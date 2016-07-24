require("gui")
sensor = {}

tones ={
   A4 = 440,
   E4 = 329.63,
   A3 = 220,
   D4 = 293.66,
   G3 = 196,
   C3 = 130,81,
}
-- Dropped Down
pads = { 
   -- E
--   {btn = {}, pad = {}, freq = 1318.51},
   -- C#
--   {btn = {}, pad = {}, freq = 1108.73},
   -- A
   {btn = {}, pad = {}, freq = tones.D4},
   -- E
   {btn = {}, pad = {}, freq = tones.G3},
   -- A
   {btn = {}, pad = {}, freq = tones.C3},
}


padInit = function(padList)
 for i, pad in ipairs(padList) do
    for j = 1, 5 do
       pad.btn[j] = {}
       pad.btn[j].freq = setFreq(pad.freq,1200*(j-3))
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
   if not touchTable[id] then
      -- When touch pressed
      if not newTouch then
	 -- No element is pressed
	 return
      else
	 -- Register new touch and update pad state
	 touchTable[id] = newTouch
	 sensor.add(touchTable,id)
      end
   elseif touchTable[id].bType == 'btn' 
      and newTouch and newTouch.bType == 'btn'
   then
      -- Moved from button
      -- to button
      if (newTouch.row ~= touchTable[id].row 
	      or newTouch.pos ~= touchTable[id].pos)
      then
	 -- Buttons are not the same,
	 -- reset state to new
	 sensor.remove(touchTable, id)
	 touchTable[id] = newTouch
	 sensor.add(touchTable, id)
      else
	 -- Same button,
	 -- set volume from pressure
	 
	 --	 pads[newTouch.row].btn[newTouch.pos].src:setVolume(
	 -- math.sqrt(pressure,10))
      end
   elseif touchTable[id].bType == 'pad'
      and pads[touchTable[id].row].pad.id == id
   then 
      -- Only pos updating
      local pad = touchTable[id]
      local xm = math.max(pad.x0,x)
      local xM = math.min(pad.x0 + pad.w,xm)
      local pos = (xM - pad.x0)/pad.w + 1
      updatePad(pad.row,id,pos)
   end
      
end

sensor.process = function(tch, x, y, dx, dy, pressure)
  -- tch = sensor.check(x,y,pressure)
end

sensor.add = function(touchTable,id)
   if touchTable[id].bType == 'btn' then
      makeNoise(touchTable[id])
   else
      updatePad(touchTable[id].row,id, touchTable[id].pos)
   end
end

sensor.remove = function(touchTable,id)
   if touchTable[id].bType == 'btn' then
      stopNoise(touchTable[id])
   elseif pads[touchTable[id].row].pad.id == id then
      -- Resetting only last pad finger
      updatePad(touchTable[id].row,'noid', 1)
   end
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
   local t = face.layout
   local posX = null
   for j, block in ipairs(t) do
      if y > block.y
	 and y < block.y + block.h
	 and x > block.x
	 and x < block.x + block.w
      then
	 for i, el in ipairs(block.elements) do
	    -- print(x, el.x, el.x + el.w, ' : ', y, el.y, el.y + el.h)
	    if y > el.y
	       and y < el.y + el.h
	       and x >  el.x
	       and x < el.x + el.w
	    then
	       posX =  align == 'v'
		  and (x - el.x)/el.w
		  or (y - el.y)/el.h
	       state = {
	       row = 4 - i,
	       x = x,
	       y = y,
	       x0 = el.x,
	       y0 = el.y,
	       w = el.w,
	       h = el.h,
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
   return state
end

--[[
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
		  x0 = block.x,
		  y0 = block.y,
		  w = block.w,
		  h = block.h,
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
--]]
