CURRENT_PATH=$(cd `dirname $0`; pwd)

check_docker_network(){
  docker network ls | grep dev-network > /dev/null
  if [ $? -ne 0 ]; then
    echo "no network, let me create!"
    docker network create --driver bridge dev-network
  else
    echo "network already created!"
  fi
}
check_docker_network

# --user $(id -u):$(id -g)
# sudo chown -hR $(id -u):$(id -g) ~/projects/docker

docker run --rm -d --net dev-network --name apache-php -p 8888:80 -v ~/projects/docker/web_root:/app -e XDEBUG_REMOTE_AUTOSTART=1 -e XDEBUG_REMOTE_ENABLE=1 webdevops/php-apache-dev:alpine

docker run --rm -d --net dev-network --name nginx -p 7777:7777 -v ~/projects/docker/web_root:/web_root -v $CURRENT_PATH"/conf/nginx/nginx.conf":/etc/nginx/nginx.conf -v $CURRENT_PATH"/conf/nginx/conf.d/":/etc/nginx/conf.d/ nginx:alpine
# docker exec -it nginx /bin/sh

docker run --rm -d --net dev-network --name redis-server -p 6379:6379 redis

docker run --rm -d --net dev-network --name mysql -p 4407:3306 -v ~/projects/docker/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ALLOW_EMPTY_PASSWORD=true --privileged=true mysql:8.0

docker run --rm -d --net dev-network --name pgsql -p 6543:5432 -v ~/projects/docker/pgsql:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres

# k8s的nfs存储依赖 nfs-common, 依赖rpcbind，这个和k8s的调试冲突
# mount -t nfs -o nolock 192.168.56.1:/mnt/nfs ./nfs
docker run --rm -d --net dev-network --name nfs-server -v ~/projects/docker/nfs/:/mnt/nfs -e NFS_EXPORT_DIR_1=/mnt/nfs -e NFS_EXPORT_DOMAIN_1=\* -e NFS_EXPORT_OPTIONS_1=rw,insecure,no_subtree_check,all_squash,fsid=1 -p 111:111 -p 111:111/udp -p 2049:2049 -p 2049:2049/udp -p 32765:32765 -p 32765:32765/udp -p 32766:32766 -p 32766:32766/udp -p 32767:32767 -p 32767:32767/udp --privileged=true fuzzle/docker-nfs-server:latest

# openssl rand -hex 16
# /home/vsftpd 目录下必须带一个和用户名一样的子目录，否则看不到数据
docker run --rm -d --name ftp --net dev-network -v ~/projects/docker/ftp/:/home/vsftpd/demo -p 20:20 -p 21:21 -p 21100-21110:21100-21110 -e LOCAL_UMASK=022 -e FTP_USER=demo -e FTP_PASS=123456 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 -e PASV_ADDRESS=0.0.0.0 -e LOG_STDOUT=1 fauria/vsftpd

docker run --rm -d -it --net dev-network --name=tftpd -p 69:69/udp -v ~/projects/docker/tftp:/srv/tftp hkarhani/tftpd

# -u "mmc;mmc" -s "smb;/mount/;yes;no;no;all;none"
# -s "smb;/mount/;yes;no;yes;all;none"
# 共享目录为 \\ip\smb
docker run --rm -d --net dev-network --name smb -v ~/projects/docker/smb/:/mount -p 139:139 -p 445:445 dperson/samba -s "smb;/mount/;yes;no;yes;all;none"

# metasploit
# alias msf="docker exec -it msf /usr/src/metasploit-framework/msfconsole"
docker run --rm -d --net=host --name msf -it --hostname msf -v $HOME/.msf4:/root/.msf4 -v /tmp/msf:/tmp/data metasploitframework/metasploit-framework
