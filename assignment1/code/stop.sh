#!/bin/bash
# Stop Flask app and nginx

echo "Stopping Flask app..."
sudo systemctl stop flask_app

echo "Stopping nginx..."
sudo systemctl stop nginx

echo "Done. Both services stopped."
