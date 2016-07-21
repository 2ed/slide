require('gui')
require('sound')
require('sensor')

verbose = true
operationSystem = love.system.getOS()
fontSize = operationSystem == "Android" and 24 or 12
win = {}

if operationSystem ~= "Android" then
   win.w, win.h = 960, 540 -- love.window.getMode() 
else
   win.w, win.h = love.window.getMode()
end
-- love.window.setMode(win.w, win.h)
-- w, h = love.window.getMode()
-- Weird trick for small resolution screens

x0, y0 = 0, 0


printProducer = function(font, inRow)
   local step = -font*1.5
   local leftBorder = font*1.5
   love.graphics.setNewFont(font)
  return function(element, reset)
      if not verbose then return end
      if reset then
	 step, leftBorder = -font*1.5, font*1.5
	 return 
      end
       leftBorder =  leftBorder + 
	 font*inRow*math.floor((step + font*1.5)/
	       (win.h - font*1.5))
      step = (step + font*1.5)%(win.h - font*1.5)
      love.graphics.setColor(255,255,255)
      love.graphics.print(element, leftBorder, step)
   end
end

p = printProducer(fontSize,22)

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

pi = function(tabl, iterFunc, freq ) -- ...)
-- local arg = {...}
 local temp = ''
 for i, el in iterFunc(tabl) do
--  for _ , val in ipairs(arg) do
    temp = temp .. ':' .. tostring(el.state[freq]) --val])
--  end
  p(tostring(i) .. ': ' ..temp)
  temp = ''
 end
end

function love.mousepressed( x, y, button, istouch )
   if operationSystem == "Android" then
      return
   end
   love.touchpressed('mouse', x, y, 0,0, 0.5)
end

function love.mousereleased( x, y, button, istouch )
   if operationSystem == "Android" then
      return
   end
   love.touchreleased('mouse', x, y, 0,0, 0.5)
end

function love.mousemoved(x,y,dx,dy,istouch)
   if operationSystem == "Android" then
      return
   end
   if sensor.touches['mouse'] then
      love.touchmoved('mouse', x, y, dx, dy, 0.5)
   end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
   sensor.register(sensor.touches,id,x,y,pressure)
   if sensor.touches[id] then
      makeNoise(sensor.touches[id])
   end
end

function love.touchmoved( id, x, y, dx, dy, pressure )
--   sensor.process(sensor.touches[id],x,y,dx,dy,pressure)
    sensor.register(sensor.touches,id,x,y,pressure)
end

function love.touchreleased( id, x, y, dx, dy, pressure )
   if sensor.touches[id] then
      stopNoise(sensor.touches[id])
   end
   sensor.remove(sensor.touches,id)
end

function love.keypressed(key,scancode)
end
function love.keyreleased(key,scancode)
end

function love.load()
   love.window.setMode(win.w, win.h)
   faceInit()
   --   w, h = love.window.getMode()
   --   src = love.audio.newSource(sample.sound)
   --   src:setLooping(true)
   love.graphics.setBackgroundColor(80,80,80)
   buildFace(face)
   padInit(face.elements)	
   loadSound(pads)
  -- sensor.link(pads,face.elements)
end

function love.update(dt)
   
end

function love.draw()
	p('kek', 'reset')
	face:draw()
	sensor.draw(sensor.touches)
	printTable(face.elements)
	pi(face.elements, ipairs, 'freq')
	printTable(pads,'r')
	printTable(sensor.touches)	-- local f,c = 220, 300
	-- p('frequency ' .. f .. ' + ' .. c .. ' cents: ' .. setFreq(f,c))
end

