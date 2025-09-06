#!/usr/bin/env python3
import base64
import json
import sys
import urllib.parse

def parse_vmess(vmess_url):
    try:
        encoded = vmess_url.replace('vmess://', '')
        decoded = base64.b64decode(encoded + '=' * (4 - len(encoded) % 4)).decode('utf-8')
        vmess_config = json.loads(decoded)
        outbound = {
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": vmess_config.get("add", ""),
                        "port": int(vmess_config.get("port", 443)),
                        "users": [
                            {
                                "id": vmess_config.get("id", ""),
                                "alterId": int(vmess_config.get("aid", 0)),
                                "security": vmess_config.get("scy", "auto")
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {},
            "tag": f"vmess-{vmess_config.get('ps', 'server')}"
        }

        net = vmess_config.get("net", "tcp")
        if net == "ws":
            outbound["streamSettings"] = {
                "network": "ws",
                "wsSettings": {
                    "path": vmess_config.get("path", "/"),
                    "headers": {"Host": vmess_config.get("host", "")}
                }
            }
        elif net == "tcp" and vmess_config.get("type") == "http":
            outbound["streamSettings"] = {
                "network": "tcp",
                "tcpSettings": {"header": {"type": "http","request":{"path":[vmess_config.get("path","/")]}}}
            }

        if vmess_config.get("tls") == "tls":
            outbound["streamSettings"]["security"] = "tls"
            outbound["streamSettings"]["tlsSettings"] = {
                "serverName": vmess_config.get("sni", vmess_config.get("add", ""))
            }

        return outbound, vmess_config.get('ps', f"vmess-{vmess_config.get('add','unknown')}")
    except Exception as e:
        print(f"Error parsing vmess URL: {e}", file=sys.stderr)
        return None, None

def parse_vless(vless_url):
    try:
        parsed = urllib.parse.urlparse(vless_url)
        params = urllib.parse.parse_qs(parsed.query)
        outbound = {
            "protocol": "vless",
            "settings": {
                "vnext": [
                    {
                        "address": parsed.hostname,
                        "port": parsed.port or 443,
                        "users": [{"id": parsed.username, "encryption": params.get("encryption", ["none"])[0]}]
                    }
                ]
            },
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
            outbound["streamSettings"] = {
                "network": "grpc",
                "grpcSettings": {"serviceName": params.get("serviceName", [""])[0]}
            }

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
    try:
        parsed = urllib.parse.urlparse(trojan_url)
        params = urllib.parse.parse_qs(parsed.query)
        outbound = {
            "protocol": "trojan",
            "settings": {"servers":[{"address": parsed.hostname,"port": parsed.port or 443,"password": parsed.username}]},
            "streamSettings": {"security": "tls","tlsSettings": {"serverName": params.get("sni",[parsed.hostname])[0]}},
            "tag": f"trojan-{urllib.parse.unquote(parsed.fragment or parsed.hostname)}"
        }
        return outbound, urllib.parse.unquote(parsed.fragment or f"trojan-{parsed.hostname}")
    except Exception as e:
        print(f"Error parsing trojan URL: {e}", file=sys.stderr)
        return None, None

def parse_ss(ss_url):
    try:
        url_content = ss_url.replace('ss://','')
        if '#' in url_content:
            config_part, name = url_content.split('#',1)
            name = urllib.parse.unquote(name)
        else:
            config_part = url_content
            name = "shadowsocks"

        if '@' in config_part:
            auth_part, server_part = config_part.split('@',1)
            try:
                decoded_auth = base64.b64decode(auth_part + '='*(4-len(auth_part)%4)).decode('utf-8')
                method, password = decoded_auth.split(':',1)
            except:
                method, password = auth_part.split(':',1)
            server, port = server_part.split(':',1)
        else:
            decoded = base64.b64decode(config_part + '='*(4-len(config_part)%4)).decode('utf-8')
            auth_server = decoded.split('@')
            method, password = auth_server[0].split(':',1)
            server, port = auth_server[1].split(':',1)

        outbound = {
            "protocol":"shadowsocks",
            "settings":{"servers":[{"address":server,"port":int(port),"method":method,"password":password}]},
            "tag": f"ss-{name}"
        }
        return outbound, name
    except Exception as e:
        print(f"Error parsing shadowsocks URL: {e}", file=sys.stderr)
        return None, None

def generate_v2ray_config(outbounds, socks_port, http_port, log_level, enable_node_selection=True):
    outbound_tags = [ob["tag"] for ob in outbounds]
    config = {
        "log":{"loglevel": log_level},
        "inbounds":[
            {"port":socks_port,"protocol":"socks","settings":{"auth":"noauth","udp":True},"tag":"socks-in"},
            {"port":http_port,"protocol":"http","settings":{},"tag":"http-in"}
        ],
        "outbounds": outbounds + [
            {"protocol":"freedom","settings":{},"tag":"direct"},
            {"protocol":"blackhole","settings":{"response":{"type":"http"}},"tag":"block"}
        ],
        "routing":{
            "domainStrategy":"IPIfNonMatch",
            "rules":[
                {"type":"field","outboundTag":"direct","domain":["geosite:private"]},
                {"type":"field","outboundTag":"direct","ip":["geoip:private"]},
                {"type":"field","outboundTag":"block","domain":["geosite:category-ads-all"]}
            ]
        }
    }

    if enable_node_selection and outbound_tags:
        main_tag = outbound_tags[0]
        config["routing"]["rules"].append({"type":"field","outboundTag":main_tag,"network":"tcp,udp"})

    return config

def main():
    if len(sys.argv) < 6:
        print("Usage: parse_subscription.py <input_file> <output_file> <socks_port> <http_port> <log_level> [selected_node] [enable_node_selection]", file=sys.stderr)
        sys.exit(1)

    input_file, output_file, socks_port, http_port, log_level = sys.argv[1:6]
    socks_port, http_port = int(socks_port), int(http_port)
    selected_node = int(sys.argv[6]) if len(sys.argv)>6 else 0
    enable_node_selection = sys.argv[7].lower()=='true' if len(sys.argv)>7 else True

    try:
        with open(input_file,'r',encoding='utf-8') as f:
            content=f.read().strip()
    except Exception as e:
        print(f"Error reading input file: {e}", file=sys.stderr)
        sys.exit(1)

    urls = [u.strip() for u in content.split('\n') if u.strip()]
    outbounds=[]
    for url in urls:
        if url.startswith('vmess://'): ob,name=parse_vmess(url)
        elif url.startswith('vless://'): ob,name=parse_vless(url)
        elif url.startswith('trojan://'): ob,name=parse_trojan(url)
        elif url.startswith('ss://'): ob,name=parse_ss(url)
        else: print(f"Unsupported protocol in URL: {url[:20]}...",file=sys.stderr); continue
        if ob: outbounds.append(ob); print(f"Parsed: {name}",file=sys.stderr)

    if not outbounds: print("No valid configurations found",file=sys.stderr); sys.exit(1)

    if enable_node_selection:
        if 0<=selected_node<len(outbounds):
            outbounds=[outbounds[selected_node]]
        else: outbounds=[outbounds[0]]

    v2ray_config = generate_v2ray_config(outbounds, socks_port, http_port, log_level, enable_node_selection)

    try:
        with open(output_file,'w',encoding='utf-8') as f:
            json.dump(v2ray_config,f,indent=2,ensure_ascii=False)
        print(f"V2Ray config written to: {output_file}",file=sys.stderr)
    except Exception as e:
        print(f"Error writing output file: {e}",file=sys.stderr)
        sys.exit(1)

if __name__=="__main__":
    main()
