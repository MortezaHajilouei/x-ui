# x-ui

xray panel supporting multi-protocol, **Multi-lang (English,Chinese)**, **IP Restrication Per Inbound**



```
bash <(curl -Ls https://raw.githubusercontent.com/mortezahajilouei/x-ui/master/install.sh)
```
or

```
wget https://raw.githubusercontent.com/mortezahajilouei/x-ui/master/install.sh
sudo bash ./install.sh
```


# Enable IP Restrictions Per Inbound
1 - open panel settings and tab xray related settings put this to first of json :
 ```json
 { 
 "log": {
    "loglevel": "warning", 
    "access": "./access.log"
  },
 "api": ...
```
- change access log path as you want

2 - add **IP limit and Unique Email** for inbound(vmess & vless)

# Install & Upgrade

## suggestion system

- CentOS 7+
- Ubuntu 16+
- Debian 8+

