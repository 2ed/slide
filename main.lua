require('gui')
require('sound')
require('sensor')

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
   if not verbose then return end
   local step = -font*1.5
   local leftBorder = font*1.5
   return function(element, reset)
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
	    printTable(iterTable[elName], r, level .. '  ')
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
	love.graphics.setBackgroundColor(80,80,80)
	buildFace(face)
end

function love.touchpressed( id, x, y, dx, dy, pressure )
   touchRegister(sensor.touchTable,id,x,y,pressure)
end

function love.touchmoved( id, x, y, dx, dy, pressure )
   touchProcess(sensor.touchTable[id],x,y,dx,dy,pressure)
end

function love.touchreleased( id, x, y, dx, dy, pressure )
   touchRemove(sensor.touchTable,id)
end

function love.keypressed(key,scancode)
   touchRegister(sensor.touchTable,key,100,100,0.5)
end

function love.keyreleased(key,scancode)
      touchRemove(sensor.touchTable,key)
end

function love.update(dt)
   
end

function love.draw()
	p('kek', 'reset')
	face:draw()
	touchDraw(sensor.touchTable)
	padInit(face.elements)	
	
	-- printTable(face.elements)
	pi(face.elements, ipairs, 'freq')
	printTable(sensor.touchTable,'r')
end

