local elog = {}

local counter = 0
local timestamp = 0
local pin = 1
local cache = 'meter.txt'

function elog.counterUp()
  counter = counter + 1
  print(counter)
  file.open(cache, 'w+')
  file.writeline(counter)
  file.close()
end

function elog.pin_up(level)
  if (level == gpio.HIGH) then
    if (tmr.now() - timestamp > MIN_PW) then
      timestamp = tmr.now()
      elog.counterUp()
    end
  end
end

function elog.init(p, cf, c)
  if (c ~= nil) then counter = c end
  if (cf ~= nil) then cache = cf end
  pin = p
  gpio.mode(pin, gpio.INT)
  timestamp = tmr.now()
  gpio.trig(pin, "up", elog.pin_up)
end

function elog.getCounter()
  return counter
end

return elog