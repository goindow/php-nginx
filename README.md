# php-nginx
使用 docker-compose 编排 php-fpm 和 nginx 容器

## 目录说明
- www/, 代码目录
- nginx/logs/, 虚拟主机日志目录
- nginx/conf.d/, 虚拟主机配置目录
- nginx/nginx.conf, nginx 配置文件
- www/html/, php-fpm bash 默认目录，无视即可

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
# 编辑 nginx/conf.d/host.conf
# cd 到 docker-compose.yml 目录
docker-compose up -d --build
```