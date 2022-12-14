#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Error: ${plain} must be root to run this script! \n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "System version not detected by ${red}, please contact the script author! ${plain}\n" && exit 1
fi

arch=$(arch)
file_name="64"

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red} failed to detect schema, use default schema: ${arch}${plain}"
fi

echo "Architecture: ${arch}"

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "This software does not support 32-bit system (x86), please use 64-bit system (x86_64), if the detection is wrong, please contact the author"
    exit -1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Please use CentOS 7 or higher! ${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Please use Ubuntu 16 or later! ${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Please use Debian 8 or higher! ${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install wget curl tar -y
    else
        apt install wget curl tar -y
    fi
}

#This function will be called when user installed x-ui out of sercurity
config_after_install() {
    echo -e "${yellow}For security reasons, the port and account password need to be changed after installation/update ${plain}"
    read -p "Are you sure to continue? [y/n]": config_confirm
    if [[ x"${config_confirm}" == x"y" || x"${config_confirm}" == x"Y" ]]; then
        read -p "Please set your account name:" config_account
        echo -e "${yellow}Your account name will be set to: ${config_account}${plain}"
        read -p "Please set your account password:" config_password
        echo -e "${yellow}Your account password will be set to: ${config_password}${plain}"
        read -p "Please set the panel access port:" config_port
        echo -e "${yellow}Your panel access port will be set to: ${config_port}${plain}"
        echo -e "${yellow}Confirm setting, setting ${plain}"
        /usr/local/x-ui/x-ui setting -username ${config_account} -password ${config_password}
        echo -e "${yellow}Account password setting completed${plain}"
        /usr/local/x-ui/x-ui setting -port ${config_port}
        echo -e "${yellow}Panel port setting completed${plain}"
    else
        echo -e "${red}Cancelled, all setting items are default settings, please modify in time${plain}"
    fi
}

download_file(){
    wget -N --no-check-certificate -O "$1" "$2"
    if [[ $? -ne 0 ]]; then
        echo -e "${red} failed to download x-ui v$1"
        exit 1
    fi
}

download_files(){
    FILE_XRAY=/usr/local/x-ui-data/xray.tar.xz
    FILE_XUI=/usr/local/x-ui-data/x-ui.tar.xz

    if [ -f "$FILE_XRAY" ]; then
        echo "$FILE_XRAY exists."
    else
        download_file "$FILE_XRAY" "https://github.com/MortezaHajilouei/xray/raw/main/xray.tar.xz"
    fi

    if [ -f "$FILE_XUI" ]; then
        echo "$FILE_XUI exists."
    else
        download_file "$FILE_XUI" "https://github.com/MortezaHajilouei/x-ui/raw/main/x-ui.tar.xz"
    fi

    tar -xf "$FILE_XRAY" --directory /usr/local/x-ui/bin
    tar -xf "$FILE_XUI" --directory /usr/local/x-ui
    
    mv /usr/local/x-ui/bin/xray /usr/local/x-ui/bin/xray-linux-${arch}
    download_file "x-ui.service" "https://raw.githubusercontent.com/MortezaHajilouei/x-ui/main/x-ui.service"
    download_file "x-ui.sh" "https://raw.githubusercontent.com/MortezaHajilouei/x-ui/main/x-ui.sh"

}

install_x-ui() {
    systemctl stop x-ui
    cd /usr/local/

    if [[ -e /usr/local/x-ui/ ]]; then
        rm /usr/local/x-ui/ -rf
    fi

    mkdir x-ui
    mkdir x-ui/bin
    mkdir x-ui-data
    cd x-ui

    download_files

    chmod +x x-ui bin/xray*   x-ui.sh

    cp -f x-ui.service /etc/systemd/system/
    cp -f x-ui.sh /usr/bin/x-ui
    

    config_after_install

    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
    echo -e "${green}x-ui v${last_version}${plain} installation completed, panel started,"
    echo -e ""
    echo -e "How to use the x-ui management script: "
    echo -e "-------------------------------------------------------- "
    echo -e "x-ui - show admin menu (more functions)"
    echo -e "x-ui start - start the x-ui panel"
    echo -e "x-ui stop - stop the x-ui panel"
    echo -e "x-ui restart - restart the x-ui panel"
    echo -e "x-ui status - view x-ui status"
    echo -e "x-ui enable - set x-ui to boot automatically"
    echo -e "x-ui disable - cancel x-ui auto-start"
    echo -e "x-ui log - view x-ui log"
    echo -e "x-ui v2-ui - Migrate the v2-ui account data of this machine to x-ui"
    echo -e "x-ui update - update x-ui panel"
    echo -e "x-ui install - install x-ui panel"
    echo -e "x-ui uninstall - uninstall x-ui panel"
    echo -e "-------------------------------------------------------- "
}

echo -e "${green} to install ${plain}"
install_base
install_x-ui
