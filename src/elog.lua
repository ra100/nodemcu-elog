local elog = {}

local counter = 0
local pin = 1
local min_pw = 20
local pulse_detected = 0

function elog.counterUp()
  counter = counter + 1
  if DEBUG then print(counter) end
end

function elog.pin_up(level)
  if (level == gpio.HIGH) then
    pulse_detected = 1
  end
end

function elog.init(p)
  pin = p
  min_pw = MIN_PW
  gpio.mode(pin, gpio.INT)
  gpio.trig(pin, "up", elog.pin_up)
  tmr.alarm(4, MIN_PW, 1, elog.checkPulse);
end

function elog.checkPulse()
  if pulse_detected == 1 then
    elog.counterUp()
    pulse_detected = 0
  end
end

function elog.getCounter()
  return counter
end

return elog