$${WRAPPER} delete interfaces ethernet `/bin/ip -o link | /bin/grep '${mac}'| /usr/bin/awk -F ':' '{print $2}'`
$${WRAPPER} set interfaces ethernet `/bin/ip -o link | /bin/grep '${mac}'| /usr/bin/awk -F ':' '{print $2}'` address ${ip}${(ip == "dhcp" ? "" : join("", list("/", netbits)))}
