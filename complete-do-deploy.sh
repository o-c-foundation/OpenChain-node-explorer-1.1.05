#!/bin/bash

# Complete Digital Ocean Ubuntu Deployment Script for OpenChain Explorer Node
# This script will set up the 4th node with the advanced explorer

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting OpenChain Node Explorer deployment on Ubuntu...${NC}"

# Update system and install dependencies
echo -e "${YELLOW}Updating system and installing dependencies...${NC}"
apt-get update
apt-get upgrade -y
apt-get install -y git nodejs npm nginx curl

# Install Node.js 16.x if needed
NODE_VERSION=$(node -v)
if [[ ! $NODE_VERSION =~ ^v16 ]]; then
  echo -e "${YELLOW}Upgrading Node.js to v16.x...${NC}"
  curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
  apt-get install -y nodejs
fi

# Clone the repository
echo -e "${YELLOW}Cloning OpenChain Explorer repository...${NC}"
cd /opt
git clone https://github.com/o-c-foundation/OpenChain-node-explorer-1.1.05.git
cd OpenChain-node-explorer-1.1.05

# Install dependencies
echo -e "${YELLOW}Installing Node.js dependencies...${NC}"
npm install express ws axios cors dotenv

# Create config file
echo -e "${YELLOW}Creating configuration file for node connections...${NC}"
cat > config.json << EOF
{
  "nodeId": "node4",
  "port": 3000,
  "hostname": "0.0.0.0",
  "peers": [
    { "url": "ws://NODE1_IP:3000", "name": "Node 1" },
    { "url": "ws://NODE2_IP:3000", "name": "Node 2" },
    { "url": "ws://NODE3_IP:3000", "name": "Node 3" }
  ],
  "explorer": {
    "enabled": true,
    "updateInterval": 10000
  }
}
EOF

echo -e "${YELLOW}Please edit config.json and replace NODE1_IP, NODE2_IP, and NODE3_IP with the actual IP addresses of your nodes${NC}"

# Create systemd service
echo -e "${YELLOW}Creating systemd service for OpenChain Explorer...${NC}"
cat > /etc/systemd/system/openchain-explorer.service << EOF
[Unit]
Description=OpenChain Node Explorer
After=network.target

[Service]
User=root
WorkingDirectory=/opt/OpenChain-node-explorer-1.1.05
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=openchain-explorer

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
echo -e "${YELLOW}Configuring Nginx as reverse proxy...${NC}"
cat > /etc/nginx/sites-available/openchain-explorer << EOF
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/openchain-explorer /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start services
echo -e "${YELLOW}Starting services...${NC}"
systemctl daemon-reload
systemctl enable openchain-explorer
systemctl start openchain-explorer
systemctl restart nginx

# Get server IP for final instructions
SERVER_IP=$(curl -s ifconfig.me)

echo -e "${GREEN}===================================================${NC}"
echo -e "${GREEN}OpenChain Node Explorer has been deployed!${NC}"
echo -e "${GREEN}===================================================${NC}"
echo -e "${YELLOW}Before starting the service:${NC}"
echo -e "1. Edit /opt/OpenChain-node-explorer-1.1.05/config.json"
echo -e "2. Replace NODE1_IP, NODE2_IP, and NODE3_IP with your actual node IPs"
echo -e "${YELLOW}Then restart the service:${NC}"
echo -e "   systemctl restart openchain-explorer"
echo -e "${YELLOW}Access your explorer at:${NC}"
echo -e "   http://$SERVER_IP"
echo -e "${GREEN}===================================================${NC}" 