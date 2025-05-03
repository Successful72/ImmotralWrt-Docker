#!/bin/bash

# 检查所有必需的环境变量是否存在
if [ -z "$LAN_IP" ] || [ -z "$LAN_MASK" ] || [ -z "$LAN_GATEWAY" ] || [ -z "$LAN_DNS" ]; then
    echo "缺少必要的网络环境变量。请检查LAN_IP、LAN_MASK、LAN_GATEWAY和LAN_DNS是否都已设置。"
    exit 1
fi

# 临时文件保存修改内容
tmp_file=$(mktemp)

# 读取原始99-init-settings文件内容
cat /etc/uci-defaults/99-init-settings > $tmp_file

# 找到exit 0所在的行，获取它之前的空行位置
last_empty_line=$(grep -n '^$' /etc/uci-defaults/99-init-settings | tail -n 1 | cut -d: -f1)

# 在空行位置插入新的配置信息
if [ -n "$last_empty_line" ]; then
    {
        # 设置LAN口网络配置
        echo "设置LAN口网络配置..."
        echo "uci set network.lan.ipaddr='$LAN_IP'"
        echo "uci set network.lan.netmask='$LAN_MASK'"
        echo "uci set network.lan.gateway='$LAN_GATEWAY'"
        echo "uci set network.lan.dns='$LAN_DNS'"

        # 判断是否需要修改DHCP服务的ignore值
        if [ "$DHCP_IGNORE" = "1" ]; then
            echo "禁用LAN口DHCP服务..."
            echo "uci set network.lan.dhcp='disabled'"
            echo "uci set network.lan.dhcp_ignore='1'"
        elif [ "$DHCP_IGNORE" = "0" ]; then
            # 如果DHCP_IGNORE为0，检查DHCP_FORCE并根据值进行处理
            if [ "$DHCP_FORCE" = "1" ]; then
                echo "启用强制DHCP..."
                echo "uci set dhcp.lan.force='1'"
            fi
            # 设置DHCP服务的起始地址、限制数目、租期等
            if [ -n "$DHCP_START" ]; then
                echo "uci set dhcp.lan.start='$DHCP_START'"
            fi
            if [ -n "$DHCP_LIMIT" ]; then
                echo "uci set dhcp.lan.limit='$DHCP_LIMIT'"
            fi
            if [ -n "$DHCP_LEASETIME" ]; then
                echo "uci set dhcp.lan.leasetime='$DHCP_LEASETIME'"
            fi
            if [ -n "$DHCP_GATEWAY" ]; then
                echo "uci set dhcp.lan.gateway='$DHCP_GATEWAY'"
            fi
            if [ -n "$DHCP_DNS" ]; then
                echo "uci set dhcp.lan.dns='$DHCP_DNS'"
            fi
        fi

        # 设置dnsmasq相关配置
        if [ -n "$DNSMASQ_LOCAL" ]; then
            echo "设置DNSMASQ_LOCAL..."
            echo "uci set dhcp.lan.dnsmasq.local='$DNSMASQ_LOCAL'"
        fi

        if [ -n "$DNSMASQ_DOMAIN" ]; then
            echo "设置DNSMASQ_DOMAIN..."
            echo "uci set dhcp.lan.dnsmasq.domain='$DNSMASQ_DOMAIN'"
        fi

        # 提交配置并重启网络
        echo "uci commit"
        echo "/etc/init.d/network restart"
    } >> $tmp_file

    # 确保exit 0在文件最后
    echo "exit 0" >> $tmp_file

    # 用更新后的内容覆盖原文件
    mv $tmp_file /etc/uci-defaults/99-init-settings
else
    echo "未找到合适的空行位置，脚本无法继续执行"
    exit 1
fi

# 使用正确的启动命令启动系统
echo "系统正在启动..."
exec /sbin/init
