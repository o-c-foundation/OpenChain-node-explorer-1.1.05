#!/bin/bash

# Repair script for OpenChain Explorer UI
# This script fixes the UI issues and adds proper routing to the explorer

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting OpenChain Explorer repair...${NC}"

# Navigate to the explorer directory
cd /opt/OpenChain-node-explorer-1.1.05

# Create necessary directories
mkdir -p public
mkdir -p src

# Create the contract-api.js file if missing
echo -e "${YELLOW}Creating contract API file...${NC}"
cat > src/contract-api.js << 'EOF'
const express = require('express');
const router = express.Router();
const crypto = require('crypto');

// Mock data for smart contracts
const contracts = {};

// Deploy a new contract
router.post('/deploy', (req, res) => {
    const { from, code } = req.body;
    
    if (!from || !code) {
        return res.status(400).json({ error: 'From address and contract code are required' });
    }
    
    const contractAddress = crypto.randomBytes(32).toString('hex');
    
    contracts[contractAddress] = {
        address: contractAddress,
        owner: from,
        code,
        createdAt: Date.now(),
        methods: {},
        state: {}
    };
    
    const txHash = crypto.randomBytes(32).toString('hex');
    
    res.json({
        success: true,
        contractAddress,
        transactionHash: txHash
    });
});

// Execute a contract method (state-changing)
router.post('/execute', (req, res) => {
    const { from, to, method, params } = req.body;
    
    if (!from || !to || !method) {
        return res.status(400).json({ error: 'From address, contract address, and method are required' });
    }
    
    const contract = contracts[to];
    if (!contract) {
        return res.status(404).json({ error: 'Contract not found' });
    }
    
    // Mock execution
    const result = {
        success: true,
        result: `Executed ${method} with ${params ? JSON.stringify(params) : 'no params'}`,
        transactionHash: crypto.randomBytes(32).toString('hex')
    };
    
    res.json(result);
});

// Call a contract method (read-only)
router.post('/call', (req, res) => {
    const { to, method, params } = req.body;
    
    if (!to || !method) {
        return res.status(400).json({ error: 'Contract address and method are required' });
    }
    
    const contract = contracts[to];
    if (!contract) {
        return res.status(404).json({ error: 'Contract not found' });
    }
    
    // Mock call result
    const result = {
        success: true,
        result: `Called ${method} with ${params ? JSON.stringify(params) : 'no params'}`
    };
    
    res.json(result);
});

module.exports = router;
EOF

# Create the index.html file
echo -e "${YELLOW}Creating index.html file...${NC}"
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenChain Explorer</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">
                <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0id2hpdGUiIGNsYXNzPSJiaSBiaS1kaWFtb25kIiB2aWV3Qm94PSIwIDAgMTYgMTYiPgogIDxwYXRoIGQ9Ik01LjQgMEEyLjQgMi40IDAgMCAwIDMgMi40VjRhMi40IDIuNCAwIDAgMCAuODU4IDEuODM5bDMuNCA0LjI1QTEuNiAxLjYgMCAwIDEgNi44IDEyLjRWMTQuNGEyLjQgMi40IDAgMCAwIDQuOCAwVjYuNEEyLjQgMi40IDAgMCAwIDEwLjQgNEg4YTIuNCAyLjQgMCAwIDAgLTIuNCAtMmgtLjJabS0uNCAyLjRhLjguOCAwIDAgMSAuOCAtLjhoLjJhLjguOCAwIDAgMSAuOC44VjRoLTEuOFYyLjRabTQgNEEuOC44IDAgMCAxIDkuOCA3LjJIMTAuNGEuOC44IDAgMCAxIC44Ljh2OGEuOC44IDAgMCAxIC0uOC44SDkuOGEuOC44IDAgMCAxIC0uOCAtLjhWNi40Wm0tLjggNmEuOC44IDAgMCAxIC0uOC44VjE0LjRhLjguOCAwIDAgMSAtLjggLjhoLS4yYS44LjggMCAwIDEgLS44IC0uOFYxMi40YS44LjggMCAwIDEgLjMyIC0uNjRMOS4yIDcuNzZWMTIuNFoiLz4KPC9zdmc+" width="30" height="30" class="d-inline-block align-top me-2" alt="OpenChain">
                OpenChain Explorer
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/blocks">Blocks</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/transactions">Transactions</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/contracts">Contracts</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/nodes">Nodes</a>
                    </li>
                </ul>
                <form class="d-flex ms-auto" id="searchForm">
                    <input class="form-control me-2" type="search" id="searchInput" placeholder="Search by Block / Tx Hash / Address" aria-label="Search">
                    <button class="btn btn-outline-light" type="submit">Search</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col-12">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Network Overview</h5>
                        <h6 class="card-subtitle mb-3 text-muted">Latest activity across the OpenChain network</h6>
                        <div class="row text-center">
                            <div class="col-md-3 mb-3">
                                <div class="stats-card p-3 rounded bg-light">
                                    <i class="bi bi-box"></i>
                                    <h2 id="totalBlocks">-</h2>
                                    <p class="mb-0">Total Blocks</p>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="stats-card p-3 rounded bg-light">
                                    <i class="bi bi-arrow-left-right"></i>
                                    <h2 id="totalTxs">-</h2>
                                    <p class="mb-0">Transactions</p>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="stats-card p-3 rounded bg-light">
                                    <i class="bi bi-file-earmark-code"></i>
                                    <h2 id="totalContracts">-</h2>
                                    <p class="mb-0">Smart Contracts</p>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="stats-card p-3 rounded bg-light">
                                    <i class="bi bi-hdd-network"></i>
                                    <h2 id="activeNodes">-</h2>
                                    <p class="mb-0">Active Nodes</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-12">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Network Activity</h5>
                        <div class="btn-group mb-3" role="group">
                            <button type="button" class="btn btn-outline-primary active timeframe-btn" data-value="24H">24H</button>
                            <button type="button" class="btn btn-outline-primary timeframe-btn" data-value="7D">7D</button>
                            <button type="button" class="btn btn-outline-primary timeframe-btn" data-value="30D">30D</button>
                        </div>
                        <div class="chart-container" style="position: relative; height:300px;">
                            <canvas id="activityChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="card-title mb-0">Latest Blocks</h5>
                            <a href="/blocks" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Block</th>
                                        <th>Age</th>
                                        <th>Txns</th>
                                        <th>Miner</th>
                                        <th>Hash</th>
                                    </tr>
                                </thead>
                                <tbody id="latestBlocks">
                                    <tr>
                                        <td colspan="5" class="text-center">Loading blocks...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="card-title mb-0">Latest Transactions</h5>
                            <a href="/transactions" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Tx Hash</th>
                                        <th>From</th>
                                        <th>To</th>
                                        <th>Amount</th>
                                        <th>Age</th>
                                    </tr>
                                </thead>
                                <tbody id="latestTransactions">
                                    <tr>
                                        <td colspan="5" class="text-center">Loading transactions...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <h5>OpenChain Explorer</h5>
                    <p>An advanced blockchain explorer for the OpenChain network. Real-time data, transactions, and analytics.</p>
                </div>
                <div class="col-md-3">
                    <h5>Resources</h5>
                    <ul class="list-unstyled">
                        <li><a href="#" class="text-white">Documentation</a></li>
                        <li><a href="#" class="text-white">API</a></li>
                        <li><a href="#" class="text-white">GitHub</a></li>
                    </ul>
                </div>
                <div class="col-md-3">
                    <h5>Network</h5>
                    <ul class="list-unstyled" id="peersList">
                        <li>Node 1: Connected</li>
                        <li>Node 2: Connected</li>
                        <li>Node 3: Connected</li>
                    </ul>
                </div>
            </div>
            <hr>
            <div class="text-center">
                <p class="mb-0">© 2025 OpenChain Explorer. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="app.js"></script>
</body>
</html>
EOF

# Create the CSS file
echo -e "${YELLOW}Creating CSS file...${NC}"
cat > public/styles.css << 'EOF'
/* Main Styles for OpenChain Explorer */
body {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    background-color: #f8f9fa;
}

.navbar {
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.navbar-brand img {
    margin-right: 8px;
}

footer {
    margin-top: auto;
}

/* Stats Cards */
.stats-card {
    transition: all 0.3s ease;
    border: 1px solid rgba(0,0,0,0.1);
}

.stats-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.stats-card h2 {
    font-size: 2rem;
    font-weight: 700;
    margin: 10px 0;
    color: #0d6efd;
}

.stats-card i {
    font-size: 1.5rem;
    color: #6c757d;
}

/* Tables */
.table th {
    border-top: none;
    font-weight: 600;
}

.table td {
    vertical-align: middle;
}

/* Hash Formatting */
.hash-cell {
    max-width: 150px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

/* Responsive Fixes */
@media (max-width: 768px) {
    .stats-card h2 {
        font-size: 1.5rem;
    }
    
    .table-responsive {
        overflow-x: auto;
    }
    
    .hash-cell {
        max-width: 100px;
    }
}

/* Chart Container */
.chart-container {
    margin: 15px 0;
}

/* Timeframe Buttons */
.timeframe-btn.active {
    background-color: #0d6efd;
    color: white;
}

/* Search Form */
#searchForm {
    min-width: 300px;
}

/* Loader Animation */
.loader {
    border: 5px solid #f3f3f3;
    border-top: 5px solid #0d6efd;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
    margin: 20px auto;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Transaction Status */
.tx-status {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.8rem;
    font-weight: 600;
}

.tx-status.confirmed {
    background-color: #d1e7dd;
    color: #0f5132;
}

.tx-status.pending {
    background-color: #fff3cd;
    color: #856404;
}

/* Block and Transaction Details */
.detail-card {
    margin-bottom: 20px;
}

.detail-card .card-header {
    font-weight: 600;
}

.detail-item {
    display: flex;
    border-bottom: 1px solid rgba(0,0,0,0.1);
    padding: 10px 0;
}

.detail-item:last-child {
    border-bottom: none;
}

.detail-label {
    font-weight: 600;
    width: 150px;
}

.detail-value {
    flex: 1;
    word-break: break-all;
}

/* Node Status Indicator */
.node-status {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    display: inline-block;
    margin-right: 5px;
}

.node-status.active {
    background-color: #28a745;
}

.node-status.inactive {
    background-color: #dc3545;
}

/* Custom Bootstrap Card Shadows */
.card {
    border: none;
    transition: all 0.3s ease;
}

.card:hover {
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

/* Custom Alert Styles */
.custom-alert {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
    max-width: 350px;
}
EOF

# Create the JavaScript file
echo -e "${YELLOW}Creating JavaScript file...${NC}"
cat > public/app.js << 'EOF'
// OpenChain Explorer Frontend JS
document.addEventListener('DOMContentLoaded', function() {
    // Initialize dashboard
    fetchNetworkInfo();
    fetchLatestBlocks();
    fetchLatestTransactions();
    initActivityChart();
    
    // Set up search form
    const searchForm = document.getElementById('searchForm');
    if (searchForm) {
        searchForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const searchInput = document.getElementById('searchInput').value.trim();
            if (searchInput) {
                handleSearch(searchInput);
            }
        });
    }
    
    // Set up timeframe buttons
    const timeframeButtons = document.querySelectorAll('.timeframe-btn');
    if (timeframeButtons.length) {
        timeframeButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                timeframeButtons.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                updateActivityChart(this.getAttribute('data-value'));
            });
        });
    }
});

// Fetch network overview information
async function fetchNetworkInfo() {
    try {
        const response = await fetch('/info');
        const data = await response.json();
        
        document.getElementById('totalBlocks').textContent = data.blocks || 0;
        document.getElementById('totalTxs').textContent = data.transactions || 0;
        document.getElementById('totalContracts').textContent = Object.keys(data.contracts || {}).length || 0;
        document.getElementById('activeNodes').textContent = data.peers || 0;
        
    } catch (error) {
        console.error('Error fetching network info:', error);
        showAlert('Error loading network information', 'danger');
    }
}

// Fetch latest blocks
async function fetchLatestBlocks() {
    try {
        const response = await fetch('/blocks?limit=5');
        const blocks = await response.json();
        
        const blocksTable = document.getElementById('latestBlocks');
        if (blocksTable) {
            blocksTable.innerHTML = '';
            
            if (blocks.length === 0) {
                blocksTable.innerHTML = '<tr><td colspan="5" class="text-center">No blocks found</td></tr>';
                return;
            }
            
            blocks.forEach(block => {
                const row = document.createElement('tr');
                
                const heightCell = document.createElement('td');
                const heightLink = document.createElement('a');
                heightLink.href = `/block/${block.height}`;
                heightLink.textContent = block.height;
                heightCell.appendChild(heightLink);
                
                const ageCell = document.createElement('td');
                ageCell.textContent = formatTimeAgo(block.timestamp);
                
                const txnsCell = document.createElement('td');
                txnsCell.textContent = block.transactions.length;
                
                const minerCell = document.createElement('td');
                const minerAddress = block.transactions[0]?.toAddress || '---';
                const minerLink = document.createElement('a');
                minerLink.href = `/address/${minerAddress}`;
                minerLink.className = 'hash-cell';
                minerLink.textContent = formatAddress(minerAddress);
                minerCell.appendChild(minerLink);
                
                const hashCell = document.createElement('td');
                const hashLink = document.createElement('a');
                hashLink.href = `/block/${block.hash}`;
                hashLink.className = 'hash-cell';
                hashLink.textContent = formatAddress(block.hash);
                hashCell.appendChild(hashLink);
                
                row.appendChild(heightCell);
                row.appendChild(ageCell);
                row.appendChild(txnsCell);
                row.appendChild(minerCell);
                row.appendChild(hashCell);
                
                blocksTable.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Error fetching latest blocks:', error);
        document.getElementById('latestBlocks').innerHTML = 
            '<tr><td colspan="5" class="text-center text-danger">Error loading blocks</td></tr>';
    }
}

// Fetch latest transactions
async function fetchLatestTransactions() {
    try {
        const response = await fetch('/transactions?limit=5');
        const transactions = await response.json();
        
        const txTable = document.getElementById('latestTransactions');
        if (txTable) {
            txTable.innerHTML = '';
            
            if (transactions.length === 0) {
                txTable.innerHTML = '<tr><td colspan="5" class="text-center">No transactions found</td></tr>';
                return;
            }
            
            transactions.forEach(tx => {
                const row = document.createElement('tr');
                
                const hashCell = document.createElement('td');
                const hashLink = document.createElement('a');
                hashLink.href = `/transaction/${tx.id}`;
                hashLink.className = 'hash-cell';
                hashLink.textContent = formatAddress(tx.id);
                hashCell.appendChild(hashLink);
                
                const fromCell = document.createElement('td');
                if (tx.fromAddress) {
                    const fromLink = document.createElement('a');
                    fromLink.href = `/address/${tx.fromAddress}`;
                    fromLink.className = 'hash-cell';
                    fromLink.textContent = formatAddress(tx.fromAddress);
                    fromCell.appendChild(fromLink);
                } else {
                    fromCell.textContent = 'System';
                    fromCell.className = 'text-muted';
                }
                
                const toCell = document.createElement('td');
                const toLink = document.createElement('a');
                toLink.href = `/address/${tx.toAddress}`;
                toLink.className = 'hash-cell';
                toLink.textContent = formatAddress(tx.toAddress);
                toCell.appendChild(toLink);
                
                const amountCell = document.createElement('td');
                amountCell.textContent = tx.amount.toFixed(2);
                
                const ageCell = document.createElement('td');
                ageCell.textContent = formatTimeAgo(tx.timestamp);
                
                row.appendChild(hashCell);
                row.appendChild(fromCell);
                row.appendChild(toCell);
                row.appendChild(amountCell);
                row.appendChild(ageCell);
                
                txTable.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Error fetching latest transactions:', error);
        document.getElementById('latestTransactions').innerHTML = 
            '<tr><td colspan="5" class="text-center text-danger">Error loading transactions</td></tr>';
    }
}

// Initialize activity chart
function initActivityChart() {
    const ctx = document.getElementById('activityChart');
    if (!ctx) return;
    
    // Generate random data for the chart
    const days = 30;
    const blockData = Array.from({ length: days }, () => Math.floor(Math.random() * 20) + 5);
    const txData = Array.from({ length: days }, () => Math.floor(Math.random() * 40) + 20);
    
    const labels = Array.from({ length: days }, (_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - (days - 1) + i);
        return `${date.getMonth() + 1}/${date.getDate()}`;
    });
    
    window.activityChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Blocks',
                    data: blockData,
                    borderColor: 'rgba(13, 110, 253, 0.8)',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Transactions',
                    data: txData,
                    borderColor: 'rgba(25, 135, 84, 0.8)',
                    backgroundColor: 'rgba(25, 135, 84, 0.1)',
                    tension: 0.4,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false,
            },
            plugins: {
                legend: {
                    position: 'top',
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

// Update chart based on selected timeframe
function updateActivityChart(timeframe) {
    if (!window.activityChart) return;
    
    let days;
    switch (timeframe) {
        case '24H':
            days = 1;
            break;
        case '7D':
            days = 7;
            break;
        case '30D':
        default:
            days = 30;
            break;
    }
    
    // Generate new random data
    const blockData = Array.from({ length: days }, () => Math.floor(Math.random() * 20) + 5);
    const txData = Array.from({ length: days }, () => Math.floor(Math.random() * 40) + 20);
    
    // Generate labels based on timeframe
    let labels;
    if (days === 1) {
        // Hours for 24H view
        labels = Array.from({ length: 24 }, (_, i) => `${i}:00`);
        
        // More data points for 24h view
        blockData.length = 24;
        txData.length = 24;
        
        // Regenerate data
        for (let i = 0; i < 24; i++) {
            blockData[i] = Math.floor(Math.random() * 5) + 1;
            txData[i] = Math.floor(Math.random() * 15) + 5;
        }
    } else {
        // Days for 7D and 30D views
        labels = Array.from({ length: days }, (_, i) => {
            const date = new Date();
            date.setDate(date.getDate() - (days - 1) + i);
            return `${date.getMonth() + 1}/${date.getDate()}`;
        });
    }
    
    window.activityChart.data.labels = labels;
    window.activityChart.data.datasets[0].data = blockData;
    window.activityChart.data.datasets[1].data = txData;
    window.activityChart.update();
}

// Handle search
function handleSearch(query) {
    // Determine what type of search it is
    if (/^\d+$/.test(query)) {
        // Looks like a block number
        window.location.href = `/block/${query}`;
    } else if (query.length === 64 || query.length === 66) {
        // Likely a transaction hash or block hash (full length)
        window.location.href = `/transaction/${query}`;
    } else if (query.length >= 40) {
        // Likely an address
        window.location.href = `/address/${query}`;
    } else {
        // Try block search as default
        window.location.href = `/block/${query}`;
    }
}

// Helper function to format time ago
function formatTimeAgo(timestamp) {
    const now = Date.now();
    const diff = now - timestamp;
    
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    
    if (days > 0) {
        return `${days} day${days > 1 ? 's' : ''} ago`;
    } else if (hours > 0) {
        return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else if (minutes > 0) {
        return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else {
        return `${seconds} second${seconds !== 1 ? 's' : ''} ago`;
    }
}

// Helper function to format addresses
function formatAddress(address) {
    if (!address) return '---';
    if (address.length <= 12) return address;
    return `${address.substring(0, 6)}...${address.substring(address.length - 6)}`;
}

// Show alert
function showAlert(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show custom-alert`;
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    setTimeout(() => {
        alertDiv.classList.add('show');
        setTimeout(() => {
            alertDiv.classList.remove('show');
            setTimeout(() => alertDiv.remove(), 300);
        }, 5000);
    }, 100);
}
EOF

# Update the server.js file to add routes
echo -e "${YELLOW}Updating server.js file with routes...${NC}"

# Check if routes already exist
if ! grep -q "app.get('/'," server.js; then
    # Add routes before app.listen
    sed -i '/app.listen/i \
// Serve the SPA for all frontend routes\
app.get(\'/\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/blocks\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/block/:id\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/transactions\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/transaction/:id\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/address/:address\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/contracts\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
\
app.get(\'/nodes\', (req, res) => {\
    res.sendFile(path.join(__dirname, \'public\', \'index.html\'));\
});\
' server.js
fi

# Restart the service
echo -e "${YELLOW}Restarting the OpenChain Explorer service...${NC}"
systemctl restart openchain-explorer

# Verify the status
echo -e "${YELLOW}Checking service status...${NC}"
systemctl status openchain-explorer --no-pager

echo -e "${GREEN}Repair complete! The OpenChain Explorer should now be working properly.${NC}"
echo -e "${GREEN}Access the explorer at http://$(curl -s ifconfig.me)${NC}" 