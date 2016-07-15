require('gui')
local touches = {}

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

printTable = function (iterTable)
 for elName, elValue in pairs(iterTable) do
  p((string.match(tostring(type(elName)),'[sn][tu]') and elName or tostring(type(elName)) ).. ': ' .. (tostring(elValue)))
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

function clear()
 love.graphics.setColor(40,40,40)
 love.graphics.rectangle(
 	'fill', 0, 0, win.w, win.h
 )
end

function love.load()
	love.window.setMode(win.w, win.h)
	w, h = love.window.getMode()
	buildFace(face)
end

function love.touchpressed( id, x, y, dx, dy, pressure )
 touches[id] = 
 	x .. ':' ..   y .. ':' ..  
 	dx .. ':' ..   dy  .. ':' ..
  pressure
end

function love.touchmoved( id, x, y, dx, dy, pressure )
 touches[id] = 
 	x .. ':' ..   y .. ':' ..  
 	dx .. ':' ..   dy  .. ':' ..
  pressure
end

function love.touchreleased( id, x, y, dx, dy, pressure )
 touches[id] = null
end

function love.draw()
	clear()
	p('kek', 'reset')
	face:draw()
	padInit(face.elements)
	-- printTable(face.elements)
	pi(face.elements, ipairs, 'freq')
 printTable(touches)
end
