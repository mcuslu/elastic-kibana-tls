#!/bin/bash

set -e

echo "Starting Elasticsearch + Kibana + TLS installation..."

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y apt-transport-https ca-certificates wget curl gnupg lsb-release unzip

# Import Elastic GPG key
echo "Adding Elastic GPG key..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg

# Add Elastic APT repository
echo "Adding Elasticsearch APT repository..."
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Update package index
sudo apt update

# Install Elasticsearch
echo "Installing Elasticsearch..."
sudo apt install -y elasticsearch

# Enable and start Elasticsearch
echo "Starting Elasticsearch service..."
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Info about auto-generated TLS certs
echo ""
echo "Elasticsearch has generated TLS certificates automatically."
echo "Certificates directory: /etc/elasticsearch/certs/"
echo ""

# Reset password for elastic user (automatically)
echo "Resetting password for 'elastic' user..."
ELASTIC_PASS=$(sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b)
echo ""
echo "New elastic user password: $ELASTIC_PASS"
echo ""

# Install Kibana
echo "Installing Kibana..."
sudo apt install -y kibana

# Configure Kibana
echo "⚙Configuring Kibana..."

sudo tee /etc/kibana/kibana.yml > /dev/null <<EOF
server.port: 5601
server.host: "0.0.0.0"

elasticsearch.hosts: ["https://localhost:9200"]
elasticsearch.username: "elastic"
elasticsearch.password: "$ELASTIC_PASS"

elasticsearch.ssl.certificateAuthorities: ["/etc/elasticsearch/certs/http_ca.crt"]
elasticsearch.ssl.verificationMode: certificate

# To enable TLS for Kibana itself, uncomment and configure the lines below:
# server.ssl.enabled: true
# server.ssl.certificate: "/etc/kibana/certs/kibana.crt"
# server.ssl.key: "/etc/kibana/certs/kibana.key"
EOF

# Enable and start Kibana
echo "Starting Kibana service..."
sudo systemctl enable kibana
sudo systemctl start kibana

# Allow port 5601 (if using UFW)
sudo ufw allow 5601

# complete info
echo ""
echo "Elasticsearch + Kibana + TLS setup completed."
echo ""
echo "Access Kibana from your browser:"
echo "   http://<your-server-ip>:5601"
echo ""
echo "Login with:"
echo "   Username: elastic"
echo "   Password: $ELASTIC_PASS"
echo ""
echo "Elasticsearch is accessible at: https://localhost:9200"
echo "TLS CA file: /etc/elasticsearch/certs/http_ca.crt"
echo ""
