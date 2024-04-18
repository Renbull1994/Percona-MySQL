#!/bin/bash

# 定義 ANSI 轉義序列
YELLOW='\033[0;33m'
NC='\033[0m' # 恢復為正常顏色
serverid=$(date +%N |cut -c 1-8)
# 創建安裝目錄
mkdir -p /data/mysql_data
mkdir -p /data/mysql_audit
mkdir -p /data/mysql_audit_archive
mkdir -p /data/myxtrabackup
mkdir -p /data/mysql_tmpdir

Install_8.0(){

DB_Port=$1

# 下載 Percona MySQL 安裝包
yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release setup ps80
percona-release enable tools release
echo "Install Percona MySQL.........."
yum -y install percona-server-server percona-mysql-shell


systemctl daemon-reload
systemctl stop mysqld

# 創建 Percona MySQL 配置文件
echo "Creating Percona Server configuration..."
cat <<EOF > /etc/my.cnf
[mysqld]
server_id=$serverid
port=$DB_Port

datadir=/data/mysql_data
relay-log=mysql-relay-log
log_error=/data/mysql_data/$serverid.err
slow_query_log_file=/data/mysql_data/mysql-slow.log

max_connections=20000
table_open_cache=20000
expire_logs_days=14
gtid_mode=ON 
log-bin=mysql-log-bin
binlog_format=ROW
sync_binlog=1
relay_log_recovery=on
enforce-gtid-consistency
slow_query_log=on
long_query_time=0.2
innodb_log_file_size=2G
innodb_buffer_pool_size=2G
master_info_repository=TABLE
relay_log_info_repository=TABLE
character_set_server=utf8
innodb_flush_method=O_DIRECT
EOF

# 初始化 Percona MySQL 數據庫
echo "Initializing Percona Server database..."
mysqld --initialize --user=mysql

PASSWD=$(grep temporary /data/mysql_data/$serverid.err | awk '{print $NF}')
echo -e "Temp password = ${YELLOW}$PASSWD${NC}"

# 啟動 Percona MySQL 服務
echo "Starting Percona Server service..."
systemctl start mysqld
systemctl enable mysqld

echo "Percona Server installation completed."
}

Install_8.x(){

DB_Port=$1

# 下載 Percona MySQL 安裝包
yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release enable-only ps-8x-innovation release
percona-release enable tools release
echo "Install Percona MySQL.........."
yum -y install percona-server-server percona-mysql-shell


systemctl daemon-reload
systemctl stop mysqld

# 創建 Percona MySQL 配置文件
echo "Creating Percona Server configuration..."
cat <<EOF > /etc/my.cnf
[mysqld]
server_id=$serverid
port=$DB_Port

datadir=/data/mysql_data
relay-log=mysql-relay-log
log_error=/data/mysql_data/$serverid.err
slow_query_log_file=/data/mysql_data/mysql-slow.log

max_connections=20000
table_open_cache=20000
gtid_mode=ON 
log-bin=mysql-log-bin
binlog_format=ROW
sync_binlog=1
relay_log_recovery=on
enforce-gtid-consistency
slow_query_log=on
long_query_time=0.2
innodb_log_file_size=2G
innodb_buffer_pool_size=2G
character_set_server=utf8
innodb_flush_method=O_DIRECT
EOF

# 初始化 Percona MySQL 數據庫
echo "Initializing Percona Server database..."
mysqld --initialize --user=mysql

PASSWD=$(grep temporary /data/mysql_data/$serverid.err | awk '{print $NF}')
echo -e "Temp password = ${YELLOW}$PASSWD${NC}"

# 啟動 Percona MySQL 服務
echo "Starting Percona Server service..."
systemctl start mysqld
systemctl enable mysqld

echo "Percona Server installation completed."

}

help(){
     cat <<- EOF
    Usage:
        /bin/bash install.sh [options] 
    Options:
        -i8  [port]   Install mysql 8.0.x with port , ex: /bin/bash install.sh -i8 6603
        -i8x [port]   Install mysql 8.3.x with port , ex: /bin/bash install.sh -i8x 6603
        -help       Help document
EOF
}

case $1 in
  '-i8')
    Install_8.0 $2
  ;;
  '-i8x')
    Install_8.x $2
  ;;
  *)
    help
  ;;
esac
