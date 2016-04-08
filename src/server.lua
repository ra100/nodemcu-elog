local elog = require 'elog'

function get_metrics()
  local c = elog.getCounter()
  local d = "# HELP power_meter Power consumption in Wh\n"
  .. "# TYPE power_meter counter\n"
  .. "power_meter{graphname=\"power_meter\",label=\"power\",type=\"counter\"} " .. tostring(c) .. "\n"
  return d
end

function init_server()
  -- create a server
  -- 30s time out for a inactive client
  local sv = net.createServer(net.TCP, 30)

  -- server listen on 80
  sv:listen(80,function(conn)
    conn:on("receive", function(client, pl)
      if string.match(pl, "metrics") then
        -- print(pl)
        local buff = ""
        buff = buff .. "HTTP/1.1 200 OK\n"
        buff = buff .. "Content-Type:text/plain; version=0.0.4\n"
        buff = buff .. "\n"
        buff = buff .. get_metrics()
        buff = buff .. "# HELP nodemcu_heap nodeMCU heap\n"
        .. "# TYPE nodemcu_heap gauge\n"
        .. "nodemcu_elog_heap{graphname=\"nodemcu\",label=\"heap\",type=\"gauge\"} " .. tostring(node.heap()) .. "\n";
        buff = buff .. "# HELP nodemcu_vdd33 nodeMCU system voltage\n"
        .. "# TYPE nodemcu_vdd33 gauge\n"
        .. "nodemcu_elog_vdd33{graphname=\"nodemcu\",label=\"vdd33\",type=\"gauge\"} " .. tostring(adc.readvdd33()/1000) .. "\n";
        client:send(buff)
      else
        client:send("OK")
      end
      client:close()
      collectgarbage()
     end)
  end)
end

local files = file.list()
local counter = nil
if (files[CACHE]) then
  if file.open(CACHE, 'r') then
    local state = tonumber(file.read(0))
    print(state)
    file.close()
    counter = state
  end
end

elog.init(PIN, CACHE, counter)

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
  wifi.sta.eventMonStop("unreg all")
  print(wifi.sta.getip())
  init_server()
end)

wifi.sta.eventMonStart()
