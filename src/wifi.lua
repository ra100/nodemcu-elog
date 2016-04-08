wifi.setmode(wifi.STATION)
wifi.sta.config(SSID,PASSWORD)
wifi.sta.connect()
wifi.sta.setip({ip=IP,netmask="255.255.255.0",gateway=GETEWAYIP})
