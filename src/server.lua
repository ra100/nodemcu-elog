local elog = require 'elog'
local counter = 0

function get_metrics()
  local c = elog.getCounter()
  local d = "# HELP power_meter Power consumption in Wh\n"
  .. "# TYPE power_meter counter\n"
  .. "power_meter{graphname=\"power_meter\",instance=\"power\",label=\"power\",type=\"counter\"} " .. tostring(c) .. "\n"
  .. "# HELP nodemcu_heap nodeMCU heap\n"
  .. "# TYPE nodemcu_heap gauge\n"
  .. "nodemcu_heap{graphname=\"nodemcu\",instance=\"power\",label=\"heap\",type=\"gauge\"} " .. tostring(node.heap()) .. "\n"
  .. "# HELP nodemcu_vdd33 nodeMCU system voltage\n"
  .. "# TYPE nodemcu_vdd33 gauge\n"
  .. "nodemcu_vdd33{graphname=\"nodemcu\",instance=\"power\",label=\"vdd33\",type=\"gauge\"} " .. tostring(adc.readvdd33()/1000) .. "\n";
  return d
end

function push_metrics()
  http.post(PUSHGATEWAY,
  'Content-Type: text/plain; version=0.0.4\r\n',
  get_metrics(),
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
      tmr.alarm(2, 5*1000, 0, push_metrics)
    else
      print("Metrics pushed")
      collectgarbage()
    end
  end)
end

function load_counter()
  if file.exists("meter.txt") then
    if file.open("meter.txt", 'r') then
      local state = tonumber(file.read(0))
      file.close()
      counter = state
    end
  end
end

function save_counter()
  file.open("meter.txt", 'w+')
  file.writeline(counter)
  file.close()
end

load_counter()
elog.init(PIN, counter)

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
  wifi.sta.eventMonStop("unreg all")
  print(wifi.sta.getip())
  push_metrics()
  tmr.alarm(3, PUSHINTERVAL * 1000, 1, push_metrics)
end)

wifi.sta.eventMonStart()

tmr.alarm(1, RESTARTINTERVAL * 1000, 1, function()
  local c = elog.getCounter()
  if c == counter then
    push_metrics()
    save_counter()
    tmr.alarm(4, 3, 0, node.restart)
  else
    counter = c
  end
end)
