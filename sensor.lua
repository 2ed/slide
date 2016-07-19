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

sensor.touches = {}

sensor.register = function(touchTable,id,x,y,pressure)
   local tId = sensor.check(x,y,pressure)
   if not tId and not sensor.touches[id] then
      return
   elseif not tId and sensor.touches[id] then
      stopNoise(sensor.touches[id])
   elseif tId and not sensor.touches[id] then
      touchTable[id] = tId
      makeNoise(sensor.touches[id])
   elseif tId.row ~= sensor.touches[id].row then
      stopNoise(sensor.touches[id])
      touchTable[id] = tId
      makeNoise(sensor.touches[id])
   else
      makeNoise(sensor.touches[id])
   end
end

sensor.process = function(tch, x, y, dx, dy, pressure)
   tch = sensor.check(x,y,pressure)
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
   for i, el in ipairs(t) do
      if el.y < y and y < el.y + el.h then
	 for block = 1,2 do
	    if el.elements[block].x < x
	       and x < el.elements[block].x + el.elements[block].w
	    then
	       local posX =  (x - el.elements[block].x)/
			el.elements[block].w 
	      
	       state = {
		  row = i,
		  x = x,
		  y = y,
		  pressure = pressure,
		  bType = block == 1  -- 1 or 2
		     and 'pad'
		     or 'btn',
		  pos = block == 1
		     and (posX + 1)
		     or math.floor(posX*5  + 1)}
	    end
	 end
      end
   end
   return state
end
