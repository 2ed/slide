require("gui")
sensor = {}

local touches = {
   
}

sensor.touchTable = touches


--[[
touches.__index = function(t,id)
   return t
end
--]]

--[[
touches.__newindex = function(t,i,v)
   rawset(t,i,v)
end
--]]

setmetatable(touches,touches)

sensor.register = function(touchTable,id,x,y,pressure)
   touchTable[id] = sensor.check(x,y,pressure)
end

sensor.process = function(tch, x, y, dx, dy, id)
   
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
	       state = {
		  row = i,
		  x = x,
		  y = y,
		  pressure = pressure,
		  bType = block == 1  -- 1 or 2
		     and 'pad'
		     or 'btn',
		  pos = (x - el.elements[block].x)/el.elements[block].w
	       }
	    end
	 end
      end
   end
   return state
end
