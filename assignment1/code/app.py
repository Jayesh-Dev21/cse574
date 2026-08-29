from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv
import socket
import datetime
import boto3
import requests
import os
from urllib.parse import unquote

load_dotenv()
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/working')
def working():
    hostname = socket.gethostname()
    try:
        external_ip = socket.gethostbyname(hostname)
    except Exception:
        external_ip = "Unable to resolve"

    details = {
        'student_name': 'Jayesh Krishan Puri',
        'student_id': '24155058',
        'hostname': hostname,
        'external_url': f"http://{external_ip}",
        'ip_address': external_ip,
        'timestamp': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'status': 'Deployed and Running on AWS EC2',
        'framework': 'Flask + Nginx',
        'cloud_provider': 'AWS EC2 (Ubuntu)'
    }
    return render_template('working.html', details=details)

S3_BUCKET = os.getenv('S3_BUCKET')
S3_ACCESS_POINT = os.getenv('S3_ACCESS_POINT')
S3_REGION = os.getenv('S3_REGION')

s3_client = boto3.client('s3', region_name=S3_REGION)

@app.route('/download_to_s3', methods=['POST'])
def download_to_s3():
    data = request.get_json()
    url = data.get('url', '').strip()
    if not url:
        return jsonify({'error': 'No URL provided'}), 400

    try:
        filename = unquote(url.split('/')[-1].split('?')[0])
        if not filename:
            filename = 'document.pdf'

        response = requests.get(url, timeout=30)
        response.raise_for_status()

        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=filename,
            Body=response.content,
            ContentType=response.headers.get('Content-Type', 'application/octet-stream')
        )

        s3_url = f"https://{S3_ACCESS_POINT}.s3-accesspoint.{S3_REGION}.amazonaws.com/{filename}"
        return jsonify({'success': True, 's3_url': s3_url, 'filename': filename})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
