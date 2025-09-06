#!/usr/bin/env python3
import base64
import json
import sys
import urllib.parse

def parse_vmess(vmess_url):
    """解析 vmess:// 链接"""
    try:
        encoded = vmess_url.replace('vmess://', '')
        decoded = base64.b64decode(encoded + '=' * (4 - len(encoded) % 4)).decode('utf-8')
        cfg = json.loads(decoded)
        outbound = {
            "protocol": "vmess",
            "settings": {
                "vnext": [{
                    "address": cfg.get("add", ""),
                    "port": int(cfg.get("port", 443)),
                    "users": [{
                        "id": cfg.get("id", ""),
                        "alterId": int(cfg.get("aid", 0)),
                        "security": cfg.get("scy", "auto")
                    }]
                }]
            },
            "streamSettings": {},
            "tag": f"vmess-{cfg.get('ps', cfg.get('add', 'unknown'))}"
        }
        net = cfg.get("net", "tcp")
        if net == "ws":
            outbound["streamSettings"] = {
                "network": "ws",
                "wsSettings": {"path": cfg.get("path", "/"), "headers": {"Host": cfg.get("host", "")}}
            }
        elif net == "tcp" and cfg.get("type") == "http":
            outbound["streamSettings"] = {
                "network": "tcp",
                "tcpSettings": {"header": {"type": "http", "request": {"path": [cfg.get("path", "/")]}}}
            }
        if cfg.get("tls") == "tls":
            outbound["streamSettings"]["security"] = "tls"
            outbound["streamSettings"]["tlsSettings"] = {"serverName": cfg.get("sni", cfg.get("add", ""))}
        return outbound, cfg.get('ps', f"vmess-{cfg.get('add', 'unknown')}")
    except Exception as e:
        print(f"Error parsing vmess URL: {e}", file=sys.stderr)
        return None, None

def parse_vless(vless_url):
    """解析 vless:// 链接"""
    try:
        parsed = urllib.parse.urlparse(vless_url)
        params = urllib.parse.parse_qs(parsed.query)
        outbound = {
            "protocol": "vless",
            "settings": {"vnext": [{
                "address": parsed.hostname,
                "port": parsed.port or 443,
                "users": [{"id": parsed.username, "encryption": params.get("encryption", ["none"])[0]}]
            }]},
            "streamSettings": {},
            "tag": f"vless-{urllib.parse.unquote(parsed.fragment or parsed.hostname)}"
        }
        flow = params.get("flow", [None])[0]
        if flow:
            outbound["settings"]["vnext"][0]["users"][0]["flow"] = flow
        network = params.get("type", ["tcp"])[0]
        if network == "ws":
            outbound["streamSettings"] = {
                "network": "ws",
                "wsSettings": {"path": params.get("path", ["/"])[0], "headers": {"Host": params.get("host", [""])[0]}}
            }
        elif network == "grpc":
            outbound["streamSettings"] = {"network": "grpc", "grpcSettings": {"serviceName": params.get("serviceName", [""])[0]}}
        security = params.get("security", [""])[0]
        if security == "tls":
            outbound["streamSettings"]["security"] = "tls"
            outbound["streamSettings"]["tlsSettings"] = {"serverName": params.get("sni", [parsed.hostname])[0]}
        elif security == "reality":
            outbound["streamSettings"]["security"] = "reality"
            outbound["streamSettings"]["realitySettings"] = {
                "serverName": params.get("sni", [parsed.hostname])[0],
                "fingerprint": params.get("fp", ["chrome"])[0],
                "publicKey": params.get("pbk", [""])[0],
                "shortId": params.get("sid", [""])[0]
            }
        return outbound, urllib.parse.unquote(parsed.fragment or f"vless-{parsed.hostname}")
    except Exception as e:
        print(f"Error parsing vless URL: {e}", file=sys.stderr)
        return None, None

def parse_trojan(trojan_url):
    """解析 trojan:// 链接"""
    try:
        parsed = urllib.parse.urlparse(trojan_url)
        params = urllib.parse.parse_qs(parsed.query)
        outbound = {
            "protocol": "trojan",
            "settings": {"servers": [{"address": parsed.hostname, "port": parsed.port or 443, "password": parsed.username}]},
            "streamSettings": {"security": "tls", "tlsSettings": {"serverName": params.get("sni", [parsed.hostname])[0]}},
            "tag": f"trojan-{urllib.parse.unquote(parsed.fragment or parsed.hostname)}"
        }
        return outbound, urllib.parse.unquote(parsed.fragment or f"trojan-{parsed.hostname}")
    except Exception as e:
        print(f"Error parsing trojan URL: {e}", file=sys.stderr)
        return None, None

def parse_ss(ss_url):
    """解析 ss:// 链接"""
    try:
        url_content = ss_url.replace('ss://', '')
        if '#' in url_content:
            config_part, name = url_content.split('#', 1)
            name = urllib.parse.unquote(name)
        else:
            config_part, name = url_content, "shadowsocks"
        if '@' in config_part:
            auth_part, server_part = config_part.split('@', 1)
            try:
                decoded_auth = base64.b64decode(auth_part + '=' * (4 - len(auth_part) % 4)).decode('utf-8')
                method, password = decoded_auth.split(':', 1)
            except:
                method, password = auth_part.split(':', 1)
            server, port = server_part.split(':', 1)
        else:
            decoded = base64.b64decode(config_part + '=' * (4 - len(config_part) % 4)).decode('utf-8')
            auth_server = decoded.split('@')
            method, password = auth_server[0].split(':', 1)
            server, port = auth_server[1].split(':', 1)
        outbound = {"protocol": "shadowsocks", "settings": {"servers": [{"address": server, "port": int(port), "method": method, "password": password}]},"tag": f"ss-{name}"}
        return outbound, name
    except Exception as e:
        print(f"Error parsing shadowsocks URL: {e}", file=sys.stderr)
        return None, None

def generate_v2ray_config(outbounds, socks_port, http_port, log_level, enable_node_selection=True):
    """生成完整 V2Ray 配置"""
    outbound_tags = [ob["tag"] for ob in outbounds]
    main_tag = outbound_tags[0] if enable_node_selection and outbound_tags else None

    config = {
        "log": {"loglevel": log_level},
        "inbounds": [
            {"port": socks_port, "protocol": "socks", "settings": {"auth": "noauth", "udp": True}, "tag": "socks-in"},
            {"port": http_port, "protocol": "http", "settings": {}, "tag": "http-in"}
        ],
        "outbounds": outbounds + [
            {"protocol": "freedom", "settings": {}, "tag": "direct"},
            {"protocol": "blackhole", "settings": {"response": {"type": "http"}}, "tag": "block"}
        ],
        "routing": {
            "domainStrategy": "IPIfNonMatch",
            "rules": [
                {"type": "field", "outboundTag": "direct", "domain": ["geosite:cn"]},
                {"type": "field", "outboundTag": "direct", "ip": ["geoip:cn"]},
                {"type": "field", "outboundTag": "block", "domain": ["geosite:category-ads-all"]},
            ]
        }
    }

    # 非大陆流量走代理节点
    if main_tag:
        config["routing"]["rules"].append({
            "type": "field",
            "outboundTag": main_tag,
            "domain": ["geosite:!cn"],
            "ip": ["geoip:!cn"]
        })

    return config

def main():
    if len(sys.argv) != 6:
        print("Usage: parse_subscription.py <input_file> <output_file> <socks_port> <http_port> <log_level>", file=sys.stderr)
        sys.exit(1)

    input_file, output_file, socks_port, http_port, log_level = sys.argv[1:6]
    socks_port, http_port = int(socks_port), int(http_port)

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read().strip()
    except Exception as e:
        print(f"Error reading input file: {e}", file=sys.stderr)
        sys.exit(1)

    urls = [u.strip() for u in content.split('\n') if u.strip()]
    outbounds, parsed_count = [], 0

    for url in urls:
        outbound, name = None, None
        if url.startswith('vmess://'): outbound, name = parse_vmess(url)
        elif url.startswith('vless://'): outbound, name = parse_vless(url)
        elif url.startswith('trojan://'): outbound, name = parse_trojan(url)
        elif url.startswith('ss://'): outbound, name = parse_ss(url)
        else: print(f"Unsupported protocol: {url[:20]}...", file=sys.stderr)
        if outbound:
            outbounds.append(outbound)
            parsed_count += 1
            print(f"Parsed: {name}", file=sys.stderr)

    if not outbounds:
        print("No valid configurations found", file=sys.stderr)
        sys.exit(1)

    print(f"Successfully parsed {parsed_count} nodes", file=sys.stderr)
    v2ray_config = generate_v2ray_config(outbounds, socks_port, http_port, log_level)

    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(v2ray_config, f, indent=2, ensure_ascii=False)
        print(f"V2Ray config written to: {output_file}", file=sys.stderr)
    except Exception as e:
        print(f"Error writing output file: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
