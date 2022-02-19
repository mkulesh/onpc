If a connection problem occurs:
- ensure that your phone and your receiver are connected to the same WLAN.
- ensure that you use the latest firmware version on your receiver. If not, update the firmware.
- many people reports that Onkyo firmware may work unstable and the factory reset of the Onkyo 
device sometime helps. If the APP previously worked but suddenly can not connect the Onkyo device 
anymore, please performs the factory reset on the device.
- WLAN may have a huge latency and the APP may need more time to connect the Onkyo device. It it 
is possible please temporary connect your receiver to the router via cable and observe whether 
it will work more stable or not.
- If you receiver is connected to the WLAN and you use dual-band router. In the case if Onkyo 
device is a dual channel device as well, you shall be careful with the dual band configuration 
on your receiver. People report if WIFI 2.5GHz & 5GHz are configured separately (means independent 
from each other but with the same password that allows to set thoroughly the channels) the Onkyo 
device can not keep a stable connection. Please combine 2.5GHz & 5GHz channels together with only 
one password for both and set the channel width frequency to 20MHz (HT20).

If you use VPN: check whether VPN clients are located in a own IP address subnet range than the regular LAN/WLAN clients. In this case you need to setup a port forwarding for the port 60128 on your VPN server. Two routes (a forward route and a reverse route) shall be configured.
If only forward route exist, the ping to the Onkyo may be possible, but the receiver will discard requests from clients outside the subnet range. In order to prevent this situation, a "masquerading" shall be allowed for the port 60128 on the VPN server. "masquerading" can be enabled in several ways:
- Using iptables directly (the most important flag is here -j MASQUERADE)
```
iptables -t nat -A POSTROUTING -o $INTERFACE_LAN -s $IP_RANGE_VPN -d $IP_ONKYO/32 -m multiport -p tcp --dport 80,60128 -j MASQUERADE
``` 
- Using firewall-cmd (if presented)
```
firewall-cmd --zone=external --add-masquerade --permanent
```