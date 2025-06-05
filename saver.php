<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: text/plain');

$jsonFile = 'dm_state.json';
$uploadDir = 'uploads/';
$initialState = [
    'users' => [],
    'messages' => [],
    'lastRead' => [],
    'typing' => [],
    'newMessage' => null,
    'last_action_timestamp' => 0,
    'group_chats' => []
];

// Ensure upload directory exists
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

if (!file_exists($jsonFile) || filesize($jsonFile) === 0) {
    file_put_contents($jsonFile, json_encode($initialState));
    $dmState = $initialState;
} else {
    $dmState = json_decode(file_get_contents($jsonFile), true) ?? $initialState;
    $dmState = array_merge($initialState, $dmState);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_POST['user'] ?? '';
    $action = $_POST['action'] ?? '';
    $recipient = $_POST['recipient'] ?? '';
    $content = $_POST['content'] ?? '';
    $isTyping = $_POST['isTyping'] ?? '0';
    $conversation = $_POST['conversation'] ?? '';
    $timestamp = $_POST['timestamp'] ?? '';
    $reaction = $_POST['reaction'] ?? '';
    $groupName = $_POST['group_name'] ?? '';
    $members = isset($_POST['members']) ? json_decode($_POST['members'], true) : [];
    $initialMessage = $_POST['initial_message'] ?? '';
    $wallets = isset($_POST['wallets']) ? json_decode($_POST['wallets'], true) : [];

    $userIndex = array_search($userId, array_column($dmState['users'], 'id'));

    switch ($action) {
        case 'join':
            if ($userIndex === false && $userId) {
                $dmState['users'][] = ['id' => $userId, 'joined' => time()];
                $dmState['last_action_timestamp'] = time();
                echo "User $userId joined";
            }
            // Sync all wallets to the users array
            if (!empty($wallets)) {
                foreach ($wallets as $wallet) {
                    if (!isset($wallet['address']) || empty($wallet['address'])) {
                        continue; // Skip invalid wallet entries
                    }
                    $walletId = $wallet['address'];
                    $formattedWalletId = substr($walletId, 0, 6) . '...' . substr($walletId, -4);
                    // Check if the formatted wallet ID already exists in users
                    $walletExists = false;
                    foreach ($dmState['users'] as $user) {
                        if ($user['id'] === $formattedWalletId) {
                            $walletExists = true;
                            break;
                        }
                    }
                    if (!$walletExists) {
                        $dmState['users'][] = ['id' => $formattedWalletId, 'joined' => time()];
                    }
                }
                $dmState['last_action_timestamp'] = time();
            }
            break;
        case 'send':
            if ($userIndex !== false && $recipient && $content) {
                if (!$recipient) break;
                $conversationKey = $recipient;
                if (!str_starts_with($recipient, 'group_')) {
                    $conversationKey = [$userId, $recipient];
                    sort($conversationKey);
                    $conversationKey = implode('-', $conversationKey);
                    if (!array_search($recipient, array_column($dmState['users'], 'id'))) {
                        $dmState['users'][] = ['id' => $recipient, 'joined' => time()];
                    }
                }
                if (!isset($dmState['messages'][$conversationKey])) {
                    $dmState['messages'][$conversationKey] = [];
                }
                $dmState['messages'][$conversationKey][] = [
                    'sender' => $userId,
                    'content' => htmlspecialchars($content),
                    'timestamp' => time(),
                    'type' => 'text',
                    'reactions' => []
                ];
                $dmState['newMessage'] = ['sender' => $userId, 'recipient' => $recipient, 'content' => $content, 'timestamp' => time()];
                $dmState['last_action_timestamp'] = time();
                echo "Message sent";
            }
            break;
        case 'upload_image':
            if ($userIndex !== false && $recipient && isset($_FILES['image'])) {
                $file = $_FILES['image'];
                $fileName = time() . '_' . basename($file['name']);
                $targetPath = $uploadDir . $fileName;

                if (move_uploaded_file($file['tmp_name'], $targetPath)) {
                    $conversationKey = $recipient;
                    if (!str_starts_with($recipient, 'group_')) {
                        $conversationKey = [$userId, $recipient];
                        sort($conversationKey);
                        $conversationKey = implode('-', $conversationKey);
                    }
                    if (!isset($dmState['messages'][$conversationKey])) {
                        $dmState['messages'][$conversationKey] = [];
                    }
                    $dmState['messages'][$conversationKey][] = [
                        'sender' => $userId,
                        'content' => $targetPath,
                        'timestamp' => time(),
                        'type' => 'image',
                        'reactions' => []
                    ];
                    $dmState['last_action_timestamp'] = time();
                    echo "Image uploaded";
                } else {
                    echo "Image upload failed";
                }
            }
            break;
        case 'create_group':
            if ($userIndex !== false && $groupName && !empty($members) && $initialMessage) {
                $groupId = uniqid('group_');
                $dmState['group_chats'][$groupId] = [
                    'name' => htmlspecialchars($groupName),
                    'members' => array_values(array_unique($members)),
                    'created' => time()
                ];
                $conversationKey = $groupId;
                if (!isset($dmState['messages'][$conversationKey])) {
                    $dmState['messages'][$conversationKey] = [];
                }
                $dmState['messages'][$conversationKey][] = [
                    'sender' => $userId,
                    'content' => htmlspecialchars($initialMessage),
                    'timestamp' => time(),
                    'type' => 'text',
                    'reactions' => []
                ];
                $dmState['newMessage'] = ['sender' => $userId, 'recipient' => $groupId, 'content' => $initialMessage, 'timestamp' => time()];
                $dmState['last_action_timestamp'] = time();
                echo "Group created with initial message";
            } else {
                echo "Missing group name, members, or initial message";
            }
            break;
        case 'typing':
            if ($recipient && $userId !== $recipient) {
                $conversationKey = $recipient;
                if (!str_starts_with($recipient, 'group_')) {
                    $conversationKey = [$userId, $recipient];
                    sort($conversationKey);
                    $conversationKey = implode('-', $conversationKey);
                }
                if (!isset($dmState['typing'][$conversationKey])) $dmState['typing'][$conversationKey] = [];
                if ($isTyping == '1') {
                    $dmState['typing'][$conversationKey][$userId] = time();
                } else {
                    unset($dmState['typing'][$conversationKey][$userId]);
                    if (empty($dmState['typing'][$conversationKey])) unset($dmState['typing'][$conversationKey]);
                }
                $dmState['last_action_timestamp'] = time();
            }
            break;
        case 'react':
            if ($conversation && $timestamp && $reaction) {
                $conversationKey = $conversation;
                if (isset($dmState['messages'][$conversationKey])) {
                    foreach ($dmState['messages'][$conversationKey] as &$msg) {
                        if ($msg['timestamp'] == $timestamp) {
                            $msg['reactions'][$reaction] = ($msg['reactions'][$reaction] ?? 0) + 1;
                            break;
                        }
                    }
                }
                $dmState['last_action_timestamp'] = time();
                echo "Reaction added";
            }
            break;
    }

    $fp = fopen($jsonFile, 'c');
    if (flock($fp, LOCK_EX)) {
        ftruncate($fp, 0);
        fwrite($fp, json_encode($dmState, JSON_PRETTY_PRINT));
        fflush($fp);
        flock($fp, LOCK_UN);
    } else {
        echo "Failed to lock file for writing";
    }
    fclose($fp);
} else {
    echo "Invalid request";
}
?>
