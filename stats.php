<?php
// Error reporting for debugging (disable in production)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Define stats file path
$stats_file = 'stats.json';

// Default stats
$default_stats = [
    'money_holders' => 920,
    'total_money_supply' => 1000000,
    'burned_money' => 28,
    'staked_money' => 28.8,
    'money_in_dao' => 25.5,
    'usdm_supply' => 3.5,
    'usdm_holders' => 24,
    'etfs_created' => 4,
    'coins_created' => 23,
    'dex_swaps' => 2,
    'dex_pairs' => 2,
    'airdrops_sent' => 536,
    'dao_proposals_executed' => 10, // New category added
    'last_updated' => date('Y-m-d H:i:s')
];

// Load stats from JSON or use defaults
if (file_exists($stats_file) && is_readable($stats_file)) {
    $stats = json_decode(file_get_contents($stats_file), true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        $stats = $default_stats;
    }
} else {
    $stats = $default_stats;
    if (is_writable(dirname($stats_file))) {
        file_put_contents($stats_file, json_encode($stats, JSON_PRETTY_PRINT));
    }
}

// Handle form submission
$error_message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['password']) && $_POST['password'] === 'MoneyFund') {
    $stats = [
        'money_holders' => (int)($_POST['money_holders'] ?? 0),
        'total_money_supply' => (int)($_POST['total_money_supply'] ?? 0),
        'burned_money' => (int)($_POST['burned_money'] ?? 0),
        'staked_money' => (float)($_POST['staked_money'] ?? 0),
        'money_in_dao' => (float)($_POST['money_in_dao'] ?? 0),
        'usdm_supply' => (float)($_POST['usdm_supply'] ?? 0),
        'usdm_holders' => (int)($_POST['usdm_holders'] ?? 0),
        'etfs_created' => (int)($_POST['etfs_created'] ?? 0),
        'coins_created' => (int)($_POST['coins_created'] ?? 0),
        'dex_swaps' => (int)($_POST['dex_swaps'] ?? 0),
        'dex_pairs' => (int)($_POST['dex_pairs'] ?? 0),
        'airdrops_sent' => (int)($_POST['airdrops_sent'] ?? 0),
        'dao_proposals_executed' => (int)($_POST['dao_proposals_executed'] ?? 0), // New category added
        'last_updated' => date('Y-m-d H:i:s')
    ];
    if (is_writable($stats_file)) {
        file_put_contents($stats_file, json_encode($stats, JSON_PRETTY_PRINT));
    } else {
        $error_message = 'Error: Cannot write to stats.json. Check file permissions.';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <title>MoneyFund Stats</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            min-height: 100vh;
            background: linear-gradient(180deg, #1A2634, #2C3E50);
            color: #E6ECEF;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: clamp(20px, 5vw, 40px) clamp(10px, 3vw, 20px);
            overflow-x: hidden;
        }

        #particles-js {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            pointer-events: none;
        }

        .content {
            z-index: 2;
            text-align: center;
            width: 90%;
            margin: 0 auto;
        }

        .stats-box {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: clamp(15px, 3vw, 20px);
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
            text-align: left;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: clamp(1rem, 2vw, 2rem);
            margin-bottom: clamp(0.8rem, 2vw, 1rem);
        }

        .stats-column h3 {
            font-size: clamp(1rem, 2.5vw, 1.2rem);
            font-weight: 600;
            color: #FFFFFF;
            margin-bottom: clamp(0.5rem, 1.5vw, 0.75rem);
        }

        .stat-item {
            font-size: clamp(0.85rem, 2vw, 1rem);
            color: #D0D9E0;
            margin-bottom: clamp(0.3rem, 1vw, 0.5rem);
        }

        .stat-item span {
            font-weight: 600;
            color: #FFFFFF;
        }

        .update-section {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-top: clamp(0.8rem, 2vw, 1rem);
            gap: clamp(0.8rem, 2vw, 1rem);
            flex-wrap: wrap;
        }

        .update-btn {
            padding: clamp(0.4rem, 1.5vw, 0.5rem) clamp(0.8rem, 2vw, 1rem);
            font-size: clamp(0.8rem, 1.8vw, 0.9rem);
            font-weight: 600;
            color: #FFFFFF;
            background: #4B5EAA;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            touch-action: manipulation;
        }

        .update-btn:hover {
            background: #3B4A8C;
            transform: translateY(-2px);
        }

        .last-updated {
            font-size: clamp(0.75rem, 1.8vw, 0.9rem);
            color: #A0A9B0;
        }

        .error {
            font-size: clamp(0.75rem, 1.8vw, 0.9rem);
            color: #FF6B6B;
            text-align: center;
            margin-top: clamp(0.8rem, 2vw, 1rem);
        }

        .edit-form {
            display: none;
            margin-top: clamp(0.8rem, 2vw, 1rem);
        }

        .edit-form input {
            width: 100%;
            padding: clamp(0.4rem, 1.5vw, 0.5rem);
            margin-bottom: clamp(0.3rem, 1vw, 0.5rem);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            background: rgba(255, 255, 255, 0.1);
            color: #FFFFFF;
            font-size: clamp(0.8rem, 1.8vw, 0.9rem);
        }

        .edit-form button {
            padding: clamp(0.4rem, 1.5vw, 0.5rem) clamp(0.8rem, 2vw, 1rem);
            font-size: clamp(0.8rem, 1.8vw, 0.9rem);
            font-weight: 600;
            color: #FFFFFF;
            background: #4B5EAA;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            touch-action: manipulation;
        }

        .edit-form button:hover {
            background: #3B4A8C;
        }

        /* Media Queries for Additional Responsiveness */
        @media (max-width: 1024px) {
            .content {
                width: 95%;
            }
            .stats-box {
                max-width: 90%;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {
            .content {
                width: 100%;
                padding: 0 10px;
            }
            .stats-box {
                padding: 10px;
            }
            .stats-grid {
                gap: 1rem;
            }
            .update-section {
                justify-content: center;
                flex-direction: column;
                align-items: stretch;
            }
            .update-btn, .edit-form button {
                width: 100%;
                text-align: center;
            }
            .last-updated {
                text-align: center;
                margin-bottom: 0.5rem;
            }
        }

        @media (max-width: 400px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .edit-form input, .edit-form button {
                font-size: 0.75rem;
            }
        }
    </style>
</head>
<body>
    <div id="particles-js"></div>
    <div class="content">
        <div class="stats-box">
            <div class="stats-grid">
                <div class="stats-column">
                    <div class="stat-item">MONEY Holders: <span><?php echo $stats['money_holders']; ?></span></div>
                    <div class="stat-item">MONEY Supply: <span><?php echo number_format($stats['total_money_supply']); ?></span></div>
                    <div class="stat-item">MONEY Burned: <span><?php echo $stats['burned_money']; ?></span></div>
                    <div class="stat-item">MONEY Staked: <span><?php echo $stats['staked_money']; ?></span></div>
                    <div class="stat-item">MONEY in DAO: <span><?php echo $stats['money_in_dao']; ?></span></div>
                </div>
                <div class="stats-column">
                    <div class="stat-item">USDM Supply: <span><?php echo $stats['usdm_supply']; ?></span></div>
                    <div class="stat-item">USDM Holders: <span><?php echo $stats['usdm_holders']; ?></span></div>
                    <div class="stat-item">ETFs Created: <span><?php echo $stats['etfs_created']; ?></span></div>
                    <div class="stat-item">Coins Created: <span><?php echo $stats['coins_created']; ?></span></div>
                    <div class="stat-item">Dex Swaps: <span><?php echo $stats['dex_swaps']; ?></span></div>
                    <div class="stat-item">Dex Pairs: <span><?php echo $stats['dex_pairs']; ?></span></div>
                    <div class="stat-item">Airdrops Sent: <span><?php echo $stats['airdrops_sent']; ?></span></div>
                    <div class="stat-item">DAO Proposals Executed: <span><?php echo $stats['dao_proposals_executed']; ?></span></div> <!-- New category added -->
                </div>
            </div>
            <div class="update-section">
                <span class="last-updated">Last Updated: <?php echo $stats['last_updated']; ?></span>
                <button class="update-btn" onclick="promptPassword()">Update</button>
            </div>
            <?php if ($error_message): ?>
                <div class="error"><?php echo $error_message; ?></div>
            <?php endif; ?>
            <form class="edit-form" id="statsForm" method="POST">
                <input type="hidden" name="password" id="passwordInput">
                <h3>MONEY Stats</h3>
                <input type="number" name="money_holders" value="<?php echo $stats['money_holders']; ?>" placeholder="MONEY Holders" required>
                <input type="number" name="total_money_supply" value="<?php echo $stats['total_money_supply']; ?>" placeholder="Total MONEY Supply" required>
                <input type="number" name="burned_money" value="<?php echo $stats['burned_money']; ?>" placeholder="Burned MONEY" required>
                <input type="number" step="0.1" name="staked_money" value="<?php echo $stats['staked_money']; ?>" placeholder="Staked MONEY" required>
                <input type="number" step="0.1" name="money_in_dao" value="<?php echo $stats['money_in_dao']; ?>" placeholder="MONEY in DAO" required>
                <h3>Other Stats</h3>
                <input type="number" step="0.1" name="usdm_supply" value="<?php echo $stats['usdm_supply']; ?>" placeholder="USDM Supply" required>
                <input type="number" name="usdm_holders" value="<?php echo $stats['usdm_holders']; ?>" placeholder="USDM Holders" required>
                <input type="number" name="etfs_created" value="<?php echo $stats['etfs_created']; ?>" placeholder="ETFs Created" required>
                <input type="number" name="coins_created" value="<?php echo $stats['coins_created']; ?>" placeholder="Coins Created" required>
                <input type="number" name="dex_swaps" value="<?php echo $stats['dex_swaps']; ?>" placeholder="Dex Swaps" required>
                <input type="number" name="dex_pairs" value="<?php echo $stats['dex_pairs']; ?>" placeholder="Dex Pairs" required>
                <input type="number" name="airdrops_sent" value="<?php echo $stats['airdrops_sent']; ?>" placeholder="Airdrops Sent" required>
                <input type="number" name="dao_proposals_executed" value="<?php echo $stats['dao_proposals_executed']; ?>" placeholder="DAO Proposals Executed" required> <!-- New category added -->
                <button type="submit">Save Changes</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/particles.js/2.0.0/particles.min.js"></script>
    <script>
        function adjustParticles() {
            const isMobile = window.innerWidth <= 600;
            particlesJS('particles-js', {
                particles: {
                    number: { value: isMobile ? 40 : 70, density: { enable: true, value_area: isMobile ? 600 : 900 } },
                    color: { value: '#D8DDE5' },
                    shape: { type: 'circle' },
                    opacity: { value: 0.3, random: true },
                    size: { value: isMobile ? 2 : 2.5, random: true },
                    line_linked: { enable: true, distance: isMobile ? 100 : 120, color: '#D8DDE5', opacity: 0.25, width: 1 },
                    move: { enable: true, speed: isMobile ? 1 : 1.5, direction: 'none', random: true, straight: false, out_mode: 'out', bounce: false }
                },
                interactivity: {
                    detect_on: 'canvas',
                    events: { onhover: { enable: !isMobile, mode: 'grab' }, onclick: { enable: false }, resize: true },
                    modes: { grab: { distance: 150, line_linked: { opacity: 0.4 } } }
                },
                retina_detect: true
            });
        }

        adjustParticles();

        window.addEventListener('resize', () => {
            adjustParticles();
            const canvas = document.querySelector('#particles-js canvas');
            if (canvas) {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
            }
        });

        function promptPassword() {
            const password = prompt('Enter password to edit stats:');
            if (password === 'MoneyFund') {
                document.getElementById('passwordInput').value = password;
                document.getElementById('statsForm').style.display = 'block';
                window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
            } else {
                alert('Incorrect password');
            }
        }
    </script>
</body>
</html>
