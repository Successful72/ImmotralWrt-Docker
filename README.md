# [Immotralwrt-Docker](https://github.com/Successful72/OpenWrt-Docker)

Openwrt的自编译Docker镜像，使用GitHub Actions构建。

<br>

## 支持设备及工作原理

编译的Docker镜像仅支持x86设备。

本项目基于[ImmortalWrt OpenWrt-24.10](https://github.com/immortalwrt/immortalwrt/tree/openwrt-24.10)构建，Docker镜像构建完毕后，会自动推送到Releases，供本地使用。

<br>

## 镜像使用方法

1. 将编译好的镜像通过SFTP传入服务器，然后执行以下命令将镜像导入本地镜像仓库

```
docker load -i <镜像绝对路径>
```

2. 创建一个Docker Compose文件和一个.env文件，分别填入
   1. Docker Compose
      ```
      # 仅有注释部分需要修改
      services:
      openwrt:
      image: '${OPENWRT_IMAGE}'

      container_name: '${CONTAINER_NAME}'
    
      networks:
        manvlan1:  # macvlan网卡名称 
          ipv4_address: '${CONTAINER_IP}'
          mac_address: '${CONTAINER_MAC}'
      dns:
        - '${DNS_SERVER}'
    
      restart: always
      privileged: true
      tty: true
      stdin_open: true

      deploy:
        resources:
          reservations:
            memory: '${MEMORY_RESERVATION}'
            cpus: '${CPU_RESERVATION}'
    
      mem_limit: ${MEMORY_LIMIT}
      cpus: ${CPU_LIMIT}
    
      extra_hosts:
        - "host.docker.internal:host-gateway"
    
      command: /bin/bash -c "sleep ${START_DELAY} && /sbin/init"

      networks:
        manvlan1:  # macvlan网卡名称(必须与上相同)
        external: true

      ```
   2. .env
      ```
      # Docker Compose变量配置：OpenWrt

      # 镜像名称
      OPENWRT_IMAGE=immortalwrt:latest

      # 容器名称
      CONTAINER_NAME=openwrt

      # 网络配置(这里使用MACVLAN网络)
      # MACVLAN网卡名称必须在对应的yml文件内修改

      # 容器IP(不可出现IP冲突)
      CONTAINER_IP=200.56.72.240

      # 容器MAC地址(不可出现容器MAC冲突；这东西随机生成即可。若部署报错，那就换一个)
      CONTAINER_MAC=FC:14:CD:30:3D:6B

      # 容器使用的DNS服务器
      DNS_SERVER=200.56.72.251

      # 设置启动延迟(秒)
      START_DELAY=10

      # 设置容器使用限制
      # 说明：内存预留和CPU预留，即容器最低可用资源，指容器正常运行需要的最低资源。合理设置可以保证容器正常运行。
      # 设置最大内存限制(填写规范：整数+容量单位[k，m，g，t]；填写数值不得高于物理内存最大数值)
      MEMORY_LIMIT=512m

      # 设置内存预留(填写规范：整数+容量单位[k，m，g，t]；填写数值不得高于最大内存限制数值)
      MEMORY_RESERVATION=256m

      # 设置CPU限制(填写规范：整数+一位小数；CPU核心不得高于物理CPU核心总数；填写0即表示不限制)
      CPU_LIMIT=4

      # 设置CPU预留(填写规范：整数+一位小数；CPU核心不得高于CPU限制数值)
      CPU_RESERVATION=2

      ```
3. 部署Docker Compose即可。

<br>

## 鸣谢

SuLingGG/OpenWrt-Docker:

<https://github.com/SuLingGG/OpenWrt-Docker>

ImmortalWrt OpenWrt Source:

<https://github.com/immortalwrt/immortalwrt>

P3TERX/Actions-OpenWrt:

<https://github.com/P3TERX/Actions-OpenWrt>

OpenWrt Source Repository:

<https://github.com/openwrt/openwrt>

Lean's OpenWrt source:

<https://github.com/coolsnowwolf/lede>

zzsrv's Openwrt-Docker:

<https://github.com/zzsrv/OpenWrt-Docker>
