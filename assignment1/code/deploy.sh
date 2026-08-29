#!/bin/bash
# Deployment script - run on your EC2 instance
# Usage: bash deploy.sh

set -e

echo "=== Cloud Computing Assignment - Deployment ==="

# Install Python & dependencies
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv nginx

# Create project directory
mkdir -p ~/flask_app/templates
mkdir -p ~/flask_app/static

# Copy files (assuming you scp'd them)
cp app.py ~/flask_app/
cp requirements.txt ~/flask_app/
cp templates/*.html ~/flask_app/templates/

# Setup virtual environment
cd ~/flask_app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service
sudo tee /etc/systemd/system/flask_app.service > /dev/null <<EOF
[Unit]
Description=Flask Web Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask_app
ExecStart=/home/ubuntu/flask_app/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Flask app
sudo systemctl daemon-reload
sudo systemctl start flask_app
sudo systemctl enable flask_app

# Configure Nginx
sudo tee /etc/nginx/sites-available/flask_app > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "=== Done! ==="
echo "Visit: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "  / - Document Viewer"
echo "  /working - Deployment Status"
