# php-nginx
使用 docker-compose 编排 php-fpm 和 nginx 容器，支持多应用

## 目录说明
- www/, 源码，如果有多个应用，使用子目录区分
- nginx/logs/, 虚拟主机日志，多应用同上
- nginx/conf.d/, 虚拟主机配置，多应用同上
- php-fpm/, Dockerfile 及 php 相关配置

## 镜像说明
- nginx，官方 nginx:1.15
- php-fpm，基于 php:7.1-fpm 的自定义镜像，除内置基础扩展外，该镜像已安装 gd、pdo_mysql、mcrpyt、zip、opcache、mongodb 扩展，如果需要安装其他扩展，可修改 Dockerfile

## docker-compose.yml
- 如果需要时间同步，将 localtime 备注开启（macos 无效，需要替换为对应的文件）
- 如果默认网络冲突，需要配置网络，将 networks 相关备注开启

## nginx、php-fpm 配置优化
> nginx、php-fpm 部分配置优化如下，请根据机器配置自行调整，相关文件及目录已挂载
- nginx.conf
  - client_max_body_size 1024m，大文件上
  - proxy_read_timeout 240s，慢脚本支持 for proxy（java etc.）
  - fastcgi_read_timeout 240s，慢脚本支持 for fastcgi（php-fpm etc.）
  - worker_processes 4，**需要依据机器调优，CPU 核心数，grep 'model name' /proc/cpuinfo | wc -l**
  - worker_connections 1024，**需要依据机器调优，最大文件句柄数，ulimit -n**
  - gzip 相关已开启
  - log 日志重定向
- www.conf
  - pm 相关优化，从上到下，dynamic 100 75 50 100，**需要依据机器调优，内存使用率**
- php.ini
  - memory_limit = 256M，for yii2 class autoload script
  - post_max_size = 1024M
  - upload_max_filesize = 1024M，大文件上传
  - date.timezone = Asia/Shanghai
- opcache.ini
  - enable 128M 60s

## php-fpm
> 为了让容器内脚本可写目录和文件，如日志（runtime/、web/），容器目录需要设置 www-data 用户和组
```shell
docker exec -it $containerIdorName chown -R www-data:www-data /var/www
// 脚本化
ssh $ip "docker exec $containerIdorName chown -R www-data:www-data /var/www"
```

## 使用
1. 安装 docker-ce
```shell
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
```

2. 启动 docker
```shell
# centos7+
systemctl enable docker    # 开机自启
systemctl start docker     # 启动

docker -v
```

3. 安装 docker-compose
```shell
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

4. 启动 php-nginx
```shell
# cd 到 www 目录，拉取代码
# 新增 nginx/conf.d/${appName}.conf，配置虚拟主机
# 新增 ningx/logs/${appName}，创建应用 nginx 日志目录
docker-compose up -d --build
```

5. 配置 nginx 日志切割
```
# chmod +x sh/docker_nginx_log_cutting.sh
# crontab
0 0 * * * /data/php-nginx/sh/docker_nginx_log_cutting.sh php-nginx_nginx_1 /data/php-nginx/nginx/logs/ &> /dev/null
```
