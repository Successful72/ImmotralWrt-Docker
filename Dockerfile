# 第一阶段：准备文件
FROM alpine:latest as builder

# 复制初始化脚本到临时位置
COPY Immortalwrt.sh /tmp/init-script.sh

# 创建entrypoint脚本
RUN echo '#!/bin/sh\n\
# 检查脚本是否存在\n\
if [ -f /root/init-script.sh ]; then\n\
  echo "正在执行初始化脚本..."\n\
  chmod +x /root/init-script.sh\n\
  /root/init-script.sh\n\
else\n\
  echo "警告：初始化脚本不存在"\n\
fi\n\
\n\
# 执行默认的启动命令\n\
echo "启动ImmortalWrt系统..."\n\
exec "$@"' > /tmp/entrypoint.sh

# 设置脚本权限
RUN chmod +x /tmp/entrypoint.sh /tmp/init-script.sh

# 第二阶段：最终镜像
FROM scratch
LABEL org.opencontainers.image.authors="Successful72"
LABEL org.opencontainers.image.description="ImmortalWrt Docker image with configurable networking"

# 添加ImmortalWrt文件系统
ADD *.tar.gz /

# 从第一阶段复制准备好的脚本
COPY --from=builder /tmp/init-script.sh /root/init-script.sh
COPY --from=builder /tmp/entrypoint.sh /root/entrypoint.sh

# 设置entrypoint脚本为入口点
ENTRYPOINT ["/root/entrypoint.sh"]

# 默认命令
CMD ["/sbin/init"]
