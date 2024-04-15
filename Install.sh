#!/bin/bash

# 定義 ANSI 轉義序列
GREEN='\033[0;32m'
NC='\033[0m' # 恢復為正常顏色


echo "================================"
echo "MySQL Community Server 8" 
# DB Port
echo -n "Install Port: "
read DB_Port
echo "================================"

read -s -n1 -p "按任意键开始运行脚本 ... "
echo ""


# 創建安裝目錄
mkdir -p /home/mysql_$DB_Port/data
mkdir -p /home/mysql_$DB_Port/log

# 下載安裝MySQL 8.0
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.36-1.el7.x86_64.rpm-bundle.tar
tar -xf mysql-8.0.36-1.el7.x86_64.rpm-bundle.tar
echo "Install MySQL.........."
yum -y -q install mysql-community-libs*.rpm mysql-community-server-8.0*.rpm mysql-community-client-*.rpm mysql-community-common-8.*.rpm mysql-community-icu-data-files-8.*.rpm
rm -rf mysql-community-*

# 下載安裝Repo包及Xtrabackup套件
echo "Install Xtrabackup.........."
yum -y -q install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release setup ps80
yum -y -q install https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/z/zstd-1.5.5-1.el7.x86_64.rpm
yum -y -q install percona-xtrabackup-80

systemctl daemon-reload
systemctl stop mysqld

chown -R mysql:mysql /home/mysql_$DB_Port

# 創建 Percona MySQL 配置文件
echo "Creating Percona Server configuration..."
cat <<EOF > /etc/my.cnf
[mysqld]
port                                   = $DB_Port
server_id                              = 1032$DB_Port
character_set_server                   = utf8mb4
collation_server                       = utf8mb4_unicode_ci
basedir                                = /home/mysql_$DB_Port
datadir                                = /home/mysql_$DB_Port/data
slow_query_log                         = 1
long_query_time                        = 3
slow_query_log_file                    = /home/mysql_$DB_Port/slow.log
log_error							   = /home/mysql_$DB_Port/log/mysqld.log

# replication
log_replica_updates                    = 1
binlog_expire_logs_seconds             = 2592000     # 3 days
binlog_format                          = row
max_binlog_size                        = 1G
relay-log                              = mysql-relay-bin
log-bin                                = mysql-bin
#read_only                              = ON

# network
max_allowed_packet                     = 128M
back_log                               = 1024
interactive_timeout                    = 600
wait_timeout                           = 600
skip_name_resolve                      = 1
max_user_connections                   = 40000
max_connections                        = 50000
max_connect_errors                     = 100000
sql_mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"

# innodb
innodb_buffer_pool_size                = 5G
innodb_data_file_path                  = ibdata1:1G:autoextend
innodb_max_dirty_pages_pct             = 50
innodb_flush_method                    = O_DIRECT
innodb_print_all_deadlocks             = 1
innodb_print_ddl_logs                  = 1
innodb_log_buffer_size                 = 16M
EOF

# 初始化 MySQL MySQL 數據庫
echo "Initializing MySQL Server database..."
mysqld --initialize --user=mysql 
PASSWD=$(grep temporary /home/mysql_$DB_Port/log/mysqld.log | awk '{print $NF}')


# 啟動 MySQL 服務
echo "Starting MySQL Server service..."
systemctl start mysqld
systemctl enable mysqld

echo "MySQL Server installation completed."

echo "**********************************"
echo "Login cmd : mysql -u root -p'"
echo -e "Temp password = ${GREEN}$PASSWD${NC}"
echo "**********************************"
