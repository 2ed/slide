
win = {}
-- win.w, win.h = 960, 540 -- love.window.getMode() 
win.w, win.h = love.window.getMode()
-- love.window.setMode(win.w, win.h)
-- w, h = love.window.getMode() -- Weird trick for small resolution screens

x0, y0 = 0, 0
face = {
	mode    = 'fill',
	shape   = 'rectangle',
	color   = {40,40,40},
	padding = {t = 0, b = 0, l = 0, r = 0},
	margin  = {t = 15, b = 10, l = 0, r = 0},
	radius  = 80,
	segments = 10
}
face.x = 0 + face.margin.l*win.w/100
face.y = 0 + face.margin.t*win.h/100
face.w = win.w*(1 - (face.margin.r + face.margin.l)/100)
face.h = win.h*(1 - (face.margin.t + face.margin.b)/100)
-- face.elements = {}

face.draw = function(self)
 local drawFunc = self.shape == 'round'
   and love.graphics.circle or love.graphics.rectangle 
 love.graphics.setColor(self.color)
 drawFunc(
 	self.mode,
 	self.x + (self.shape == 'round' and self.w/2 or 0),
 	self.y + (self.shape == 'round' and self.h/2 or 0),
 	self.shape == 'round' and self.h/2 or self.w, -- self.radius 
	self.shape == 'round' and  self.segments or self.h
	)
 if self.elements then
	for i,el in ipairs(self.elements) do 
		el:draw()
	end
 end
end

face.newElement = function(self, o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.__newindex = function(table, key, value)
		rawset(table, key, value)
	end
	o.elements = {}
	return o
end

face.split = function(self, parts, align, template, initPart)
   local template = template or {}
   self.elements = self.elements or {}
   local xPlus, yPlus = 0, 1
   if align == 'h' or not align then
      xPlus, yPlus = 1, 0
   end
--   if string.sub(parts, -1) == '%' then
   local width  = self.w*
      (1 - (self.padding.l + self.padding.r)/100)/(parts^xPlus)
--      *tonumber(string.sub(parts,1,-2))
   local height = self.h*
      (1 - (self.padding.t + self.padding.b)/100)/(parts^yPlus)
   
   for i= initPart or 1, parts do
      self.elements[i] = self:newElement()
      local el = self.elements[i] 
      el.mode    = template.mode    or 'fill'
      el.shape   = template.shape   or 'shape'
      el.color   = template.color   or {40,100,100}
      el.margin  = template.margin  or
	 {t =  0, b =  0, l = 0, r =  0 } 
      el.padding = template.padding or
	 {t =  0, b =  0, l = 0, r =  0}
      el.x = self.x + self.padding.l*self.w/100
	 + el.margin.l*width/100 + xPlus*(i - 1)*width 
      el.y = self.y + self.padding.t*self.h/100
	 + el.margin.t*height/100 + yPlus*(i - 1)*height 
      el.w = width  * (1 - (el.margin.l + el.margin.r)/100)
      el.h = height * (1 - (el.margin.t + el.margin.b)/100)
   end
   local width  = self.w*
      (1 - (self.padding.l + self.padding.r)/100)/(parts^xPlus)
   local height = self.h*
      (1 - (self.padding.t + self.padding.b)/100)/(parts^yPlus)

end

buildFace = function(face)
	face:split(5,'v',
   {
	   margin = {t = 10, b = 10, l = 0.5, r = 0}, 
		  color = {80,180,230}
	 	}
	)
	for i, el in ipairs(face.elements) do
		el:split(2,'h', 
			  {color = {40,40,40},
			  margin = {t = 5, b = 5, l = 2, r = 5} })
		face.pad = el.elements[1]
		face.btn = el.elements[2]
		el.elements[1].margin = {t = 20, b = 20, l = 2, r = 80}
		el.elements[1]:split(12,'h', 
			{
				color = {120,80,80}, 
				shape = 'rectangle',
				mode = 'line',
		  margin = {t = 0, b = 0, l = 0, r = 0}
			})
		-- el.elements[2].margin = {t = 0, b = 0, l = 0, r = 0}
		el.elements[2].color = {255,255,255}
		el.elements[2]:split(5,'h', 
			{
			--	color = {255,230,153}, 
			 color = {230, 191, 81},
				shape = 'round',
		  -- margin = {t = 0, b = 0, l = 0, r = 0}
			})
	end
end
