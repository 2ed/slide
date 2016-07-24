
template = {
   buttonPanel = {},
   padsPanel = {},
   background = {
--      margin = {t = 10, b = 10, l = 0.5, r = 0}, 
      color = {50, 64, 78}
   },
   panels  = {
      color = {38, 43, 43},
      margin = {t = 5, b = 5, l = 2, r = 5},
   },
   frets = {
      color = {120,80,80}, 
      shape = 'rectangle',
      mode = 'line',
      margin = {t = 0, b = 0, l = 0, r = 0},
   },   
   buttons = {
      color = {120,101, 73}, 
      --      color = {45, 74, 71},
      --      shape = 'round',
      shape = 'rectangle',
      margin = {t = 4, b = 4, l = 1, r = 1}
   }
}

buildFace = function(face)
   face:split(2,'v', template.background)
   face.elements[2].color = {8,137,123}
   for i , block in ipairs(face.elements) do 
      block:split(#pads,'v', template.panels)
      for j, el in ipairs(block.elements) do
--	 el:split(2,'h', template.panels)
	 if i == 1 then
	    el:split(12,'h',template.frets)
	 else
	    el:split(5,'h', template.buttons)
	 end
      end
   end
   face.pads = face.elements[1]
   face.buttons = face.elements[2]
end

face = {}

face = {
   mode    = 'fill',
   shape   = 'rectangle',
   --   color   = {40,40,40},
   color   = {40, 43, 45},
   padding = {t = 0, b = 0, l = 0, r = 0},
   --   margin  = {t = 15, b = 10, l = 0, r = 0},
   margin  = {t = 5, b = 0, l = 0, r = 0},
   radius  = 80,
   segments = 10
}

faceInit = function()
   face.x = 0 + face.margin.l*win.w/100
   face.y = 0 + face.margin.t*win.h/100
   face.w = win.w*(1 - (face.margin.r + face.margin.l)/100)
   face.h = win.h*(1 - (face.margin.t + face.margin.b)/100)
-- face.elements = {}
end

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
	self.__index = function(t,key)
	   if key == 'w' then
	      return t.width  * (1 - (t.margin.l + t.margin.r)/100)
	   elseif key == 'h' then
	      return t.height * (1 - (t.margin.t + t.margin.b)/100)
	   else
	      return self[key]
	   end
	end
	self.__newindex = function(t, key, value)
		rawset(t, key, value)
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
      el.width = width
      el.height = height
      -- el.w = width  * (1 - (el.margin.l + el.margin.r)/100)
      -- el.h = height * (1 - (el.margin.t + el.margin.b)/100)
   end
end

