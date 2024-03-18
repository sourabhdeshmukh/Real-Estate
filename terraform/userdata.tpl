#!/bin/sh
logit() {
   while read LINE
   do
      LOGFILE=/var/log/user-data.log
      STAMP=$(date +"%Y-%m-%d %H:%M:%S")
      echo "$STAMP       $LINE" >> $LOGFILE
   done

}

set -x
((

yum update -qy
yum install git curl wget docker -qy
systemctl start docker
systemctl enable docker
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

git clone https://github.com/sourabhdeshmukh/Real-Estate.git
cd Real-Estate
docker-compose up -d


) 2>&1)  | logit