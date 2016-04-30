# NodeMCU Power meter

Nodemcu script that logs power consumption pushes metrics to
prometheus.io pushgateway.

## Notes

elog.lua is inspired by/modified code from
[Power Meter pulse logger with ESP8266 running NodeMCU](http://www.thalin.se/2015/05/power-meter-pulse-logger-with-esp8266.html).

## Requirements

-   prometheus.io

-   prometheus pushgateway

-   NodeMCU module

    -   firmware 1.5.1 newer than 2016/01/15 - float, with modules: node, file,
    gpio, wifi, net, tmr, http - <http://nodemcu-build.com/>

-   Analog Light Intensity Sensor Module 5528 Photo Resistor for
AVR Arduino UNO (or similar) [on ebay](http://www.ebay.com/itm/200982532672)

## Usage

-   Connect sensor to nodemcu, GND<->GND, VCC<->3V, SIG<->D1.

-   modify `config.default.lua` a file and save it as `config.lua`

    -   `PIN` - pin number default 1 for D1

    -   `MIN_PW` - minimum wait time till script registers new impulse
    (prevents logging light echo)

    -   `SSID` - your WiFi SSID

    -   `PASSWORD` - your WiFi password

    -   `GATEWAYIP` - your network gateway (IP address of router)

    -   `IP` - static IP you want to set for nodemcu
    (connects faster without using DHCP)

    -   `REFRESHINTERVAL` - in seconds how often should logger detect if
    logging is still working, if counter doesn't increase value for X seconds
    nodemcu restarts

    -   `PUSHGATEWAY` - url of pushgateway server

    -   `PUSHINTERVAL` - how often should metrics be pushed (in seconds)

-   Upload all `.lua` files to nodemcu and restart

## License

GNU GPLv3