<?php
header('Content-Type: application/json');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$stats_file = __DIR__ . '/stats.json';
$stats_dir = __DIR__;

// Ensure directory is writable
if (!is_writable($stats_dir)) {
    error_log("Directory $stats_dir is not writable");
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Directory not writable']);
    exit;
}

// Initialize stats file if it doesn't exist
if (!file_exists($stats_file)) {
    if (!file_put_contents($stats_file, json_encode(['playerWins' => 0, 'houseWins' => 0], JSON_PRETTY_PRINT))) {
        error_log("Failed to create $stats_file");
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to create stats file']);
        exit;
    }
    chmod($stats_file, 0666); // Set permissions
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['playerWins'], $data['houseWins'])) {
        if (file_put_contents($stats_file, json_encode($data, JSON_PRETTY_PRINT)) === false) {
            error_log("Failed to write to $stats_file");
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Failed to write stats']);
            exit;
        }
        echo json_encode(['status' => 'success']);
    } else {
        error_log("Invalid input data: " . print_r($data, true));
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
    }
} else {
    $stats = file_exists($stats_file) ? json_decode(file_get_contents($stats_file), true) : ['playerWins' => 0, 'houseWins' => 0];
    if (!is_array($stats)) {
        error_log("Invalid JSON in $stats_file, resetting to defaults");
        $stats = ['playerWins' => 0, 'houseWins' => 0];
        file_put_contents($stats_file, json_encode($stats, JSON_PRETTY_PRINT));
    }
    echo json_encode($stats);
}
?>
