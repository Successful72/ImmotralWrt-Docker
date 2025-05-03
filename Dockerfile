FROM scratch
LABEL org.opencontainers.image.authors="Successful72"
LABEL org.opencontainers.image.description="OpenWrt Docker image with configurable networking"
LABEL org.opencontainers.image.source="https://github.com/Successful72/openwrt-docker"

# 添加OpenWrt文件系统
ADD *.tar.gz /

# 添加配置脚本
COPY $GITHUB_WORKSPACE/custom-scripts/Immortalwrt-init.sh /usr/bin/Immortalwrt-init.sh
COPY $GITHUB_WORKSPACE/custom-scripts/entrypoint.sh /entrypoint.sh

# 设置脚本执行权限
RUN chmod +x /usr/bin/Immortalwrt-init.sh /entrypoint.sh

# 设置环境变量默认值
ENV LAN_IPADDR="192.168.1.1" \
    LAN_NETMASK="255.255.255.0" \
    LAN_GATEWAY="192.168.1.1" \
    LAN_DNS="8.8.8.8" \
    IGNORE_DHCP="0"

# 暴露常用端口
EXPOSE 22 80 443 53/udp

# 设置容器入口点
ENTRYPOINT ["/entrypoint.sh"]
