FROM scratch
LABEL org.opencontainers.image.authors="Successful72"
LABEL org.opencontainers.image.description="OpenWrt Docker image with configurable networking"

# 添加OpenWrt文件系统
ADD *.tar.gz /

# 添加配置脚本
COPY /custom-scripts/Immortalwrt.sh /Immortalwrt.sh

# 设置脚本执行权限
RUN chmod +x /Immortalwrt.sh

# 设置容器入口点
ENTRYPOINT ["/Immortalwrt.sh"]
