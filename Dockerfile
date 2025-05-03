# 基于OpenWrt官方镜像
FROM scratch
LABEL org.opencontainers.image.authors="Successful72"
LABEL org.opencontainers.image.description="ImmortalWrt Docker image with configurable networking"

# 添加ImmortalWrt文件系统
ADD *.tar.gz /

# 复制初始化脚本
COPY Immortalwrt.sh /root/init-script.sh

# 赋予脚本执行权限
RUN chmod +x /root/init-script.sh

# 创建entrypoint脚本
RUN echo '#!/bin/sh\n\
# 运行初始化脚本\n\
/root/init-script.sh\n\
\n\
# 执行默认的启动命令\n\
exec "$@"' > /root/entrypoint.sh && \
    chmod +x /root/entrypoint.sh

# 设置entrypoint脚本为入口点
ENTRYPOINT ["/root/entrypoint.sh"]

# 默认命令
CMD ["/sbin/init"]
