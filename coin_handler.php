<?php
header('Content-Type: application/json');

// Directory for image uploads
$uploadDir = 'uploads/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// JSON file for coin data
$jsonFile = 'coins.json';

// Log file for debugging
$logFile = 'debug.log';
function logMessage($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

// Determine the action
$action = isset($_GET['action']) ? $_GET['action'] : (isset($_POST['action']) ? $_POST['action'] : '');

logMessage("Action received: $action");

switch ($action) {
    case 'save':
        // Handle image upload if provided
        $imageUrl = '';
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $image = $_FILES['image'];
            $imageName = uniqid() . '_' . basename($image['name']);
            $targetPath = $uploadDir . $imageName;
            
            logMessage("Attempting to upload image to: $targetPath");
            if (move_uploaded_file($image['tmp_name'], $targetPath)) {
                $imageUrl = $targetPath;
                logMessage("Image uploaded successfully: $imageUrl");
            } else {
                logMessage("Failed to upload image");
                echo json_encode(['success' => false, 'error' => 'Failed to upload image']);
                exit;
            }
        } else {
            logMessage("No image uploaded or upload error: " . (isset($_FILES['image']) ? $_FILES['image']['error'] : 'No image'));
        }

        // Validate required fields
        $requiredFields = ['tokenAddress', 'name', 'symbol', 'supply', 'devAddress', 'timestamp', 'txHash', 'renounced'];
        foreach ($requiredFields as $field) {
            if (!isset($_POST[$field]) || empty($_POST[$field])) {
                logMessage("Missing required field: $field");
                echo json_encode(['success' => false, 'error' => "Missing required field: $field"]);
                exit;
            }
        }

        // Get existing coin data
        $coins = file_exists($jsonFile) ? json_decode(file_get_contents($jsonFile), true) : [];
        if ($coins === null) {
            logMessage("Failed to parse existing coins.json");
            echo json_encode(['success' => false, 'error' => 'Failed to parse existing coin data']);
            exit;
        }
        logMessage("Existing coins: " . json_encode($coins));

        // New coin data
        $newCoin = [
            'tokenAddress' => $_POST['tokenAddress'],
            'name' => $_POST['name'],
            'symbol' => $_POST['symbol'],
            'supply' => $_POST['supply'],
            'imageUrl' => $imageUrl,
            'devAddress' => $_POST['devAddress'],
            'timestamp' => $_POST['timestamp'],
            'txHash' => $_POST['txHash'],
            'renounced' => $_POST['renounced']
        ];

        logMessage("New coin data: " . json_encode($newCoin));

        // Add new coin to array
        $coins[$_POST['tokenAddress']] = $newCoin;

        // Save updated data
        logMessage("Saving updated coins to $jsonFile");
        if (file_put_contents($jsonFile, json_encode($coins, JSON_PRETTY_PRINT)) === false) {
            logMessage("Failed to save coin data");
            echo json_encode(['success' => false, 'error' => 'Failed to save coin data']);
            exit;
        }

        logMessage("Coin data saved successfully");
        echo json_encode([
            'success' => true,
            'imageUrl' => $imageUrl
        ]);
        break;

    case 'get':
        logMessage("Fetching coins from $jsonFile");
        if (file_exists($jsonFile)) {
            $coins = json_decode(file_get_contents($jsonFile), true);
            if ($coins === null) {
                logMessage("Failed to parse coins.json");
                echo json_encode([]);
                exit;
            }
            // Convert associative array to indexed array for frontend
            $coinArray = array_values($coins);
            logMessage("Returning coins: " . json_encode($coinArray));
            echo json_encode($coinArray);
        } else {
            logMessage("No coins file found");
            echo json_encode([]);
        }
        break;

    case 'update_renounced':
        // Get POST data
        $data = json_decode(file_get_contents('php://input'), true);
        $tokenAddress = $data['tokenAddress'] ?? null;
        $renounced = $data['renounced'] ?? null;

        if (!$tokenAddress || $renounced === null) {
            logMessage("Missing tokenAddress or renounced value");
            echo json_encode(['success' => false, 'error' => 'Missing tokenAddress or renounced value']);
            exit;
        }

        logMessage("Updating renounced status for token $tokenAddress to $renounced");

        // Get existing coin data
        if (file_exists($jsonFile)) {
            $coins = json_decode(file_get_contents($jsonFile), true);
            if ($coins === null) {
                logMessage("Failed to parse coins.json");
                echo json_encode(['success' => false, 'error' => 'Failed to parse coin data']);
                exit;
            }
            
            if (isset($coins[$tokenAddress])) {
                $coins[$tokenAddress]['renounced'] = $renounced;
                if (file_put_contents($jsonFile, json_encode($coins, JSON_PRETTY_PRINT)) === false) {
                    logMessage("Failed to save updated coin data");
                    echo json_encode(['success' => false, 'error' => 'Failed to save updated coin data']);
                    exit;
                }
                logMessage("Renounced status updated successfully");
                echo json_encode(['success' => true]);
            } else {
                logMessage("Coin not found: $tokenAddress");
                // Since the front-end now fetches from the blockchain, we can create a new entry if the coin doesn't exist
                $coins[$tokenAddress] = [
                    'tokenAddress' => $tokenAddress,
                    'name' => 'Unknown',
                    'symbol' => 'UNK',
                    'supply' => '0',
                    'imageUrl' => '',
                    'devAddress' => '0x0',
                    'timestamp' => 'N/A',
                    'txHash' => 'N/A',
                    'renounced' => $renounced
                ];
                if (file_put_contents($jsonFile, json_encode($coins, JSON_PRETTY_PRINT)) === false) {
                    logMessage("Failed to save new coin data for renounced update");
                    echo json_encode(['success' => false, 'error' => 'Failed to save new coin data']);
                    exit;
                }
                logMessage("Created new coin entry for $tokenAddress with renounced status");
                echo json_encode(['success' => true]);
            }
        } else {
            logMessage("No coin data found, creating new file");
            $coins = [];
            $coins[$tokenAddress] = [
                'tokenAddress' => $tokenAddress,
                'name' => 'Unknown',
                'symbol' => 'UNK',
                'supply' => '0',
                'imageUrl' => '',
                'devAddress' => '0x0',
                'timestamp' => 'N/A',
                'txHash' => 'N/A',
                'renounced' => $renounced
            ];
            if (file_put_contents($jsonFile, json_encode($coins, JSON_PRETTY_PRINT)) === false) {
                logMessage("Failed to create new coin data file");
                echo json_encode(['success' => false, 'error' => 'Failed to create new coin data file']);
                exit;
            }
            logMessage("Created new coin data file with entry for $tokenAddress");
            echo json_encode(['success' => true]);
        }
        break;

    default:
        logMessage("Invalid action received");
        echo json_encode(['success' => false, 'error' => 'Invalid action']);
        break;
}
?>
