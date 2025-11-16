🚀 MySQL Master–Slave Replication on AWS EC2 using Terraform

Fully automated deployment of MySQL Master–Slave replication on Amazon Linux 2023 using Terraform + GTID-based replication via Percona XtraBackup.

Note: Percona Server Pro requires a license key.
For community/hobby/demo use, you may switch to:

Oracle MySQL Community Edition

Percona Server Community Edition (ps80)

📘 Project Overview

This project automates:

✔ AWS VPC creation
✔ Public subnet, IGW, Route Tables
✔ Security groups for SSH + MySQL
✔ EC2 Master & Slave via a reusable Terraform module
✔ Additional EBS volume for /var/lib/mysql
✔ Installation of MySQL (Percona or Oracle)
✔ GTID-based Master/Slave replication
✔ Base-backup from Master to Slave using Percona XtraBackup

No snapshots are used — backup from scratch (clean MYSQL directory).

🏗️ Terraform Architecture
project/
├── backend-setup.tf        # S3 + DynamoDB backend
├── main.tf                 # VPC + EC2 infra
├── variables.tf
├── terraform.tfvars
├── output.tf
└── modules/
    └── ec2_instance/
        ├── main.tf
        ├── variables.tf
        └── output.tf

🌐 AWS Resources Created
Component	Purpose
VPC (10.0.0.0/16)	Isolated private network
Public Subnet (10.0.1.0/24)	For EC2 instances
Internet Gateway	Public network access
Route Table	Default 0.0.0.0/0 routing
Security Group	SSH (22), MySQL (3306)
EC2 Master	MySQL master node
EC2 Slave	MySQL replica
EBS Volume (10GB)	Dedicated storage for MySQL
⚙️ Terraform Usage
1️⃣ Initialize Backend (first time only)
terraform init
terraform apply -target=aws_s3_bucket.tf_state -target=aws_dynamodb_table.tf_lock

2️⃣ Deploy complete infrastructure
terraform init
terraform apply

Outputs include:

Master EC2 Public & Private IP

Slave EC2 Public & Private IP

SSH Keypair info

🐬 MySQL Installation (Master & Slave)
If using Percona Server Pro (requires license):
sudo percona-release enable ps80 release
sudo dnf install percona-server-server-pro -y


Enable Percona XtraBackup Pro:

percona-release enable pxb-80-pro --user_name=<username> --repo_token=<token>
dnf install percona-xtrabackup-pro-80

If using Percona Server Community (recommended for demo):
sudo percona-release enable ps-80 release
sudo dnf install percona-server* -y
sudo dnf install percona-xtrabackup-80 -y

Enable MySQL
sudo systemctl enable mysqld
sudo systemctl start mysqld

💽 Mount EBS Volume to /var/lib/mysql
sudo mkfs.xfs /dev/nvme1n1
sudo mkdir -p /var/lib/mysql
sudo mount /dev/nvme1n1 /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql


Add to /etc/fstab:

/dev/nvme1n1  /var/lib/mysql  xfs  defaults,noatime  0 0

📘 MySQL Master Configuration

Edit /etc/my.cnf:

server-id=1
log_bin=/var/lib/mysql/mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
log_replica_updates=ON
binlog_row_image=FULL


Restart MySQL:

sudo systemctl restart mysqld

Create replication user
CREATE USER 'repl'@'10.0.1.%'
IDENTIFIED WITH mysql_native_password BY 'yourpass';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.0.1.%';

FLUSH PRIVILEGES;

📦 Full Backup (Master) Using XtraBackup
mkdir -p /backup/full
xtrabackup --backup --target-dir=/backup/full
xtrabackup --prepare --target-dir=/backup/full

🔁 Transfer Backup to Slave
rsync -avz -e "ssh -i privatekey-of-ec2-user" /backup/full/ ec2-user@<SLAVE-IP>:/tmp/full/

📥 Restore Backup on Slave

Stop MySQL & clean directory:

sudo systemctl stop mysqld
sudo rm -rf /var/lib/mysql/*


Restore backup:

xtrabackup --copy-back --target-dir=/tmp/full
sudo chown -R mysql:mysql /var/lib/mysql

🐬 MySQL Slave Configuration

Edit /etc/my.cnf:

server-id=2
gtid_mode=ON
enforce_gtid_consistency=ON
log_replica_updates=ON
binlog_format=ROW


Restart:

sudo systemctl restart mysqld

🧩 Important GTID Step

Check GTID mode:

SHOW VARIABLES LIKE 'gtid_mode';


Check backup GTID:

cat /var/lib/mysql/xtrabackup_binlog_info


Set GTID_PURGED:

SET GLOBAL gtid_purged='f011681c-c2c5-11f0-8313-02f8b0a6201b:1-3';

🔗 Configure GTID Replication on Slave
STOP REPLICA;

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='10.0.1.202',
  SOURCE_USER='repl',
  SOURCE_PASSWORD='yourpass',
  SOURCE_PORT=3306,
  SOURCE_AUTO_POSITION=1;

START REPLICA;

📊 Check Replication Status
SHOW REPLICA STATUS\G;


Expected:

Replica_IO_Running: Yes
Replica_SQL_Running: Yes
Seconds_Behind_Source: 0

🧪 Test Replication
On Master:
CREATE DATABASE testdb;
CREATE TABLE testdb.emp(id INT);
INSERT INTO testdb.emp VALUES (1);

On Slave:
SELECT * FROM testdb.emp;


If rows appear → Replication SUCCESSFUL 🎉

📌 Notes & Best Practices

✔ Keep 20–25% free disk space
✔ Increase binlog retention during backup
✔ For large databases (TB-scale):

use gp3 (600–1000 MB/s)

parallel rsync
✔ Always use GTID-based replication for easy recovery
✔ Take regular incremental backups via XtraBackup

🎯 Conclusion

This repo demonstrates:

✔ Automated AWS infra creation via Terraform
✔ MySQL installation on AL2023
✔ Zero-snapshot backup-based replication
✔ GTID auto-position sync
✔ Fully reproducible environment for learning or PoC