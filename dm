<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Direct Messaging</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            text-rendering: optimizeLegibility;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0A0C1E, #1F2A44); /* Matches MoneyFund body background */
            color: #E8ECEF;
            display: flex;
            flex-direction: column;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
        }

        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80" opacity="0.03"%3E%3Cdefs%3E%3Cfilter id="noise"%3E%3CfeTurbulence type="fractalNoise" baseFrequency="0.7" numOctaves="4" stitchTiles="stitch"/%3E%3C/filter%3E%3C/defs%3E%3Crect width="100%" height="100%" filter="url(%23noise)"/%3E%3C/svg%3E'); /* Matches MoneyFund noise overlay */
            z-index: -1;
        }

        .flex-container {
            display: flex;
            height: 100%;
            justify-content: center;
            align-items: center;
            padding: 0;
            box-sizing: border-box;
            flex-direction: column;
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
        }

        #username-header {
            width: 100%;
            max-width: 1200px;
            padding: 12px 20px;
            background: rgba(17, 24, 39, 0.95); /* Matches MoneyFund panel background */
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund panel border */
            border-radius: 8px 8px 0 0;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3); /* Matches MoneyFund panel shadow */
            color: #FFFFFF;
            font-weight: 600;
            font-size: 1.1em;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            z-index: 1;
        }

        #wallet-selector {
            padding: 8px;
            font-size: 1em;
            border-radius: 6px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund input border */
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund input background */
            color: #E8ECEF;
            text-align: center;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        #wallet-selector:hover, #wallet-selector:focus {
            border-color: rgba(99, 102, 241, 0.4); /* Matches MoneyFund input hover */
            box-shadow: 0 0 6px rgba(99, 102, 241, 0.3); /* Matches MoneyFund input hover */
            outline: none;
        }

        #toggle-container {
            width: 100%;
            max-width: 1200px;
            padding: 10px 20px;
            background: rgba(17, 24, 39, 0.95); /* Matches MoneyFund panel background */
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund panel border */
            border-radius: 6px;
            text-align: center;
            margin-bottom: 10px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            z-index: 1;
        }

        #toggle-view {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund button border */
            font-size: 0.95em;
            cursor: pointer;
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            color: #F9FAFB; /* Matches MoneyFund button text color */
            transition: background 0.3s ease, transform 0.2s ease;
        }

        #toggle-view:hover, #toggle-view:focus {
            background: linear-gradient(90deg, #4338CA, #9333EA); /* Matches MoneyFund button hover */
            transform: scale(1.02);
            outline: none;
        }

        .search-container {
            position: relative;
            display: flex;
            align-items: center;
        }

        #search-bar {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund input border */
            font-size: 0.95em;
            box-sizing: border-box;
            width: 200px;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund input background */
            color: #E8ECEF;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        #search-bar:hover, #search-bar:focus {
            border-color: rgba(99, 102, 241, 0.4); /* Matches MoneyFund input hover */
            box-shadow: 0 0 6px rgba(99, 102, 241, 0.3); /* Matches MoneyFund input hover */
            outline: none;
        }

        #search-bar::placeholder {
            color: #9CA3AF; /* Matches MoneyFund placeholder color */
            opacity: 1;
        }

        #clear-search {
            position: absolute;
            right: 8px;
            background: none;
            border: none;
            font-size: 0.9em;
            cursor: pointer;
            color: #A3BFFA;
            display: none;
        }

        #clear-search:hover {
            color: #E8ECEF;
        }

        #dm-container {
            width: 100%;
            max-width: 1200px;
            height: 800px;
            background: rgba(17, 24, 39, 0.95); /* Matches MoneyFund panel background */
            border-radius: 0 0 8px 8px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3); /* Matches MoneyFund panel shadow */
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund panel border */
            display: flex;
            overflow: hidden;
            z-index: 1;
        }

        #conversations-list {
            width: 30%;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            padding: 20px;
            overflow-y: auto;
            border-right: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
        }

        #conversations-header {
            font-weight: 600;
            font-size: 1em;
            margin-bottom: 10px;
            color: #FFFFFF;
        }

        #chat-area {
            width: 70%;
            padding: 20px;
            display: flex;
            flex-direction: column;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
        }

        #chat-header {
            font-weight: 600;
            font-size: 1.1em;
            color: #FFFFFF;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
            margin-bottom: 10px;
        }

        #messages {
            flex-grow: 1;
            overflow-y: auto;
            padding: 20px;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            border-radius: 8px;
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
        }

        .message {
            margin: 10px 0;
            padding: 12px 16px;
            border-radius: 12px;
            max-width: 70%;
            word-wrap: break-word;
            display: flex;
            flex-direction: column;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .message.sent {
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            color: #F9FAFB; /* Matches MoneyFund button text color */
            align-self: flex-end;
        }

        .message.received {
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            color: #E8ECEF;
            align-self: flex-start;
        }

        .message img {
            max-width: 100%;
            border-radius: 8px;
            margin-top: 5px;
        }

        .message .sender-id {
            font-size: 0.7em;
            color: #A3BFFA;
            margin-bottom: 4px;
        }

        .message .timestamp {
            font-size: 0.7em;
            color: #A3BFFA;
            align-self: flex-end;
            margin-top: 4px;
        }

        .message .reactions {
            margin-top: 5px;
            display: flex;
            gap: 5px;
        }

        .reaction {
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 0.8em;
            cursor: pointer;
            color: #E8ECEF;
            transition: background 0.3s ease;
        }

        .reaction:hover {
            background: rgba(255, 255, 255, 0.1); /* Matches MoneyFund hover */
        }

        #message-input {
            display: flex;
            gap: 10px;
            align-items: center;
            background: rgba(17, 24, 39, 0.95); /* Matches MoneyFund panel background */
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 1px 5px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
        }

        input[type="text"] {
            flex-grow: 1;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund input border */
            font-size: 1em;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund input background */
            color: #E8ECEF;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        input[type="text"]:hover, input[type="text"]:focus {
            border-color: rgba(99, 102, 241, 0.4); /* Matches MoneyFund input hover */
            box-shadow: 0 0 6px rgba(99, 102, 241, 0.3); /* Matches MoneyFund input hover */
            outline: none;
        }

        input[type="text"]::placeholder {
            color: #9CA3AF; /* Matches MoneyFund placeholder color */
            opacity: 1;
        }

        input[type="file"] {
            display: none;
        }

        .upload-btn {
            padding: 12px;
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            border: none; /* Removed border to match MoneyFund button */
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9em;
            color: #F9FAFB; /* Matches MoneyFund button text color */
            transition: background 0.3s ease, transform 0.2s ease;
        }

        .upload-btn:hover {
            background: linear-gradient(90deg, #4338CA, #9333EA); /* Matches MoneyFund button hover */
            transform: scale(1.02);
        }

        button {
            padding: 12px 20px;
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            border: none;
            border-radius: 6px;
            cursor: pointer;
            color: #F9FAFB; /* Matches MoneyFund button text color */
            font-weight: 500;
            font-size: 1em;
            transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }

        button:hover {
            background: linear-gradient(90deg, #4338CA, #9333EA); /* Matches MoneyFund button hover */
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2); /* Adjusted to match MoneyFund hover shadow */
        }

        button:disabled {
            background: rgba(75, 85, 99, 0.6); /* Matches MoneyFund disabled button */
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .typing-indicator {
            color: #A3BFFA;
            font-style: italic;
            font-size: 0.9em;
            margin-bottom: 5px;
        }

        .group-chat-modal {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(17, 24, 39, 0.95); /* Matches MoneyFund panel background */
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3); /* Matches MoneyFund panel shadow */
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund panel border */
            z-index: 1000;
            width: 90%;
            max-width: 500px;
            max-height: 80vh;
            display: flex;
            flex-direction: column;
            color: #E8ECEF;
        }

        .group-chat-modal .user-list {
            max-height: 200px;
            overflow-y: auto;
            margin: 10px 0;
            padding: 10px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
            border-radius: 6px;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
        }

        .group-chat-modal .user-list label {
            display: block;
            margin: 5px 0;
            color: #E8ECEF;
        }

        .group-chat-modal button {
            margin-top: 10px;
            margin-right: 10px;
        }

        .group-chat-modal .button-container {
            display: flex;
            justify-content: flex-end;
        }

        .group-chat-modal .search-container {
            position: relative;
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .group-chat-modal #group-search-bar {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund input border */
            font-size: 0.95em;
            box-sizing: border-box;
            width: 100%;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund input background */
            color: #E8ECEF;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .group-chat-modal #group-search-bar:hover, .group-chat-modal #group-search-bar:focus {
            border-color: rgba(99, 102, 241, 0.4); /* Matches MoneyFund input hover */
            box-shadow: 0 0 6px rgba(99, 102, 241, 0.3); /* Matches MoneyFund input hover */
            outline: none;
        }

        .group-chat-modal #group-search-bar::placeholder {
            color: #9CA3AF; /* Matches MoneyFund placeholder color */
            opacity: 1;
        }

        .group-chat-modal #clear-group-search {
            position: absolute;
            right: 8px;
            background: none;
            border: none;
            font-size: 0.9em;
            cursor: pointer;
            color: #A3BFFA;
            display: none;
        }

        .group-chat-modal #clear-group-search:hover {
            color: #E8ECEF;
        }

        .conversation-item {
            padding: 12px 15px;
            margin: 8px 0;
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            border-radius: 8px;
            box-shadow: 0 1px 5px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
            cursor: pointer;
            transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease;
            display: flex;
            align-items: center;
            color: #E8ECEF;
        }

        .conversation-item:hover {
            background: rgba(255, 255, 255, 0.1); /* Matches MoneyFund hover */
            transform: scale(1.05); /* Matches MoneyFund tile hover */
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2); /* Matches MoneyFund tile hover */
        }

        .conversation-item .avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            color: #F9FAFB; /* Matches MoneyFund button text color */
            font-weight: 600;
            font-size: 0.9em;
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
        }

        .conversation-item .contact-name {
            flex-grow: 1;
            font-size: 1em;
            font-weight: 500;
        }

        .conversation-item .unread {
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            color: #F9FAFB; /* Matches MoneyFund button text color */
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.8em;
        }

        .conversation-item .group-indicator {
            background: rgba(17, 24, 39, 0.9); /* Matches MoneyFund panel background */
            color: #E8ECEF;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 8px;
        }

        .conversation-item .edit-contact {
            margin-left: 8px;
            padding: 4px 8px;
            background: linear-gradient(90deg, #4F46E5, #A855F7); /* Matches MoneyFund button background */
            border-radius: 4px;
            font-size: 0.8em;
            cursor: pointer;
            color: #F9FAFB; /* Matches MoneyFund button text color */
            transition: background 0.3s ease, transform 0.2s ease;
        }

        .conversation-item .edit-contact:hover {
            background: linear-gradient(90deg, #4338CA, #9333EA); /* Matches MoneyFund button hover */
            transform: scale(1.02);
        }

        @media (max-width: 767px) {
            body {
                padding: 10px;
            }

            #dm-container {
                height: 600px;
                flex-direction: column;
            }

            #conversations-list {
                width: 100%;
                height: 30%;
                border-bottom: 1px solid rgba(99, 102, 241, 0.2); /* Matches MoneyFund border */
                border-right: none;
            }

            #chat-area {
                width: 100%;
                height: 70%;
            }

            #chat-header {
                font-size: 0.95em;
                padding-bottom: 8px;
            }

            .conversation-item {
                padding: 10px;
                margin: 8px 0;
                font-size: 0.9em;
            }

            .conversation-item .avatar {
                width: 30px;
                height: 30px;
                font-size: 0.8em;
            }

            .conversation-item .unread {
                padding: 2px 6px;
                font-size: 0.7em;
            }

            #messages {
                padding: 10px;
                font-size: 0.9em;
            }

            .message {
                padding: 8px;
                max-width: 80%;
            }

            input[type="text"] {
                padding: 10px;
                font-size: 0.9em;
            }

            button {
                padding: 10px 16px;
                font-size: 0.9em;
            }

            #search-bar {
                width: 100%;
            }

            .group-chat-modal {
                width: 95%;
                max-height: 70vh;
            }

            .group-chat-modal .user-list {
                max-height: 150px;
            }
        }
    </style>
</head>
<body>
    <div class="flex-container">
        <div id="username-header">
            My Username:
            <select id="wallet-selector" onchange="selectWallet(this.value)">
                <option value="">-- Select Wallet --</option>
            </select>
        </div>
        <div id="toggle-container">
            <select id="toggle-view" onchange="updateView(this.value)">
                <option value="all-users">All Users</option>
                <option value="my-dms">My DMs</option>
            </select>
            <div class="search-container">
                <input type="text" id="search-bar" placeholder="Search by last 4 digits..." oninput="filterConversations()">
                <button id="clear-search" onclick="clearSearch()">Ã—</button>
            </div>
            <button id="create-group-btn" onclick="createGroupChat()">Create Group Chat</button>
        </div>
        <div id="dm-container">
            <div id="conversations-list">
                <div id="conversations-header"></div>
            </div>
            <div id="chat-area">
                <div id="chat-header"></div>
                <div id="messages"></div>
                <div id="message-input">
                    <input type="text" id="messageInput" placeholder="Type a message..." maxlength="500">
                    <input type="file" id="imageUpload" accept="image/*">
                    <button class="upload-btn" onclick="document.getElementById('imageUpload').click()">ðŸ“Ž</button>
                    <button id="sendBtn" disabled>Send</button>
                </div>
                <div id="typing-indicator" class="typing-indicator"></div>
            </div>
        </div>
    </div>

    <script>
        let wallets = JSON.parse(localStorage.getItem('wallets') || '[]');
        let selectedWallet = null;
        let userId = null;
        let contacts = JSON.parse(localStorage.getItem('contacts') || '{}');
        let currentConversation = localStorage.getItem('currentConversation') || null;
        let typingTimeout = null;
        let lastNotifiedTimestamp = 0;
        let currentView = 'all-users';
        let allUsers = [];
        let allConversations = [];
        let refreshInterval = null;
        let isSearchActive = false;
        let groupChatUsers = [];
        const audio = new Audio('https://www.soundjay.com/buttons/ding-01a.mp3');
        document.addEventListener('click', () => audio.play().catch(err => console.log('Initial audio play blocked:', err)), { once: true });

        function initializeWallets() {
            const walletSelector = document.getElementById('wallet-selector');
            walletSelector.innerHTML = '<option value="">-- Select Wallet --</option>';
            wallets.forEach((wallet, index) => {
                const option = document.createElement('option');
                option.value = index;
                option.textContent = wallet.address.slice(0, 6) + '...' + wallet.address.slice(-4);
                walletSelector.appendChild(option);
            });

            const selectedIndex = parseInt(localStorage.getItem('selectedWalletIndex')) || 0;
            if (wallets.length > 0 && selectedIndex >= 0 && selectedIndex < wallets.length) {
                selectedWallet = wallets[selectedIndex];
                userId = selectedWallet.address.slice(0, 6) + '...' + selectedWallet.address.slice(-4);
                walletSelector.value = selectedIndex;
            } else if (wallets.length > 0) {
                selectedWallet = wallets[0];
                userId = selectedWallet.address.slice(0, 6) + '...' + selectedWallet.address.slice(-4);
                localStorage.setItem('selectedWalletIndex', 0);
                walletSelector.value = 0;
            } else {
                userId = "user_" + Math.random().toString(36).substr(2, 5);
            }

            localStorage.setItem('userId', userId);
        }

        function selectWallet(index) {
            const idx = parseInt(index);
            if (idx >= 0 && idx < wallets.length) {
                selectedWallet = wallets[idx];
                userId = selectedWallet.address.slice(0, 6) + '...' + selectedWallet.address.slice(-4);
                localStorage.setItem('selectedWalletIndex', idx);
                localStorage.setItem('userId', userId);
                updateDM();
            } else {
                selectedWallet = null;
                userId = "user_" + Math.random().toString(36).substr(2, 5);
                localStorage.setItem('userId', userId);
            }
        }

        function debounce(func, wait) {
            let timeout;
            return function (...args) {
                clearTimeout(timeout);
                timeout = setTimeout(() => func.apply(this, args), wait);
            };
        }

        function updateView(view) {
            currentView = view;
            document.getElementById('search-bar').value = '';
            isSearchActive = false;
            document.getElementById('clear-search').style.display = 'none';
            updateDM();
        }

        function saveContact(userId) {
            const newName = prompt(`Enter a name for ${userId}:`, contacts[userId] || '');
            if (newName !== null && newName.trim() !== '') {
                contacts[userId] = newName.trim();
                localStorage.setItem('contacts', JSON.stringify(contacts));
                updateDM();
            }
        }

        function createGroupChat() {
            fetch(`dm_state.json?user=${encodeURIComponent(userId)}&_=${Date.now()}`, { cache: 'no-store' })
                .then(response => response.json())
                .then(data => {
                    groupChatUsers = data.users.filter(user => user.id !== userId && user.id.startsWith('0x'));
                    if (groupChatUsers.length === 0) {
                        alert("No wallet users available to create a group chat.");
                        return;
                    }
                    const promptDiv = document.createElement('div');
                    promptDiv.className = 'group-chat-modal';
                    promptDiv.innerHTML = `
                        <div>Group Name: <input type="text" id="groupNameInput" placeholder="Enter group name"></div>
                        <div>Initial Message: <input type="text" id="initialMessageInput" placeholder="Enter your first message"></div>
                        <div>Select Wallet Users:</div>
                        <div class="search-container">
                            <input type="text" id="group-search-bar" placeholder="Search by last 4 digits..." oninput="filterGroupChatUsers()">
                            <button id="clear-group-search" onclick="clearGroupSearch()">Ã—</button>
                        </div>
                        <div class="user-list" id="group-user-list"></div>
                        <div class="button-container">
                            <button onclick="submitGroupChat(this.parentElement.parentElement)">Create</button>
                            <button onclick="this.parentElement.parentElement.remove()">Cancel</button>
                        </div>
                    `;
                    document.body.appendChild(promptDiv);
                    filterGroupChatUsers();
                })
                .catch(err => console.error('Fetch users error:', err));
        }

        function filterGroupChatUsers() {
            const searchTerm = document.getElementById('group-search-bar').value.toLowerCase().trim();
            const clearButton = document.getElementById('clear-group-search');
            clearButton.style.display = searchTerm ? 'block' : 'none';

            const filteredUsers = groupChatUsers.filter(user => {
                const lastFourDigits = user.id.slice(-4).toLowerCase();
                return searchTerm === '' || lastFourDigits.includes(searchTerm);
            });

            const userListDiv = document.getElementById('group-user-list');
            userListDiv.innerHTML = filteredUsers.map(user => 
                `<label><input type="checkbox" value="${user.id}">${contacts[user.id] || user.id}</label>`
            ).join('');
        }

        function clearGroupSearch() {
            document.getElementById('group-search-bar').value = '';
            document.getElementById('clear-group-search').style.display = 'none';
            filterGroupChatUsers();
        }

        function submitGroupChat(modal) {
            const groupName = modal.querySelector('#groupNameInput').value.trim();
            const initialMessage = modal.querySelector('#initialMessageInput').value.trim();
            const selectedUsers = Array.from(modal.querySelectorAll('input[type="checkbox"]:checked')).map(cb => cb.value);
            if (groupName && initialMessage && selectedUsers.length > 0) {
                selectedUsers.push(userId);
                fetch('saver.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `user=${encodeURIComponent(userId)}&action=create_group&group_name=${encodeURIComponent(groupName)}&members=${encodeURIComponent(JSON.stringify(selectedUsers))}&initial_message=${encodeURIComponent(initialMessage)}`
                }).then(() => {
                    document.body.removeChild(modal);
                    updateView('my-dms');
                    updateDM();
                }).catch(err => console.error('Group chat creation error:', err));
            } else {
                alert("Please enter a group name, an initial message, and select at least one wallet user.");
            }
        }

        function updateTypingIndicator(conversationKey, isTyping) {
            if (currentConversation) {
                fetch(`saver.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `user=${encodeURIComponent(userId)}&action=typing&recipient=${encodeURIComponent(currentConversation)}&isTyping=${isTyping ? 1 : 0}`
                }).catch(err => console.error('Typing update error:', err));
            }
        }

        function filterConversations() {
            const searchTerm = document.getElementById('search-bar').value.toLowerCase().trim();
            isSearchActive = searchTerm !== '';
            document.getElementById('clear-search').style.display = isSearchActive ? 'block' : 'none';
            let filteredHtml = '';

            if (currentView === 'all-users') {
                const filtered = allUsers.filter(user => {
                    const lastFourDigits = user.id.slice(-4).toLowerCase();
                    return user.id.startsWith('0x') && (searchTerm === '' || lastFourDigits.includes(searchTerm));
                });

                filtered.forEach(user => {
                    const conversationKey = [userId, user.id].sort().join('-');
                    const messages = data.messages[conversationKey] || [];
                    const unread = messages.filter(m => m.timestamp > (data.lastRead?.[conversationKey]?.[userId] || 0) && m.sender !== userId).length;
                    const avatarText = 'MF';
                    const displayName = contacts[user.id] || user.id;
                    const editButton = `<span class="edit-contact" onclick="event.stopPropagation(); saveContact('${user.id}')">âœŽ</span>`;
                    filteredHtml += `<div class="conversation-item" onclick="selectConversation('${user.id}')"><div class="avatar">${avatarText}</div><span class="contact-name">${displayName}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}${editButton}</div>`;
                });

                document.getElementById('conversations-list').innerHTML = `
                    <div id="conversations-header">${filtered.length} Total Wallet Users</div>
                    ${filteredHtml}
                `;
            } else if (currentView === 'my-dms') {
                const filtered = allConversations.filter(conv => {
                    if (conv.type === 'user') {
                        const lastFourDigits = conv.id.slice(-4).toLowerCase();
                        return conv.id.startsWith('0x') && (searchTerm === '' || lastFourDigits.includes(searchTerm));
                    } else {
                        const lastFourDigits = conv.group.name.slice(-4).toLowerCase();
                        return searchTerm === '' || lastFourDigits.includes(searchTerm);
                    }
                });

                filtered.forEach(conv => {
                    const unread = conv.messages.filter(m => 
                        m.timestamp > (data.lastRead?.[conv.conversationKey]?.[userId] || 0) && 
                        m.sender !== userId
                    ).length;

                    if (conv.type === 'user') {
                        const userId = conv.id;
                        const avatarText = 'MF';
                        const displayName = contacts[userId] || userId;
                        const editButton = `<span class="edit-contact" onclick="event.stopPropagation(); saveContact('${userId}')">âœŽ</span>`;
                        filteredHtml += `<div class="conversation-item" onclick="selectConversation('${userId}')"><div class="avatar">${avatarText}</div><span class="contact-name">${displayName}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}${editButton}</div>`;
                    } else if (conv.type === 'group') {
                        const groupId = conv.id;
                        const group = conv.group;
                        const avatarText = group.name.charAt(0).toUpperCase();
                        const memberCount = group.members.length;
                        filteredHtml += `<div class="conversation-item" onclick="selectConversation('${groupId}')"><div class="avatar">${avatarText}</div><span class="group-indicator">ðŸ‘¥ ${memberCount}</span><span class="contact-name">${group.name}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}</div>`;
                    }
                });

                document.getElementById('conversations-list').innerHTML = `
                    <div id="conversations-header">${filtered.length} Conversations</div>
                    ${filteredHtml}
                `;
            }
        }

        function clearSearch() {
            document.getElementById('search-bar').value = '';
            isSearchActive = false;
            document.getElementById('clear-search').style.display = 'none';
            updateDM();
        }

        let data = {};

        function updateDM() {
            if (isSearchActive) return;

            fetch(`dm_state.json?user=${encodeURIComponent(userId)}&_=${Date.now()}`, { cache: 'no-store' })
                .then(response => response.json())
                .then(fetchedData => {
                    data = fetchedData;
                    let conversationsHtml = '';
                    let filteredUsers = [];
                    let filteredGroups = [];
                    let headerText = '';

                    if (currentView === 'all-users') {
                        filteredUsers = data.users.filter(user => user.id !== userId && user.id.startsWith('0x'));
                        filteredGroups = [];
                        allUsers = filteredUsers;
                        headerText = `${filteredUsers.length} Total Wallet Users`;

                        filteredUsers.forEach(user => {
                            const conversationKey = [userId, user.id].sort().join('-');
                            const messages = data.messages[conversationKey] || [];
                            const unread = messages.filter(m => m.timestamp > (data.lastRead?.[conversationKey]?.[userId] || 0) && m.sender !== userId).length;
                            const avatarText = 'MF';
                            const displayName = contacts[user.id] || user.id;
                            const editButton = `<span class="edit-contact" onclick="event.stopPropagation(); saveContact('${user.id}')">âœŽ</span>`;
                            conversationsHtml += `<div class="conversation-item" onclick="selectConversation('${user.id}')"><div class="avatar">${avatarText}</div><span class="contact-name">${displayName}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}${editButton}</div>`;
                        });
                    } else if (currentView === 'my-dms') {
                        filteredUsers = data.users.filter(user => {
                            if (user.id === userId || !user.id.startsWith('0x')) return false;
                            const conversationKey = [userId, user.id].sort().join('-');
                            return data.messages[conversationKey] && data.messages[conversationKey].length > 0;
                        });

                        filteredGroups = Object.entries(data.group_chats || {}).map(([groupId, group]) => {
                            return {
                                id: groupId,
                                ...group
                            };
                        }).filter(group => 
                            group.members.includes(userId) && 
                            data.messages[group.id] && 
                            data.messages[group.id].length > 0
                        );

                        allConversations = [];

                        filteredUsers.forEach(user => {
                            const conversationKey = [userId, user.id].sort().join('-');
                            const messages = data.messages[conversationKey] || [];
                            const latestTimestamp = messages.length > 0 ? Math.max(...messages.map(m => m.timestamp)) : 0;
                            allConversations.push({
                                type: 'user',
                                id: user.id,
                                conversationKey,
                                latestTimestamp,
                                messages
                            });
                        });

                        filteredGroups.forEach(group => {
                            const conversationKey = group.id;
                            const messages = data.messages[conversationKey] || [];
                            const latestTimestamp = messages.length > 0 ? Math.max(...messages.map(m => m.timestamp)) : 0;
                            allConversations.push({
                                type: 'group',
                                id: group.id,
                                conversationKey,
                                latestTimestamp,
                                messages,
                                group
                            });
                        });

                        allConversations.sort((a, b) => b.latestTimestamp - a.latestTimestamp);

                        headerText = `${allConversations.length} Conversations`;

                        allConversations.forEach(conv => {
                            const unread = conv.messages.filter(m => 
                                m.timestamp > (data.lastRead?.[conv.conversationKey]?.[userId] || 0) && 
                                m.sender !== userId
                            ).length;

                            if (conv.type === 'user') {
                                const userId = conv.id;
                                const avatarText = 'MF';
                                const displayName = contacts[userId] || userId;
                                const editButton = `<span class="edit-contact" onclick="event.stopPropagation(); saveContact('${userId}')">âœŽ</span>`;
                                conversationsHtml += `<div class="conversation-item" onclick="selectConversation('${userId}')"><div class="avatar">${avatarText}</div><span class="contact-name">${displayName}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}${editButton}</div>`;
                            } else if (conv.type === 'group') {
                                const groupId = conv.id;
                                const group = conv.group;
                                const avatarText = group.name.charAt(0).toUpperCase();
                                const memberCount = group.members.length;
                                conversationsHtml += `<div class="conversation-item" onclick="selectConversation('${groupId}')"><div class="avatar">${avatarText}</div><span class="group-indicator">ðŸ‘¥ ${memberCount}</span><span class="contact-name">${group.name}</span>${unread > 0 ? ` <span class="unread">+${unread}</span>` : ''}</div>`;
                            }
                        });
                    }

                    document.getElementById('conversations-header').textContent = headerText;
                    document.getElementById('conversations-list').innerHTML = `
                        <div id="conversations-header">${headerText}</div>
                        ${conversationsHtml}
                    `;

                    if (currentConversation) {
                        const conversationKey = currentConversation.startsWith('group_') ? currentConversation : [userId, currentConversation].sort().join('-');
                        const isGroupChat = currentConversation.startsWith('group_');
                        let messagesHtml = '';
                        const messages = data.messages[conversationKey] || [];
                        const messagesDiv = document.getElementById('messages');
                        const wasAtBottom = messagesDiv.scrollTop + messagesDiv.clientHeight >= messagesDiv.scrollHeight - 10;

                        messages.forEach(msg => {
                            const isSent = msg.sender === userId;
                            const content = msg.type === 'image' ? `<img src="${msg.content}" alt="Image"/>` : msg.content;
                            const senderLastFour = msg.sender.slice(-4);
                            const senderDisplay = isGroupChat ? `<span class="sender-id">${contacts[msg.sender] || senderLastFour}</span>` : '';
                            messagesHtml += `<div class="message ${isSent ? 'sent' : 'received'}">${senderDisplay}${content} <span class="timestamp">${new Date(msg.timestamp * 1000).toLocaleTimeString()}</span>${msg.reactions ? `<div class="reactions">${Object.entries(msg.reactions).map(([r, count]) => `<span class="reaction" onclick="addReaction('${conversationKey}', '${msg.timestamp}', '${r}')">${r} ${count}</span>`).join('')}</div>` : ''}</div>`;
                        });
                        document.getElementById('messages').innerHTML = messagesHtml;

                        if (wasAtBottom) {
                            messagesDiv.scrollTop = messagesDiv.scrollHeight;
                        }

                        const typingUser = Object.entries(data.typing?.[conversationKey] || {}).find(([id, time]) => id !== userId && time && (Date.now() / 1000 - time < 2));
                        document.getElementById('typing-indicator').textContent = typingUser ? `${typingUser[0]} is typing...` : '';
                        const latestMessageCheck = messages[messages.length - 1];
                        if (latestMessageCheck && latestMessageCheck.timestamp > lastNotifiedTimestamp && latestMessageCheck.sender !== userId) {
                            audio.currentTime = 0;
                            audio.play().catch(err => console.error('Audio play error:', err));
                            lastNotifiedTimestamp = latestMessageCheck.timestamp;
                        }
                    } else {
                        document.getElementById('chat-header').textContent = '';
                    }
                    document.getElementById('sendBtn').disabled = !currentConversation;
                })
                .catch(err => console.error('Fetch error:', err));
        }

        const debouncedUpdateDM = debounce(updateDM, 100);

        function selectConversation(recipient) {
            currentConversation = recipient;
            localStorage.setItem('currentConversation', recipient);
            const conversationKey = recipient.startsWith('group_') ? recipient : [userId, recipient].sort().join('-');
            const messages = data.messages[conversationKey] || [];
            
            if (recipient.startsWith('group_')) {
                const group = data.group_chats[recipient];
                document.getElementById('chat-header').textContent = group ? group.name : 'Group';
            } else {
                const displayName = contacts[recipient] || recipient;
                document.getElementById('chat-header').textContent = displayName;
            }

            if (messages.length > 0) {
                if (!data.lastRead) data.lastRead = {};
                if (!data.lastRead[conversationKey]) data.lastRead[conversationKey] = {};
                data.lastRead[conversationKey][userId] = Math.max(...messages.map(m => m.timestamp));
                fetch(`saver.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `user=${encodeURIComponent(userId)}&action=update_last_read&conversation=${encodeURIComponent(conversationKey)}&timestamp=${data.lastRead[conversationKey][userId]}`
                }).catch(err => console.error('Update last read error:', err));
            }
            updateDM();
        }

        function sendMessage() {
            const content = document.getElementById('messageInput').value.trim();
            if (content && currentConversation) {
                fetch('saver.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `user=${encodeURIComponent(userId)}&action=send&recipient=${encodeURIComponent(currentConversation)}&content=${encodeURIComponent(content)}`
                }).then(() => {
                    document.getElementById('messageInput').value = '';
                    updateDM();
                }).catch(err => console.error('Send error:', err));
            }
        }

        function uploadImage() {
            const fileInput = document.getElementById('imageUpload');
            const file = fileInput.files[0];
            if (file && currentConversation) {
                const formData = new FormData();
                formData.append('user', userId);
                formData.append('action', 'upload_image');
                formData.append('recipient', currentConversation);
                formData.append('image', file);

                fetch('saver.php', {
                    method: 'POST',
                    body: formData
                }).then(response => response.text())
                    .then(() => {
                        fileInput.value = '';
                        updateDM();
                    }).catch(err => console.error('Image upload error:', err));
            }
        }

        function addReaction(conversationKey, timestamp, reaction) {
            fetch(`saver.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `user=${encodeURIComponent(userId)}&action=react&conversation=${encodeURIComponent(conversationKey)}&timestamp=${encodeURIComponent(timestamp)}&reaction=${encodeURIComponent(reaction)}`
            }).then(() => updateDM()).catch(err => console.error('Reaction error:', err));
        }

        document.getElementById('sendBtn').addEventListener('click', sendMessage);
        document.getElementById('imageUpload').addEventListener('change', uploadImage);
        document.getElementById('messageInput').addEventListener('input', debounce((e) => {
            const conversationKey = currentConversation.startsWith('group_') ? currentConversation : [userId, currentConversation].sort().join('-');
            clearTimeout(typingTimeout);
            updateTypingIndicator(conversationKey, e.target.value.trim().length > 0);
            typingTimeout = setTimeout(() => updateTypingIndicator(conversationKey, false), 2000);
            document.getElementById('sendBtn').disabled = !currentConversation || e.target.value.trim() === '';
        }, 500));
        document.getElementById('messageInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });

        document.getElementById('search-bar').addEventListener('focus', () => {
            isSearchActive = true;
        });

        document.getElementById('search-bar').addEventListener('blur', () => {
            if (!document.getElementById('search-bar').value) {
                isSearchActive = false;
            }
        });

        initializeWallets();

        fetch(`saver.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `user=${encodeURIComponent(userId)}&action=join&wallets=${encodeURIComponent(JSON.stringify(wallets))}`
        }).then(response => response.text())
          .then(result => {
              console.log('Join result:', result);
              refreshInterval = setInterval(debouncedUpdateDM, 500);
              updateDM();
          }).catch(err => {
              console.error('Join error:', err);
              refreshInterval = setInterval(debouncedUpdateDM, 500);
              updateDM();
          });
    </script>
</body>
</html>
