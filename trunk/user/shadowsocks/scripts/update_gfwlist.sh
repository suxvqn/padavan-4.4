#!/bin/sh

set -e -o pipefail
[ "$1" != "force" ] && [ "$(nvram get ss_update_gfwlist)" != "1" ] && exit 0
#GFWLIST_URL="$(nvram get gfwlist_url)"
logger -st "gfwlist" "Starting update..."
curl -k -s -o /etc/storage/gfwlist/gfwlist_list_origin.conf --connect-timeout 15 --retry 5 https://gitlab.com/gfwlist/gfwlist/raw/master/gfwlist.txt
rm -f /etc/storage/gfwlist/gfwlist_list.conf
base64 -d /etc/storage/gfwlist/gfwlist_list_origin.conf > /etc/storage/gfwlist/gfwlist_list.conf
count=`awk '{print NR}' /etc/storage/gfwlist/gfwlist_list.conf|tail -n1`
mtd_storage.sh save >/dev/null 2>&1
rm -f /etc/storage/gfwlist/gfwlist_list_origin.conf
logger -st "gfwlist" "Update done"
if [ $(nvram get ss_enable) = 1 ]; then
lua /etc_ro/ss/gfwcreate.lua
logger -st "SS" "重启ShadowSocksR Plus+..."
/usr/bin/shadowsocks.sh stop
/usr/bin/shadowsocks.sh start
fi
else
logger -st "gfwlist" "列表下载失败,请重试！"
fi
#rm -f /tmp/gfwlist_list.conf

