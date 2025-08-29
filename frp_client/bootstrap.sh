#!/usr/bin/env bashio
set -e

build_arch=${1:-amd64}
frp_version=${2:-0.52.0}

frp_url="https://github.com/fatedier/frp/releases/download/"
app_path="/usr/src"

function select_machine() {
    case $build_arch in
        "aarch64") echo "arm64" ;;
        "amd64") echo "amd64" ;;
        "armhf"|"armv7") echo "arm" ;;
        "i386") echo "386" ;;
        *) echo "amd64" ;;
    esac
}

function install() {
    bashio::log.info "Installing frpc"
    local machine=$(select_machine)
    local file_name="frp_${frp_version}_linux_${machine}.tar.gz"
    local file_url="${frp_url}v${frp_version}/${file_name}"
    bashio::log.info "Downloading ${file_url}"
    
    mkdir -p /tmp
    mkdir -p $app_path

    curl -o /tmp/${file_name} -sSL $file_url || {
        bashio::log.fatal "Failed to download $file_url"
        exit 1
    }

    tar xzf /tmp/${file_name} -C /tmp
    local file_dir=$(echo ${file_name} | sed 's/.tar.gz//')

    cp -f /tmp/${file_dir}/frpc ${app_path}/
    rm -rf /tmp/${file_name} /tmp/${file_dir}
}

install
