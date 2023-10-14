#!/usr/bin/env bash
# Author: yulinzhihou <yulinzhihou@gmail.com>
# Forum:  https://gsgamesahre.com
# Project: https://github.com/yulinzhihou/gstlenv.git
# Date :  2021-02-01
# Notes:  gstlenv for CentOS/RedHat 7+ Debian 10+ and Ubuntu 18+
# comment: 一键开服，适合于那种可以一键开启的服务端，如果3-5分钟后，服务端没开启，则需要使用分步开服方式
# 增加容器是否存在的判断
docker ps --format "{{.Names}}" | grep gsserver >/dev/null
if [ $? -eq 0 ]; then
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

  # 游戏内注册=0，登录器注册=1
  # if [ ${IS_DLQ} -eq 0 ]; then
  #   docker exec -d gsserver /home/billing/billing up -d
  #   sleep 3
  # fi

  # 检查是否有数据库文件，目前发现会出现不定时的出现数据库容器没有数据初始化的问题，临时解决，在开服前检测是否有正常的数据库文件
  function check_runtlbb_mysql_is_initd() {
    while :; do
      if [ -d '/tlgame/gsmysql/tlbbdb' ]; then
        FILE_CUR_NUM=$(ls -ltr /tlgame/gsmysql/tlbbdb | wc -l)
        if [ ${FILE_CUR_NUM} -lt 1 ]; then
          docker exec -d gsmysql /bin/bash /usr/local/bin/init_db.sh
        else
          break
        fi
      else
        echo "${CRED}环境未被初始化成功，请执行 [rebuild] 命令，进行重构${CEND}"
        exit 1
      fi
    done
  }

  SERVER_IS_RUN=$(docker exec -it gsserver ps aux | grep "Server" | wc -l)
  WORLD_IS_RUN=$(docker exec -it gsserver ps aux | grep "World" | wc -l)
  LOGIN_IS_RUN=$(docker exec -it gsserver ps aux | grep "Login" | wc -l)
  SHAREMEM_IS_RUN=$(docker exec -it gsserver ps aux | grep "ShareMem" | wc -l)
  BILLING_IS_RUN=$(docker exec -it gsserver ps aux | grep "billing" | wc -l)
  echo "${CSUCCESS}正在检测是否已经开服……，请稍候……${CEND}"
  if [ ${SERVER_IS_RUN} -eq 1 ] || [ ${WORLD_IS_RUN} -eq 1 ] || [ ${LOGIN_IS_RUN} -eq 1 ] || [ ${SHAREMEM_IS_RUN} -eq 1 ] || [ ${BILLING_IS_RUN} -eq 1 ]; then
    echo "${CRED}服务端好像正在运行，如果有疑问可以使用 [runtop] 进行查看，如果想继续执行，请先执行 [restart] 重启后再进行开服 [runtlbb] 操作${CEND}"
    exit 1
  else
    echo "${CSUCCESS}暂未发现之前运行过，正在开启……${CEND}"
    check_runtlbb_mysql_is_initd &&
      chmod -R 777 /tlgame &&
      docker exec -d gsserver chmod -R 777 /usr/local/bin &&
      docker exec -d gsmysql chmod -R 777 /usr/local/bin &&
      # chown -R root:root /tlgame &&
      cd ${ROOT_PATH}/${GSDIR} &&
      docker exec -d gsserver /bin/bash run.sh

    if [ $? -eq 0 ]; then
      # 删除因为改版本导致引擎启动失败的dump文件
      # gsbak
      cd ${ROOT_PATH}/${GSDIR} && rm -rf core.*
      echo -e "${CSUCCESS}已经成功启动服务端，请耐心等待几分钟后，建议使用：【runtop】查看开服的情况！！${CEND}"
      echo -e "${CWARNING}如果需要定时备份，请执行【gsbak】命令，默认1小时备份一次数据库和版本，保留10次备份数据！！${CEND}"
      exit 0
    else
      echo -e "${GSISSUE}\r\n"
      echo -e "${CRED} 启动服务端失败！${CEND}"
      exit 1
    fi
  fi
else
  echo -e "${GSISSUE}\r\n"
  echo "${CRED}环境毁坏，需要重新安装或者移除现有的环境重新安装！！！${CEND}"
  exit 1
fi
