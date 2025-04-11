# [Immotralwrt-Docker](https://github.com/Successful72/OpenWrt-Docker)

Openwrt的自编译Docker镜像，使用GitHub Actions构建。

---

## 支持设备及工作原理

编译的Docker镜像仅支持x86设备。

本项目基于[ImmortalWrt OpenWrt-24.10](https://github.com/immortalwrt/immortalwrt/tree/openwrt-24.10)构建，Docker镜像构建完毕后，会自动推送到Releases，供本地使用。

---
## 镜像使用方法

将编译好的镜像通过SFTP传入服务器，然后执行以下命令将镜像导入本地镜像仓库

```
docker load -i <镜像绝对路径>
```

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
