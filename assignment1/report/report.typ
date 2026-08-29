#set page(
  paper: "a4",
  margin: (top: 1.6cm, bottom: 1.6cm, left: 2.2cm, right: 2.2cm),
  numbering: "1",
)

#set text(font: "Liberation Serif", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#set figure(gap: 4pt)
#show figure.caption: set text(size: 9pt)

// Title
#align(center)[
  #text(size: 13pt, weight: "bold")[CSE574: Cloud Computing] \
  #v(2pt)
  #text(size: 11pt)[Indian Institute of Technology (BHU) Varanasi] \
  #v(6pt)
  #text(size: 12pt, weight: "bold")[Assignment 1: Deploying a Web Application on AWS EC2] \
  #v(4pt)
  #text(size: 11pt)[Instructor: Dr. Prasenjit Chanak] \
  #v(8pt)
  #table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 4pt, y: 3pt),
    align: left,
    [*Name:*], [Jayesh Krishan Puri],
    [*Branch:*], [Mining Engineering, 3rd Year B.Tech],
    [*Roll No:*], [24155058],
    [*Date:*], [29 August 2026],
    [*GitHub*], [https://github.com/Jayesh-Dev21],
  )
]

#line(length: 100%)
#v(4pt)

= Cloud Platform and VM Setup

An AWS account was created and an *EC2 instance* was launched on *Amazon Web Services (AWS)* to serve as the cloud VM for deploying the web application. The instance was configured with Ubuntu Server and accessed via SSH using a key pair.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: (x: 6pt, y: 5pt),
  [*Cloud Provider*], [Amazon Web Services (AWS)],
  [*Service*], [EC2 (Elastic Compute Cloud)],
  [*OS (Guest)*], [Ubuntu Server (latest LTS)],
  [*Instance Type*], [t2.micro (Free Tier eligible)],
  [*Region*], [ap-south-1 (Mumbai)],
  [*Key Pair*], [pair.pem (SSH authentication)],
  [*Security Group*], [SSH (22), HTTP (80), HTTPS (443)],
)

#figure(
  image("../screenshots/01_aws_console.png", width: 80%),
  caption: [AWS Management Console -- EC2 dashboard],
)

= SSH and Instance Configuration

=== Step 1: Key Pair and SSH Setup

A key pair (.pem file) was downloaded during instance creation. SSH was configured to connect to the EC2 instance using the private key.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/02_key_pair.png", width: 100%), caption: [Key pair download]),
  figure(image("../screenshots/03_instance_config.png", width: 100%), caption: [Instance launch configuration]),
)

=== Step 2: SSH Connection and Verification

The EC2 instance was accessed via SSH from the local terminal using the downloaded key pair. The instance state confirmed it was running successfully.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/04_instance_running.png", width: 100%), caption: [Instance state -- running]),
  figure(image("../screenshots/05_ssh_connected.png", width: 100%), caption: [SSH connection established]),
)

=== Step 3: System Update and Package Installation

After connecting, the system packages were updated and essential software was installed including *nginx*, *curl*, *git*, *Python3*, and the *AWS CLI*.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/06_system_update.png", width: 100%), caption: [System update and package install]),
  figure(image("../screenshots/07_packages_installed.png", width: 100%), caption: [Nginx, curl, git, AWS CLI installed]),
)

= Deploying the Flask Application

=== Step 4: Transferring Code to the EC2 Instance

The Flask application code was transferred from the local machine to the EC2 instance using `scp` (secure copy).

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/08_scp_transfer.png", width: 100%), caption: [scp transfer of application code]),
  figure(image("../screenshots/09_files_received.png", width: 100%), caption: [Files received on EC2]),
)

=== Step 5: Flask App Deployment

The Flask application was deployed on the EC2 instance using *Gunicorn* as the WSGI server. The app was configured to listen on `0.0.0.0:5000` and was managed using a *systemd* service for automatic restarts.

#figure(
  image("../screenshots/10_flask_deployed.png", width: 80%),
  caption: [Flask application deployed on EC2],
)

=== Step 6: Running Application

The Flask application was started and verified to be running correctly on the EC2 instance.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/11_flask_running.png", width: 100%), caption: [Flask app running on port 5000]),
  figure(image("../screenshots/12_doc_viewer.png", width: 100%), caption: [Document viewer page loaded]),
)

= Application Endpoints

The web application provides two main endpoints:

- `/` -- A document viewer page with a URL input field to view documents (PDFs, Google Docs, etc.) directly in the browser, along with a "Download to S3" button.
- `/working` -- A deployment status page displaying the student details, external URL, IP address, hostname, cloud provider, framework, and server timestamp.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/13_doc_loaded.png", width: 100%), caption: [Document loaded in viewer]),
  figure(image("../screenshots/14_scripts_working.png", width: 100%), caption: [Deploy and stop scripts working]),
)

= Nginx Configuration

Nginx was configured as a reverse proxy to forward requests from port 80 to the Gunicorn server running on port 5000. The configuration was placed in `/etc/nginx/sites-available/flask_app` and symlinked to `sites-enabled`.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: (x: 6pt, y: 5pt),
  [*Framework*], [Flask (Python)],
  [*WSGI Server*], [Gunicorn (3 workers)],
  [*Web Server*], [Nginx (reverse proxy, port 80)],
  [*App Port*], [5000],
  [*Process Manager*], [systemd (flask_app.service)],
)

= AWS S3 Integration

=== Step 7: S3 Bucket Creation

An S3 bucket named `docustore-cse574` was created in the `ap-south-1` (Mumbai) region for storing documents. An S3 Access Point was also configured for the bucket.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/15_s3_bucket.png", width: 100%), caption: [S3 bucket created]),
  figure(image("../screenshots/16_s3_versioning.png", width: 100%), caption: [Bucket versioning enabled]),
)

=== Step 8: S3 Upload via boto3 SDK

The application uses *boto3*, the AWS SDK for Python, to upload documents to S3. When a user enters a document URL and clicks "Download to S3", the application fetches the document and uploads it to the bucket using `put_object`.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/19_sdk_upload.png", width: 100%), caption: [Upload via SDK -- any PDF from URL]),
  figure(image("../screenshots/20_sdk_files.png", width: 100%), caption: [All files visible in S3 bucket]),
)

=== Step 9: Cross-Verification

The uploaded documents were verified by viewing them from the S3 bucket through the application's document viewer, confirming end-to-end functionality.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/17_s3_viewed.png", width: 100%), caption: [S3 stored document viewed in app]),
  figure(image("../screenshots/18_cross_verified.png", width: 100%), caption: [Assignment 2 report viewed on Assignment 1 app]),
)

= Challenges Faced

The primary challenge was *AWS credential configuration*. The initial deployment encountered an `Unable to locate credentials` error, which was resolved by running `aws configure` on the EC2 instance. Subsequently, an `AccessDenied` error appeared because the IAM user lacked `s3:PutObject` permissions on the target bucket. This was fixed by attaching the `AmazonS3FullAccess` policy to the IAM user through the AWS IAM console.

= Deployment Verification

The application was verified by accessing both endpoints on the EC2 public IP:

- `http://<EC2_IP>/` -- The document viewer page loaded successfully with the URL input field and Load / Download to S3 buttons.
- `http://<EC2_IP>/working` -- The deployment status page displayed the correct student details (Jayesh Krishan Puri, 24155058), external URL, IP address, hostname, and server timestamp.

The Flask application runs under *systemd* (`flask_app.service`) with Gunicorn serving 3 worker processes, and Nginx proxying traffic on port 80.

= Service URLs and Current Status

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: (x: 6pt, y: 5pt),
  [*App URL*], [`http://<EC2_IP>/` (now stopped)],
  [*Status Page*], [`http://<EC2_IP>/working` (now stopped)],
  [*S3 Bucket*], [`s3://docustore-cse574`],
  [*S3 Access Point*], [`assignment-suyan8hc8ibfazmowpudzcio5uhwnaps3a-s3alias`],
  [*S3 Region*], [`ap-south-1` (Mumbai)],
)

*Note:* The EC2 instance and Flask service have been *stopped* after successful verification to avoid unnecessary compute charges on the AWS Free Tier. The S3 bucket `docustore-cse574` remains active and all uploaded documents are intact.

= Source Code

The complete source code for this assignment is available at:

#align(center)[
  #text(size: 10pt)[`https://github.com/Jayesh-Dev21/cse574`]
]

#v(20pt)
#line(length: 100%)
#align(center)[
  #text(size: 9pt, fill: luma(100))[CSE574: Cloud Computing | IIT (BHU) Varanasi | 29 August 2026]
]
