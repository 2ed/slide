require('gui')
require('sound')
require('sensor')

verbose = true

padInit = function(padList)
 for i, pad in ipairs(padList) do
  pad.state = {
  	freq = 440*2^(3-i),
  	str = {{pos = 0, id = 'top'}},
  	btn = {},
  }
 end
end

printProducer = function(font, inRow)
   local step = -font*1.5
   local leftBorder = font*1.5
   return function(element, reset)
      if not verbose then return end
      if reset then
	 step, leftBorder = -font*1.5, font*1.5
	 return 
      end
      love.graphics.setNewFont(font)
      leftBorder =  leftBorder + 
	 font*inRow*math.floor((step + font*1.5)/
	       (h - font*1.5))
      step = (step + font*1.5)%(h - font*1.5)
      love.graphics.setColor(255,255,255)
      love.graphics.print(element, leftBorder, step)
   end
end

p = printProducer(24,22)

printTable = function (iterTable, flag, level)
   level = level or ''
   for elName, elValue in pairs(iterTable) do
      p(level .. (string.match(tostring(type(elName)),'[sn][tu]')
	    and elName
	    or tostring(type(elName)) ).. ': ' .. (tostring(elValue)))
      if flag then
	 if tostring(type(iterTable[elName])) == 'table' then
	    printTable(iterTable[elName],'r', level .. '  ')
	 end
      end
   end
end

pi = function(tabl, iterFunc, ...)
 local arg = {...}
 local temp = ''
 for i, el in iterFunc(tabl) do
  for _ , val in ipairs(arg) do
   temp = temp .. ':' .. tostring(el.state[val])
  end
  p(tostring(i) .. ': ' ..temp)
  temp = ''
 end
end

function love.load()
   love.window.setMode(win.w, win.h)
   w, h = love.window.getMode()
   --   src = love.audio.newSource(sample.sound)
   --   src:setLooping(true)
   love.graphics.setBackgroundColor(80,80,80)
   buildFace(face)
   loadSound(pads)
end

function love.touchpressed( id, x, y, dx, dy, pressure )
   sensor.register(sensor.touches,id,x,y,pressure)
   if sensor.touches[id] then
      makeNoise(sensor.touches[id])
   end
end

function love.touchmoved( id, x, y, dx, dy, pressure )
   -- sensor.process(sensor.touches[id],x,y,dx,dy,pressure)
    sensor.register(sensor.touches,id,x,y,pressure)
end

function love.touchreleased( id, x, y, dx, dy, pressure )
   if sensor.touches[id] then
      stopNoise(sensor.touches[id])
   end
   sensor.remove(sensor.touches,id)
end

function love.keypressed(key,scancode)
   sensor.register(sensor.touches,
		   key,
		   string.byte(key)*4,
		   string.byte(key)*4,
		   0.5)
   if key == 'z' then
     -- makeNoise(touchTable, id)
   elseif key == 'x' then
      -- src:setPitch(2)
   end
end

function love.keyreleased(key,scancode)
   if key == 'z' then
      --      stopNoise(sensor.touches[id])
   end
   if sensor.touches[key] then
      stopNoise(sensor.touches[key])
   end
   sensor.remove(sensor.touches,key)
end

function love.update(dt)
   
end

function love.draw()
	p('kek', 'reset')
	face:draw()
	sensor.draw(sensor.touches)
	padInit(face.elements)	
	-- printTable(face.elements)
	pi(face.elements, ipairs, 'freq')
	printTable(pads,'r')
	printTable(sensor.touches,'r')
end

