#!/bin/sh

# Docker入口点脚本
# 负责启动OpenWrt并在适当的时机执行配置脚本

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Docker容器启动..."

# 启动配置管理器后台进程
if [ -f /usr/bin/Immortalwrt-init.sh ]; then
  log "注册配置初始化服务..."
  # 创建一个初始化服务脚本
  cat > /etc/init.d/custom-init << EOF
#!/bin/sh /etc/rc.common
START=99
STOP=15

start() {
  /usr/bin/openwrt-init.sh &
}

stop() {
  :
}
EOF
  
  # 设置执行权限
  chmod +x /etc/init.d/custom-init
  
  # 启用服务
  /etc/init.d/custom-init enable
  
  log "初始化服务已注册，将在系统启动完成后执行"
else
  log "警告: 配置脚本不存在于 /usr/bin/Immortalwrt-init.sh"
fi

# 执行OpenWrt初始化进程
log "启动OpenWrt系统..."
exec /sbin/init "$@"
