#!/bin/bash
# ----------------------------------------------------------------------------------------------------
# Filename:      docker_nginx_log_cutting.sh
# Version:       1.0
# Date:          2020.6.2
# Author:        hyb
# Description:   nginx[docker] 容器日志切割、打包、删除过期压缩包脚本，支持多项目切割打包
# Notes:         配合 crontab 计划任务，每天零时对日志打包
#                0 0 * * * [PATH]/docker_nginx_log_cutting.sh container_name project_dir &> /dev/null
# ----------------------------------------------------------------------------------------------------

# .log 日志文件名
access_log="access.log"
error_log="error.log"

# .tar.gz 日志压缩包名
access_tgz="access-*.tar.gz"
error_tgz="error-*.tar.gz"

# 压缩包过期时间
log_expires=14

# 打包时间
when=$(date -d 'yesterday' +%Y%m%d)    
#when=$(date -d 'today' +%Y%m%d%H%M)    # 测试

missing_parameter_tips="failed, missing parameter \$[]. command like, [PATH]/nginx_log_cutting.sh \$nginx_container_name \$nginx_logs_path."

# nginx 容器名
#
# docker 使用镜像重新创建容器的时候，container id 会变化。在启动容器的时候可以设置容器名，固定不变
nginx_container_name=$1
test -z $nginx_container_name && echo ${missing_parameter_tips//[]/nginx_container_name} && exit 1

# nginx 日志目录
#
# 支持多项目，程序会自动识别，最多识别两级目录，每个目录为一个项目，尝试切割打包，比如，a/
#   - 单项目 [a/*.log]
#   - 多项目 [a/b/*.log  a/c/*.log...](for php-nginx frame)
nginx_logs_dir=${2/%\//}
test -z $nginx_logs_dir && echo ${missing_parameter_tips//[]/nginx_logs_dir} && exit 2
test ! -d $nginx_logs_dir && echo "failed, $nginx_logs_dir is not a directory. is the nginx logs directory? " && exit 3
# 多项目支持
nginx_logs_dirs=($nginx_logs_dir/)
for path in $(ls -d $nginx_logs_dir/*/ 2> /dev/null); do   
    nginx_logs_dirs[${#nginx_logs_dirs[@]}]=$path
done

# 确保 docker daemon 正在运行
docker ps &> /dev/null
test $? -ne 0 && echo "failed，docker daemon is not running." && exit 4

# 确保 container 正在运行
docker ps | tail -n +2 | cut -d '"' -f 3 | awk -F " {2,}" '{print $5}' | grep ^$nginx_container_name$ &> /dev/null
test $? -ne 0 && echo "failed, the container[$nginx_container_name] was not found in the run list. please, start the container first." && exit 5

# 确保 container 基于 nginx
nginx=$(docker exec $nginx_container_name bash -c "command -v nginx")
test -z $nginx && echo "failed, nginx commands were not found in the container. is the nginx container?" && exit 6

# 确保 container 中的 nginx 正在运行
nginx_pid_file="/var/run/nginx.pid"
pid=$(docker exec $nginx_container_name bash -c "cat $nginx_pid_file 2> /dev/null")
test $? -ne 0 && echo "failed, nginx.pid file was not found." && exit 7

# 主逻辑
for path in ${nginx_logs_dirs[@]}; do
    # access.log 处理
    # 切割打包
    mv $path$access_log ${path}access-$when.log &> /dev/null && \
    tar -zcf ${path}access-$when.tar.gz -C $path access-$when.log --remove-file &> /dev/null
    # 过期处理
    if test $? -eq 0; then
        access_expires=$(($(ls $path$access_tgz 2> /dev/null | wc -l) - $log_expires))
        test $access_expires -gt 0 && ls -rtd $path$access_tgz | head -n $access_expires | xargs rm -f
    fi   

    # error.log 处理
    # 切割打包
    mv $path$error_log ${path}error-$when.log &> /dev/null && \
    tar -zcf ${path}error-$when.tar.gz -C $path error-$when.log --remove-file &> /dev/null    
    # 过期处理
    if test $? -eq 0; then
        error_expires=$(($(ls $path$error_tgz 2> /dev/null | wc -l) - $log_expires))
        test $error_expires -gt 0 && ls -rtd $path$error_tgz | head -n $error_expires | xargs rm -f
    fi
done

# 通知 nginx，新建 log
docker exec $nginx_container_name bash -c "kill -USR1 $pid" &> /dev/null

echo "success" && exit 0
