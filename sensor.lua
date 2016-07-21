require("gui")
sensor = {}

-- Dropped Down
pads = { 
   -- E
   {btn = {}, str = {}, freq = 1318.51},
   -- C#
   {btn = {}, str = {}, freq = 1108.73},
   -- A
   {btn = {}, str = {}, freq = 880},
   -- E
   {btn = {}, str = {}, freq = 659.25},
   -- A
   {btn = {}, str = {}, freq = 440},
}


padInit = function(padList)
 for i, pad in ipairs(padList) do
    for j = 1, 5 do
       pad.btn[j] = {}
       pad.btn[j].freq = setFreq(pad.freq,1200*(j-4))
    end
 end
end

sensor.touches = {}


--[[ 

So, here's the plan:
Once you hit the button/pad you are 
sticked  to it until the finger is released,
unless you are strumming to neighbouring button.

Rows mean initial state, cols -- next state.
Aaand, opposite when released.

           ---------------------------------
           || empty   |   pad   |  button  |
--------------------------------------------
--------------------------------------------
| was empty||   do    | reg ID  |  reg ID  |
| (Pressed || nothing |set Pitch|   play   |
| or moved)||         |         |          |
--------------------------------------------
| was pad  ||   do    | update  |    do    | 
| (moved)  || nothing |pos Pitch|  nothing | 
--------------------------------------------
--------------------------------------------
| to empty ||   do    | rem ID  |  rem ID  | 
|(Released)|| nothing |  set 0  |   stop   | 
|          ||         |  Pitch  |          |
--------------------------------------------


--]]

sensor.register = function(touchTable,id,x,y,pressure, moved)
   local newTouch = sensor.check(x,y,pressure)
--   local previousTouch = sensor.touch[id]
   if not newTouch and not sensor.touches[id] then
      return
   elseif not newTouch and sensor.touches[id]
      and not moved
   then
      -- if
      stopNoise(sensor.touches[id])
   elseif newTouch and not sensor.touches[id]
    then
      touchTable[id] = newTouch
      if newTouch.bType == 'btn' then
	 makeNoise(sensor.touches[id])
      end
   elseif newTouch.row ~= sensor.touches[id].row
      and newTouch.bType == 'btn'
   then
      stopNoise(sensor.touches[id])
      touchTable[id] = newTouch
      if newTouch.bType == 'btn' then
	 makeNoise(sensor.touches[id])
      end
   else
      if newTouch.bType == 'btn' then
	 makeNoise(sensor.touches[id])
      end
   end
end

sensor.process = function(tch, x, y, dx, dy, pressure)
  -- tch = sensor.check(x,y,pressure)
end

sensor.remove = function(touchTable,id)
   touchTable[id] = null
end

sensor.draw = function(touchTable)
   local radius = win.h/5
   for id, t in pairs(touchTable) do
      love.graphics.setColor(100,255,100,150)
      love.graphics.circle("fill", t.x, t.y, t.pressure*radius,20)
   end
end

function sensor.check(x,y,pressure)
   local state = null
   local t = face.elements
   local   posX = null
   for i, el in ipairs(t) do
      if el.y < y and y < el.y + el.h then
	 for j = 1,2 do
	    local block = el.elements[j]
	    if block.x < x
	       and x < block.x + block.w
	    then
	       posX =  (x - block.x)/block.w 
	    
	       state = {
		  row = i,
		  x = x,
		  y = y,
		  pressure = pressure,
		  bType = j == 1  -- 1 or 2
		     and 'pad'
		     or 'btn',
		  pos = j == 1
		     and (posX + 1)
		     or math.floor(posX*5  + 1)}
	    end
	 end
      end
   end
   -- return i, j, posX
   return state
end
