#!/bin/bash

# V2Ray 代理测试脚本
# 用于验证代理是否正常工作

HA_IP=${1:-"192.168.0.100"}  # Home Assistant IP，请替换为实际IP
SOCKS_PORT=10808
HTTP_PORT=10809

echo "=== V2Ray 代理连通性测试 ==="
echo "Home Assistant IP: $HA_IP"
echo ""

# 测试 SOCKS5 代理连通性
echo "1. 测试 SOCKS5 代理连通性..."
if curl -s --connect-timeout 5 --socks5 $HA_IP:$SOCKS_PORT http://httpbin.org/ip > /tmp/socks_test 2>/dev/null; then
    echo "   ✅ SOCKS5 代理连接成功"
    echo "   IP: $(cat /tmp/socks_test | grep -o '"origin": "[^"]*' | cut -d'"' -f4)"
else
    echo "   ❌ SOCKS5 代理连接失败"
fi

echo ""

# 测试 HTTP 代理连通性  
echo "2. 测试 HTTP 代理连通性..."
if curl -s --connect-timeout 5 --proxy $HA_IP:$HTTP_PORT http://httpbin.org/ip > /tmp/http_test 2>/dev/null; then
    echo "   ✅ HTTP 代理连接成功"
    echo "   IP: $(cat /tmp/http_test | grep -o '"origin": "[^"]*' | cut -d'"' -f4)"
else
    echo "   ❌ HTTP 代理连接失败"
fi

echo ""

# 测试国外网站访问（应该走代理）
echo "3. 测试国外网站访问（应该走代理）..."
if curl -s --connect-timeout 10 --socks5 $HA_IP:$SOCKS_PORT https://www.google.com > /dev/null 2>&1; then
    echo "   ✅ Google 访问成功（通过代理）"
else
    echo "   ❌ Google 访问失败"
fi

if curl -s --connect-timeout 10 --socks5 $HA_IP:$SOCKS_PORT https://www.youtube.com > /dev/null 2>&1; then
    echo "   ✅ YouTube 访问成功（通过代理）"
else
    echo "   ❌ YouTube 访问失败"
fi

echo ""

# 测试国内网站访问（应该直连）
echo "4. 测试国内网站访问..."
if curl -s --connect-timeout 5 --socks5 $HA_IP:$SOCKS_PORT https://www.baidu.com > /dev/null 2>&1; then
    echo "   ✅ 百度访问成功"
else
    echo "   ❌ 百度访问失败"
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "如果国外网站无法访问，请检查："
echo "1. V2Ray 日志中的路由信息"
echo "2. 选择的节点是否正常工作"
echo "3. 订阅是否包含有效的节点"
echo ""
echo "常用测试命令："
echo "curl -x socks5://$HA_IP:$SOCKS_PORT https://httpbin.org/ip"
echo "curl -x http://$HA_IP:$HTTP_PORT https://httpbin.org/ip"