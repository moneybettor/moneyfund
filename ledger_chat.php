<?php
header('Content-Type: application/json');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$chat_file = __DIR__ . '/chat_data.json';
$chat_dir = __DIR__;

// Ensure directory is writable
if (!is_writable($chat_dir)) {
    error_log("Directory $chat_dir is not writable");
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Directory not writable']);
    exit;
}

// Initialize chat file if it doesn't exist
if (!file_exists($chat_file)) {
    if (!file_put_contents($chat_file, json_encode(['chatMessages' => []], JSON_PRETTY_PRINT))) {
        error_log("Failed to create $chat_file");
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to create chat file']);
        exit;
    }
    chmod($chat_file, 0666); // Set permissions
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['chatMessages']) && is_array($data['chatMessages'])) {
        if (file_put_contents($chat_file, json_encode(['chatMessages' => $data['chatMessages']], JSON_PRETTY_PRINT)) === false) {
            error_log("Failed to write to $chat_file");
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Failed to write chat data']);
            exit;
        }
        echo json_encode(['status' => 'success']);
    } else {
        error_log("Invalid input data: " . print_r($data, true));
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
    }
} else {
    $chat_data = file_exists($chat_file) ? json_decode(file_get_contents($chat_file), true) : ['chatMessages' => []];
    if (!is_array($chat_data) || !isset($chat_data['chatMessages'])) {
        error_log("Invalid JSON in $chat_file, resetting to defaults");
        $chat_data = ['chatMessages' => []];
        file_put_contents($chat_file, json_encode($chat_data, JSON_PRETTY_PRINT));
    }
    echo json_encode($chat_data);
}
?>
