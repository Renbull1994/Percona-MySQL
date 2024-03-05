#!/bin/bash

# 定義 ANSI 轉義序列
GREEN='\033[0;32m'
NC='\033[0m' # 恢復為正常顏色

# 創建安裝目錄
mkdir -p /data/mysql_data
mkdir -p /data/mysql_audit
mkdir -p /data/mysql_audit_archive
mkdir -p /data/myxtrabackup
mkdir -p /data/mysql_tmpdir

# 下載 Percona MySQL 安裝包
yum -y -q install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

# 選擇安裝的版本
PS3="請選擇要安裝的Percona版本: "
options=("8.0" "8.2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "8.0")
            PERCONA_VERSION="8.0"
            break
            ;;
        "8.2")
            PERCONA_VERSION="8.2"
            break
            ;;
        "Quit")
            echo "退出安裝"
            exit 0
            ;;
        *) echo "無效選擇";;
    esac
done


if [ "$opt" == "8.0" ]; then

percona-release setup ps80
percona-release enable tools release
echo "Install Percona MySQL.........."
yum -y -q install percona-server-server percona-mysql-shell percona-mysql-router


systemctl daemon-reload
systemctl stop mysqld

# 創建 Percona MySQL 配置文件
echo "Creating Percona Server configuration..."
cat <<EOF > /etc/my.cnf
[mysqld]
server_id=1

datadir=/data/mysql_data
relay-log=1-relay-log
log_error=/data/mysql_data/1.err
slow_query_log_file=/data/mysql_data/1-slow.log

max_connections=20000
table_open_cache=20000
expire_logs_days=14
gtid_mode=ON 
log-bin=1-log-bin
log-slave-updates
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

PASSWD=$(grep temporary /data/mysql_data/1.err | awk '{print $NF}')
echo -e "Temp password = ${GREEN}$PASSWD${NC}"

# 啟動 Percona MySQL 服務
echo "Starting Percona Server service..."
systemctl start mysqld
systemctl enable mysqld

echo "Percona Server installation completed."

elif [ "$opt" == "8.2" ]; then

percona-release enable-only ps-8x-innovation release
percona-release enable tools release
echo "Install Percona MySQL.........."
yum -y -q install percona-server-server percona-mysql-shell percona-mysql-router


systemctl daemon-reload
systemctl stop mysqld

# 創建 Percona MySQL 配置文件
echo "Creating Percona Server configuration..."
cat <<EOF > /etc/my.cnf
[mysqld]
server_id=1

datadir=/data/mysql_data
relay-log=1-relay-log
log_error=/data/mysql_data/1.err
slow_query_log_file=/data/mysql_data/1-slow.log

max_connections=20000
table_open_cache=20000
gtid_mode=ON 
log-bin=1-log-bin
log-slave-updates
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

PASSWD=$(grep temporary /data/mysql_data/1.err | awk '{print $NF}')
echo -e "Temp password = ${GREEN}$PASSWD${NC}"

# 啟動 Percona MySQL 服務
echo "Starting Percona Server service..."
systemctl start mysqld
systemctl enable mysqld

echo "Percona Server installation completed."

fi
