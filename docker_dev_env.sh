#! /usr/bin/env bash

CURRENT_DIR=$(cd `dirname $0`; pwd)

# --user $(id -u):$(id -g)
# sudo chown -hR $(id -u):$(id -g) ~/projects/docker

docker run --rm -d --name apache-php -p 8888:80 -v ~/projects/docker/web_root:/app -e XDEBUG_REMOTE_AUTOSTART=1 -e XDEBUG_REMOTE_ENABLE=1 webdevops/php-apache-dev:alpine

docker run --rm -d --name nginx -p 7777:7777 -v ~/projects/docker/web_root:/web_root -v $CURRENT_DIR"/conf/nginx/nginx.conf":/etc/nginx/nginx.conf -v $CURRENT_DIR"/conf/nginx/conf.d/":/etc/nginx/conf.d/ nginx:alpine
# docker exec -it nginx /bin/sh

docker run --rm -d --name redis-server -p 6379:6379 redis

docker run --rm -d --name mysql -p 4407:3306 -v ~/projects/docker/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ALLOW_EMPTY_PASSWORD=true --privileged=true mysql:8.0

docker run --rm -d --name pgsql -p 6543:5432 -v ~/projects/docker/pgsql:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres

# k8s的nfs存储依赖 nfs-common, 依赖rpcbind，这个和k8s的调试冲突
# debian 客户端需要安装 nfs-common
# mount -t nfs -o nolock 192.168.56.1:/mnt/nfs ./nfs
docker run --rm -d --name nfs-server -v ~/projects/docker/nfs/:/mnt/nfs -e NFS_EXPORT_DIR_1=/mnt/nfs -e NFS_EXPORT_DOMAIN_1=\* -e NFS_EXPORT_OPTIONS_1=rw,insecure,no_subtree_check,all_squash,fsid=1 -p 111:111 -p 111:111/udp -p 2049:2049 -p 2049:2049/udp -p 32765:32765 -p 32765:32765/udp -p 32766:32766 -p 32766:32766/udp -p 32767:32767 -p 32767:32767/udp --privileged=true fuzzle/docker-nfs-server:latest

# openssl rand -hex 16
# /home/vsftpd 目录下必须带一个和用户名一样的子目录，否则看不到数据
docker run --rm -d --name ftp -v ~/projects/docker/ftp/:/home/vsftpd/demo -p 20:20 -p 21:21 -p 21100-21110:21100-21110 -e LOCAL_UMASK=022 -e FTP_USER=demo -e FTP_PASS=123456 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 -e PASV_ADDRESS=0.0.0.0 -e LOG_STDOUT=1 fauria/vsftpd

docker run --rm -d -it --name=tftpd -p 69:69/udp -v ~/projects/docker/tftp:/srv/tftp hkarhani/tftpd

# 共享目录为 \\ip\smb
docker run --rm -d --name smb -v ~/projects/docker/smb/:/mount -p 139:139 -p 445:445 dperson/samba -u "mmc;123456;1000;mmc;1000" -s "smb;/mount;yes;no;no;mmc"
