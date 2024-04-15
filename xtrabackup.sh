#!/bin/bash
# 定义变量
MYSQL_USERNAME=""
MYSQL_PASSWORD=""
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_DATADIR=""
MYSQL_CNF=""
MYSQL_SOCK=""

# Telegram Bot
API=""
CHAT=""

today=$(date +%Y-%m-%d)

IP=$(curl ident.me)

#路径
WORKSPACE=""
S3=""

# 备份所有数据库 
backup_all_database(){
echo "
 __   __ _                 _                   _ 
 \ \ / /| |               | |                 | | 
  \ V / | |_  _ __   __ _ | |__    __ _   ___ | | __ _   _  _ __ 
   > <  | __|| '__| / _  || '_ \  / _  | / __|| |/ /| | | || '_ \ 
  / . \ | |_ | |   | (_| || |_) || (_| || (__ |   < | |_| || |_) | 
 /_/ \_\ \__||_|    \__,_||_.__/  \__,_| \___||_|\_\ \__,_|| .__/ 
                                                           | | 
                                                           |_| 
"


# 删除旧备份
rm -fr $WORKSPACE

if [[ ! -d "$WORKSPACE" ]];then
    mkdir -p $WORKSPACE
fi


# 记录开始时间
start_time=$(date +%s)

#开始备份
echo "$(date +"%y%m%d %H:%M:%S") 正在进行全库全量备份，备份目录为$WORKSPACE/$(date +"%Y%m%d")/base，被备份目录为$MYSQL_DATADIR"
mkdir -p "$WORKSPACE/$(date +"%Y%m%d")/base"
xtrabackup --defaults-file=$MYSQL_CNF \
           --backup \
           --target-dir="$WORKSPACE/$(date +"%Y%m%d")/base" \
           --user=$MYSQL_USERNAME \
           --password=$MYSQL_PASSWORD \
           --host=$MYSQL_HOST \
           --port=$MYSQL_PORT \
           --socket=$MYSQL_SOCK \
           --datadir=$MYSQL_DATADIR

# 检查 xtrabackup 是否成功
status=$?
if [ $status -ne 0 ]; then
    
message="$today $HOSTNAME
IP: $IP
备份失败，请进速查看"
echo $message
curl -X POST "https://api.telegram.org/bot$API/sendMessage" -d "chat_id=$CHAT&text=$message"

else

/usr/local/bin/aws s3 sync $WORKSPACE $S3


# 记录脚本结束时间
end_time=$(date +%s)

# 计算脚本总运行时间（秒）
runtime=$((end_time - start_time))

# 将运行时间转换为时分秒格式
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$((runtime % 60))

message="$today $HOSTNAME
IP: $IP
备份完成，耗时 $hours 时 $minutes 分 $seconds 秒"
echo $message
curl -X POST "https://api.telegram.org/bot$API/sendMessage" -d "chat_id=$CHAT&text=$message"
fi
}


help(){
     cat <<- EOF
    Usage:
        /bin/bash xtrabackup.sh [options] | [--exclude] Options::
    Options:
        all    | Backup mysql , ex: /bin/bash xtrabackup.sh all
        help   | Help document
EOF
}

case $1 in
    all)
        # 全库全量备份
        backup_all_database
    ;;
  *)
    help
  ;;
esac
