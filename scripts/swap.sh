#!/usr/bin/env bash
# Author: yulinzhihou <yulinzhihou@gmail.com>
# Forum:  https://gsgamesahre.com
# Project: https://github.com/yulinzhihou/gstlenv.git
# Date :  2021-02-01
# Notes:  gstlenv for CentOS/RedHat 7+ Debian 10+ and Ubuntu 18+
# comment: 内存小，但是容量有20个G以上的云服务器。需要拓展虚拟内存
# 引入全局参数
if [ -f /root/.gs/.env ]; then
  . /root/.gs/.env
fi
# 颜色代码
if [ -f ./color.sh ]; then
  . ${GS_PROJECT}/scripts/color.sh
else
  . /usr/local/bin/color
fi

if [ ! -f /usr/swap/swapfile ]; then
  mkdir -p /usr/swap && dd if=/dev/zero of=/usr/swap/swapfile bs=100M count=40 &&
    chmod -R 600 /usr/swap/swapfile &&
    mkswap /usr/swap/swapfile &&
    swapon /usr/swap/swapfile &&
    echo "/usr/swap/swapfile swap swap defaults 0 0" >>/etc/fstab
  echo -e "${CSUCCESS}内存+虚拟缓存： ($(free -hm | awk -F " " 'NR==2{print $2}') + 4.0G) 成功！ 并且成功增加到开机自动加载！！${CEND}"
  exit 0
else
  echo -e "${CYELLOW}内存+虚拟缓存： ($(free -hm | awk -F " " 'NR==2{print $2}') + $(free -hm | awk -F " " 'NR==3{print $2}')) ${CEND}"
  exit 1
fi
