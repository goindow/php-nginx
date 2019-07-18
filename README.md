# php-nginx
使用 docker-compose 编排 php-fpm 和 nginx 容器，支持多应用

## 目录说明
- www/, 源码，如果有多个应用，使用子目录区分
- nginx/logs/, 虚拟主机日志，多应用同上
- nginx/conf.d/, 虚拟主机配置，多应用同上
- php-fpm/, Dockerfile 及 php.ini、www.conf 等配置

## 镜像说明
- nginx，官方 nginx:1.15
- php-fpm，基于 php:7.1-fpm 的自定义镜像，除内置基础扩展外，该镜像已安装 gd 和 pdo_mysql 扩展，如果需要安装其他扩展，可修改 Dockerfile
- nginx、php-fpm 使用默认配置文件，请根据机器配置自行优化，相关文件及目录已挂载

## docker-compose.yml
- 如果需要时间同步，将备注开启
- 如果无需进入容器，可将 nginx 和 php-fpm 换成 alpine 系列镜像

## 使用
1. 安装 docker-ce
```shell
yum update
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
# 新增 nginx/conf.d/*.conf，配置虚拟主机
docker-compose up -d --build
```
