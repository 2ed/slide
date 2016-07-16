touches = {
   
}

touches.__index = function(t,id)
   return 
end

touches.__newindex = function(t,i,v)
   rawset(t,i,v)
end

setmetatable(touches,touches)

touchRegister = function(touchTable,id,x,y,pressure)
   touchTable[id] = {
      id = id,
      x = x,
      y = y,
      pressure = pressure,
   }
end

touchProcess = function(tch, x, y, dx, dy, id)
   
end
