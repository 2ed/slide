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

touchRegister = function(touchTable,id,x,y,pressure)
   touchTable[id] = {
      x = x,
      y = y,
      pressure = pressure,
--      button = checkButton(x,y,pressure)
   }
   
end

touchProcess = function(tch, x, y, dx, dy, id)
   
end

touchRemove = function(touchTable,id)
   touchTable[id] = null
end

touchDraw = function(touchTable)
   local radius = win.h/5
   for id, t in pairs(touchTable) do
      love.graphics.setColor(100,255,100,150)
      love.graphics.circle("fill", t.x, t.y, t.pressure*radius,20)
--      p(tostring(id))
   end
end
