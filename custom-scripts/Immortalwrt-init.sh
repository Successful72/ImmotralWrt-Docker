#!/bin/sh

# OpenWrt初始化配置脚本
# 根据环境变量自动配置OpenWrt

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "开始执行OpenWrt初始化配置..."

# 检查必要的环境变量
if [ -z "$LAN_IPADDR" ] || [ -z "$LAN_NETMASK" ] || [ -z "$LAN_GATEWAY" ] || [ -z "$LAN_DNS" ]; then
  log "错误: 必须设置以下环境变量: LAN_IPADDR, LAN_NETMASK, LAN_GATEWAY, LAN_DNS"
  exit 1
fi

# 设置LAN接口
log "配置LAN接口..."
uci set network.lan.ipaddr="$LAN_IPADDR"
uci set network.lan.netmask="$LAN_NETMASK"
uci set network.lan.gateway="$LAN_GATEWAY"
uci set network.lan.dns="$LAN_DNS"

# 设置DNSMASQ域名相关设置
if [ -n "$DNSMASQ_LOCAL" ]; then
  log "设置DNSMASQ本地域名: $DNSMASQ_LOCAL"
  uci set dhcp.@dnsmasq[0].local="$DNSMASQ_LOCAL"
fi

if [ -n "$DNSMASQ_DOMAIN" ]; then
  log "设置DNSMASQ域名: $DNSMASQ_DOMAIN"
  uci set dhcp.@dnsmasq[0].domain="$DNSMASQ_DOMAIN"
fi

# 设置Root密码
if [ -n "$ROOT_PASSWORD" ]; then
  log "设置Root密码..."
  echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root
else
  log "警告: 未设置ROOT_PASSWORD环境变量，保持原始密码不变"
fi

# 配置DHCP服务
if [ "$IGNORE_DHCP" = "0" ]; then
  log "配置DHCP服务..."
  
  # 检查是否强制执行DHCP设置
  if [ "$FORCE_DHCP" = "1" ] || [ ! -z "$DHCP_START" -a ! -z "$DHCP_LIMIT" -a ! -z "$DHCP_LEASETIME" ]; then
    if [ -n "$DHCP_START" ]; then
      log "设置DHCP起始地址: $DHCP_START"
      uci set dhcp.lan.start="$DHCP_START"
    fi
    
    if [ -n "$DHCP_LIMIT" ]; then
      log "设置DHCP最大分配数量: $DHCP_LIMIT"
      uci set dhcp.lan.limit="$DHCP_LIMIT"
    fi
    
    if [ -n "$DHCP_LEASETIME" ]; then
      log "设置DHCP租约时间: $DHCP_LEASETIME"
      uci set dhcp.lan.leasetime="$DHCP_LEASETIME"
    fi
  else
    log "DHCP基本设置未完全提供或未强制执行，跳过DHCP基本设置"
  fi
  
  # 设置DHCP选项
  if [ -n "$DHCP_GATEWAY" ]; then
    log "设置DHCP网关选项: $DHCP_GATEWAY"
    uci add_list dhcp.lan.dhcp_option="3,$DHCP_GATEWAY"
  fi
  
  if [ -n "$DHCP_DNS" ]; then
    log "设置DHCP DNS选项: $DHCP_DNS"
    uci add_list dhcp.lan.dhcp_option="6,$DHCP_DNS"
  fi
elif [ "$IGNORE_DHCP" = "1" ]; then
  log "IGNORE_DHCP=1，跳过DHCP设置"
else 
  log "IGNORE_DHCP未设置或无效值，跳过DHCP设置"
fi

# 提交所有更改
log "提交所有配置更改..."
uci commit

# 重启相关服务
log "重启网络服务..."
/etc/init.d/network restart

log "重启DHCP服务..."
/etc/init.d/dnsmasq restart

log "OpenWrt初始化配置完成！"
