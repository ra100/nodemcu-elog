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
  .. "nodemcu_vdd33{graphname=\"nodemcu\",instance=\"power\",label=\"vdd33\",type=\"gauge\"} " .. tostring(adc.readvdd33()/1000) .. "\n"
  .. "# HELP nodemcu_uptime nodeMCU uptime\n"
  .. "# TYPE nodemcu_uptime counter\n"
  .. "nodemcu_uptime{graphname=\"nodemcu\",instance=\"power\",label=\"uptime\",type=\"counter\"} " .. tostring(tmr.time()) .. "\n";
  return d
end

function push_metrics(cb)
  http.post(PUSHGATEWAY,
  'Content-Type: text/plain; version=0.0.4\r\n',
  get_metrics(),
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
      tmr.alarm(2, 10*1000, 0, push_metrics)
    else
      print("Metrics pushed")
      collectgarbage()
      if not cb == nil then
        cb()
      end
    end
  end)
end

function restart()
  node.restart();
end

elog.init(PIN)
tmr.alarm(3, PUSHINTERVAL * 1000, 1, push_metrics)

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
  wifi.sta.eventMonStop("unreg all")
  print(wifi.sta.getip())
end)

wifi.sta.eventMonStart()

tmr.alarm(1, RESTARTINTERVAL * 1000, 1, function()
  if (elog.getCounter() == counter) then
    push_metrics(restart)
  else
    counter = elog.getCounter()
  end
end)
