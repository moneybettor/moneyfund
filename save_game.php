<?php
header('Content-Type: application/json');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$log_file = __DIR__ . '/game_log.json';
$log_dir = __DIR__;

// Ensure directory is writable
if (!is_writable($log_dir)) {
    error_log("Directory $log_dir is not writable");
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Directory not writable']);
    exit;
}

// Initialize log file if it doesn't exist
if (!file_exists($log_file)) {
    if (!file_put_contents($log_file, '[]')) {
        error_log("Failed to create $log_file");
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to create log file']);
        exit;
    }
    chmod($log_file, 0666); // Set permissions
}

$data = json_decode(file_get_contents('php://input'), true);

if ($data && isset($data['wallet'], $data['bet'], $data['outcome'], $data['playerScore'], $data['dealerScore'], $data['winAmount'], $data['isBlackjack'], $data['isBust'], $data['timestamp'])) {
    $logs = file_exists($log_file) ? json_decode(file_get_contents($log_file), true) : [];
    if (!is_array($logs)) {
        error_log("Invalid JSON in $log_file, resetting to empty array");
        $logs = [];
    }
    $logs[] = $data;
    if (file_put_contents($log_file, json_encode($logs, JSON_PRETTY_PRINT)) === false) {
        error_log("Failed to write to $log_file");
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to write log']);
        exit;
    }
    echo json_encode(['status' => 'success']);
} else {
    error_log("Invalid input data: " . print_r($data, true));
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
}
?>
