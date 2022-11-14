# x-ui

xray panel supporting multi-protocol, **Multi-lang (English,Chinese)**, **IP Restrication Per Inbound**

# Enable IP Restrictions Per Inbound
1 - open panel settings and tab xray related settings put this to first of json :
 ```json
 { 
 ...
 
 "log": {
    "loglevel": "warning", 
    "access": "./access.log"
  },
  
 ...
 "api": ...
```
- change access log path as you want

2 - add **IP limit and Unique Email** for inbound(vmess & vless)

# Install & Upgrade

```
bash <(curl -Ls https://raw.githubusercontent.com/mortezahajilouei/x-ui/master/install.sh)
```

> If your server cpu architecture is not `amd64` replace another architecture

```
cd /root/
rm x-ui/ /usr/local/x-ui/ /usr/bin/x-ui -rf
tar zxvf x-ui-linux-amd64.tar.gz
chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh
cp x-ui/x-ui.sh /usr/bin/x-ui
cp -f x-ui/x-ui.service /etc/systemd/system/
mv x-ui/ /usr/local/
systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui
```


## suggestion system

- CentOS 7+
- Ubuntu 16+
- Debian 8+

