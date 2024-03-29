# php-nginx
使用 docker-compose 编排 php-fpm 和 nginx 容器，支持多应用，开箱即用

## 目录说明
- www/, 源码，如果有多个应用，使用子目录区分
- nginx/logs/, 虚拟主机日志，多应用同上
- nginx/conf.d/, 虚拟主机配置，多应用同上
- php-fpm/, Dockerfile 及 php 相关配置
- sh/，shell 脚本

## 镜像说明
- nginx，官方 nginx:1.22.1-alpine
- php-fpm，基于 php:7.4.33-fpm 的自定义镜像，除内置基础扩展外，该镜像已安装 gd、pdo_mysql、mcrpyt、zip、opcache、mongodb 扩展，如果需要安装其他扩展，可修改 Dockerfile

## docker-compose.yml
- 生产环境将 restart 备注开启
- 如果需要时间同步，将 localtime 备注开启（不兼容 Darwin）
- 如果默认网络冲突，需要配置网络，将 networks 相关备注开启

## nginx、php-fpm 配置优化
> nginx、php-fpm 部分配置优化如下，请根据机器配置自行调整，相关文件及目录已挂载
- nginx.conf
  - client_max_body_size 1024m，大文件上传
  - proxy_read_timeout 240s，慢脚本支持 for proxy（java etc.）
  - fastcgi_read_timeout 240s，慢脚本支持 for fastcgi（php-fpm etc.）
  - worker_connections 65535，**需要依据机器调优，最大文件句柄数**，`ulimit -n`
  - gzip 相关已开启
  - log 日志重定向
- www.conf
  - pm 相关优化，从上到下，dynamic 100 75 50 100，**需要依据机器调优，内存使用率**
- php.ini
  - post_max_size = 1024M，大文件上传
  - upload_max_filesize = 1024M，大文件上传
  - date.timezone = Asia/Shanghai
- opcache.ini
  - enable 128M 60s

## docker_nginx_log_cutting.sh
- 自动切割打包 ./nginx/logs/ 下的所有项目
- 保存近 14 天的日志压缩包

## php-fpm
> 为了让容器内脚本可写目录和文件，如日志（runtime/、web/），容器目录需要设置 www-data 用户和组
```shell
docker exec -it $containerIdorName chown -R www-data:www-data /var/www
# 脚本化
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

2. 安装 docker-compose
```shell
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

3. 配置容器日志
```shell
mkdir /etc/docker && mkdir /data/docker-runtime

# registry-mirrors，设置镜像源（注意：中科大镜像源已不对外!!!）
# graph，设置 docker 运行时根目录，默认是 /var/lib/docker，如果 /var 不单独分区容易造成磁盘溢出，请根据自己的操作系统分区情况修改
# log-x，日志相关配置
cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://hub-mirror.c.163.com"],
    "graph": "/data/docker-runtime",
    "log-driver": "json-file",
     "log-opts": {
        "max-size": "50m",
        "max-file": "1"
     }
}
EOF
```

4. 配置 nginx 日志切割
```shell
# chmod +x sh/docker_nginx_log_cutting.sh
# crontab
0 0 * * * /data/php-nginx/sh/docker_nginx_log_cutting.sh php-nginx_nginx_1 /data/php-nginx/nginx/logs/ &> /dev/null
```

5. 启动 docker
```shell
# centos7+
systemctl enable docker    # 开机自启
systemctl start docker     # 启动

docker -v
```

6. 启动 php-nginx
```shell
# cd 到 www 目录，拉取代码
# 新增 nginx/conf.d/${appName}.conf，配置虚拟主机
# 新增 ningx/logs/${appName}，创建应用 nginx 日志目录
docker-compose up -d --build
```
