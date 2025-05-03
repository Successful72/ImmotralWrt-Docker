#!/bin/sh

# ImmortalWrt初始化配置脚本
# 此脚本通过环境变量接收配置信息并直接修改对应文件

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 错误: $1" >&2
  exit 1
}

# 检查必要的环境变量
check_required_vars() {
  log "检查必要的环境变量..."
  
  # 检查LAN接口的必要配置
  if [ -z "$LAN_IP" ]; then
    error "环境变量LAN_IP未设置"
  fi
  
  if [ -z "$LAN_NETMASK" ]; then
    error "环境变量LAN_NETMASK未设置"
  fi
  
  if [ -z "$LAN_GATEWAY" ]; then
    error "环境变量LAN_GATEWAY未设置"
  fi
  
  if [ -z "$LAN_DNS" ]; then
    error "环境变量LAN_DNS未设置"
  fi
  
  # 检查ROOT密码
  if [ -z "$ROOT_PASSWORD" ]; then
    error "环境变量ROOT_PASSWORD未设置"
  fi
}

# 配置LAN接口
configure_lan() {
  log "配置LAN接口..."
  
  # 网络配置文件路径
  NETWORK_CONFIG="/etc/config/network"
  
  # 确保文件存在
  if [ ! -f "$NETWORK_CONFIG" ]; then
    error "网络配置文件 $NETWORK_CONFIG 不存在"
  fi
  
  # 备份原始文件
  cp "$NETWORK_CONFIG" "${NETWORK_CONFIG}.bak"
  
  # 使用sed修改LAN接口配置
  # 修改IP地址
  sed -i "/config interface 'lan'/,/config/ s/option ipaddr '[^']*'/option ipaddr '$LAN_IP'/g" "$NETWORK_CONFIG"
  
  # 修改子网掩码
  sed -i "/config interface 'lan'/,/config/ s/option netmask '[^']*'/option netmask '$LAN_NETMASK'/g" "$NETWORK_CONFIG"
  
  # 添加或修改网关
  if grep -q "option gateway" "$NETWORK_CONFIG"; then
    sed -i "/config interface 'lan'/,/config/ s/option gateway '[^']*'/option gateway '$LAN_GATEWAY'/g" "$NETWORK_CONFIG"
  else
    sed -i "/config interface 'lan'/,/config/ s/option netmask.*/&\n\toption gateway '$LAN_GATEWAY'/g" "$NETWORK_CONFIG"
  fi
  
  # 添加或修改DNS
  if grep -q "option dns" "$NETWORK_CONFIG"; then
    sed -i "/config interface 'lan'/,/config/ s/option dns '[^']*'/option dns '$LAN_DNS'/g" "$NETWORK_CONFIG"
  else
    sed -i "/config interface 'lan'/,/config/ s/option gateway.*/&\n\toption dns '$LAN_DNS'/g" "$NETWORK_CONFIG"
  fi
  
  log "LAN接口配置完成"
}

# 配置dnsmasq
configure_dnsmasq() {
  log "配置dnsmasq..."
  
  # dnsmasq配置文件路径
  DHCP_CONFIG="/etc/config/dhcp"
  
  # 确保文件存在
  if [ ! -f "$DHCP_CONFIG" ]; then
    error "DHCP配置文件 $DHCP_CONFIG 不存在"
  fi
  
  # 备份原始文件
  cp "$DHCP_CONFIG" "${DHCP_CONFIG}.bak"
  
  # 如果提供了DNSMASQ_LOCAL，则修改local设置
  if [ -n "$DNSMASQ_LOCAL" ]; then
    log "设置dnsmasq local为: $DNSMASQ_LOCAL"
    if grep -q "option local" "$DHCP_CONFIG"; then
      sed -i "/option local/c\\\\toption local '$DNSMASQ_LOCAL'" "$DHCP_CONFIG"
    else
      sed -i "/config dnsmasq/a\\\\toption local '$DNSMASQ_LOCAL'" "$DHCP_CONFIG"
    fi
  fi
  
  # 如果提供了DNSMASQ_DOMAIN，则修改domain设置
  if [ -n "$DNSMASQ_DOMAIN" ]; then
    log "设置dnsmasq domain为: $DNSMASQ_DOMAIN"
    if grep -q "option domain" "$DHCP_CONFIG"; then
      sed -i "/option domain/c\\\\toption domain '$DNSMASQ_DOMAIN'" "$DHCP_CONFIG"
    else
      sed -i "/config dnsmasq/a\\\\toption domain '$DNSMASQ_DOMAIN'" "$DHCP_CONFIG"
    fi
  fi
  
  log "dnsmasq配置完成"
}

# 设置Root密码
set_root_password() {
  log "设置root密码..."
  
  # 使用openssl生成密码哈希
  PASSWORD_HASH=$(echo "$ROOT_PASSWORD" | openssl passwd -1 -stdin)
  
  # shadow文件路径
  SHADOW_FILE="/etc/shadow"
  
  # 确保文件存在
  if [ ! -f "$SHADOW_FILE" ]; then
    error "Shadow文件 $SHADOW_FILE 不存在"
  fi
  
  # 备份原始文件
  cp "$SHADOW_FILE" "${SHADOW_FILE}.bak"
  
  # 更新root密码
  sed -i "s|^root:[^:]*:|root:$PASSWORD_HASH:|" "$SHADOW_FILE"
  
  log "Root密码设置完成"
}

# 配置DHCP服务
configure_dhcp() {
  log "配置DHCP服务..."
  
  # 如果IGNORE=1，则跳过DHCP配置
  if [ "$DHCP_IGNORE" = "1" ]; then
    log "DHCP_IGNORE=1，跳过DHCP配置"
    return
  fi
  
  # DHCP配置文件路径
  DHCP_CONFIG="/etc/config/dhcp"
  
  # 确保文件存在
  if [ ! -f "$DHCP_CONFIG" ]; then
    error "DHCP配置文件 $DHCP_CONFIG 不存在"
  fi
  
  # 已经备份过文件，不需要再次备份
  
  # 如果DHCP_FORCE=1或未设置，则配置DHCP
  if [ "$DHCP_FORCE" = "1" ] || [ -z "$DHCP_FORCE" ]; then
    log "配置DHCP选项..."
    
    # 设置起始分配基址
    if [ -n "$DHCP_START" ]; then
      log "设置DHCP起始分配基址为: $DHCP_START"
      if grep -q "option start" "$DHCP_CONFIG"; then
        sed -i "/config dhcp 'lan'/,/config/ s/option start '[^']*'/option start '$DHCP_START'/g" "$DHCP_CONFIG"
      else
        sed -i "/config dhcp 'lan'/a\\\\toption start '$DHCP_START'" "$DHCP_CONFIG"
      fi
    fi
    
    # 设置最大分配数量
    if [ -n "$DHCP_LIMIT" ]; then
      log "设置DHCP最大分配数量为: $DHCP_LIMIT"
      if grep -q "option limit" "$DHCP_CONFIG"; then
        sed -i "/config dhcp 'lan'/,/config/ s/option limit '[^']*'/option limit '$DHCP_LIMIT'/g" "$DHCP_CONFIG"
      else
        sed -i "/config dhcp 'lan'/a\\\\toption limit '$DHCP_LIMIT'" "$DHCP_CONFIG"
      fi
    fi
    
    # 设置租约时间
    if [ -n "$DHCP_LEASETIME" ]; then
      log "设置DHCP租约时间为: $DHCP_LEASETIME"
      if grep -q "option leasetime" "$DHCP_CONFIG"; then
        sed -i "/config dhcp 'lan'/,/config/ s/option leasetime '[^']*'/option leasetime '$DHCP_LEASETIME'/g" "$DHCP_CONFIG"
      else
        sed -i "/config dhcp 'lan'/a\\\\toption leasetime '$DHCP_LEASETIME'" "$DHCP_CONFIG"
      fi
    fi
    
    # 设置DHCP网关
    if [ -n "$DHCP_GATEWAY" ]; then
      log "设置DHCP网关为: $DHCP_GATEWAY"
      # 检查是否已存在option 3配置
      if grep -q "list dhcp_option '3," "$DHCP_CONFIG"; then
        sed -i "/list dhcp_option '3,/c\\\\tlist dhcp_option '3,$DHCP_GATEWAY'" "$DHCP_CONFIG"
      else
        sed -i "/config dhcp 'lan'/a\\\\tlist dhcp_option '3,$DHCP_GATEWAY'" "$DHCP_CONFIG"
      fi
    fi
    
    # 设置DHCP DNS服务器
    if [ -n "$DHCP_DNS" ]; then
      log "设置DHCP DNS为: $DHCP_DNS"
      # 检查是否已存在option 6配置
      if grep -q "list dhcp_option '6," "$DHCP_CONFIG"; then
        sed -i "/list dhcp_option '6,/c\\\\tlist dhcp_option '6,$DHCP_DNS'" "$DHCP_CONFIG"
      else
        sed -i "/config dhcp 'lan'/a\\\\tlist dhcp_option '6,$DHCP_DNS'" "$DHCP_CONFIG"
      fi
    fi
  else
    log "DHCP_FORCE不等于1，跳过DHCP详细配置"
  fi
  
  log "DHCP服务配置完成"
}

# 重启网络服务
restart_services() {
  log "重启网络服务..."
  
  # 重启网络服务
  /etc/init.d/network restart
  
  # 重启DHCP服务
  /etc/init.d/dnsmasq restart
  
  log "服务重启完成"
}

# 主函数
main() {
  log "OpenWrt初始化配置开始..."
  
  # 检查必要的环境变量
  check_required_vars
  
  # 配置LAN接口
  configure_lan
  
  # 配置dnsmasq
  configure_dnsmasq
  
  # 设置Root密码
  set_root_password
  
  # 配置DHCP服务
  configure_dhcp
  
  # 重启服务
  restart_services
  
  log "OpenWrt初始化配置完成!"
}

# 执行主函数
main
