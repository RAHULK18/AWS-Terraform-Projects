🚀 MySQL Master–Slave Replication on AWS EC2 using Terraform

Fully automated deployment of MySQL Master–Slave replication on Amazon Linux 2023 using Terraform, GTID-based replication, and Percona XtraBackup (no snapshots used).

```bash
⚠️ Note: Percona Server Pro requires a license key. For community/demo setups, use:

Oracle MySQL Community Edition, or

Percona Server Community Edition (ps80)


📘 Project Overview

This project automates:

✔ AWS VPC & Networking
✔ EC2 Master and Slave (via module)
✔ EBS data disk
✔ MySQL installation
✔ GTID-based replication
✔ Backup import using Percona XtraBackup

🏗️ Terraform Architecture
project/
├── backend-setup.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
├── output.tf
└── modules/
    └── ec2_instance/
         ├── main.tf
         ├── variables.tf
         └── output.tf

🌐 AWS Resources Created

VPC 10.0.0.0/16

Subnet 10.0.1.0/24

IGW + Route Table

Security Group (22, 3306)

Key Pair

EC2 Master + EC2 Slave

EBS 10GB gp3 → /var/lib/mysql

⚙️ Terraform Usage
1️⃣ Initialize backend (first time)
terraform init
terraform apply -target=aws_s3_bucket.tf_state -target=aws_dynamodb_table.tf_lock

2️⃣ Deploy infrastructure
terraform init
terraform apply

🐬 MySQL Installation (Master & Slave)
Option A: Percona Server Pro (requires subscription)
sudo percona-release enable ps80 release
sudo dnf install percona-server-server-pro -y


Enable XtraBackup-Pro:

percona-release enable pxb-80-pro --user_name=<username> --repo_token=<token>
sudo dnf install percona-xtrabackup-pro-80 -y

Option B: Percona Server Community Edition (recommended)
sudo percona-release enable ps-80 release
sudo dnf install percona-server-server -y
sudo dnf install percona-xtrabackup-80 -y

Enable MySQL
sudo systemctl enable mysqld
sudo systemctl start mysqld

💽 Mount EBS Volume to /var/lib/mysql
sudo mkfs.xfs /dev/nvme1n1
sudo mkdir -p /var/lib/mysql
sudo mount /dev/nvme1n1 /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql


Update fstab:

echo "/dev/nvme1n1 /var/lib/mysql xfs defaults,noatime 0 0" | sudo tee -a /etc/fstab

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

Create Replication User
CREATE USER 'repl'@'10.0.1.%'
IDENTIFIED WITH mysql_native_password BY 'yourpass';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.0.1.%';

FLUSH PRIVILEGES;

📦 Backup Master Using XtraBackup
mkdir -p /backup/full
xtrabackup --backup --target-dir=/backup/full
xtrabackup --prepare --target-dir=/backup/full

🔁 Transfer Backup to Slave
rsync -avz -e "ssh -i private-key.pem" /backup/full/ ec2-user@<SLAVE-IP>:/tmp/full/

📥 Restore Backup on Slave

Stop MySQL + clean datadir:

sudo systemctl stop mysqld
sudo rm -rf /var/lib/mysql/*


Restore:

xtrabackup --copy-back --target-dir=/tmp/full
sudo chown -R mysql:mysql /var/lib/mysql

🐬 Slave MySQL Configuration

Edit /etc/my.cnf:

server-id=2
gtid_mode=ON
enforce_gtid_consistency=ON
log_replica_updates=ON
binlog_format=ROW


Restart:

sudo systemctl restart mysqld

🧩 GTID Initialization

Check backup GTID:

cat /var/lib/mysql/xtrabackup_binlog_info


Example output:

f011681c-c2c5-11f0-8313-02f8b0a6201b:1-3


Apply GTID_PURGED:

SET GLOBAL gtid_purged='f011681c-c2c5-11f0-8313-02f8b0a6201b:1-3';

🔗 Configure Replication on Slave
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

Master:

CREATE DATABASE testdb;
CREATE TABLE testdb.emp(id INT);
INSERT INTO testdb.emp VALUES (1);


Slave:

SELECT * FROM testdb.emp;

📌 Notes & Best Practices

Keep 20–25% free space on both nodes.

Increase binlog retention during backup.

For multi-TB DBs use:

gp3 ≥ 600–1000 MB/s

parallel rsync

Always use GTID for stable replication.

🎯 Conclusion

This project demonstrates:

✔ Automated AWS infra with Terraform
✔ MySQL installation on AL2023
✔ XtraBackup-based replication (no snapshots)
✔ GTID-based auto-positioning
✔ Fully reproducible dev/test environment