
sample = {
   cfg = {
      sec = 1,
      rate = 44100,
      bits = 16,
      channel = 1,
      amp = 0.2,
   },
}

sample.cfg.len = sample.cfg.sec*sample.cfg.rate

Oscillator = function(waveForm,freq)
   local phase = 0
   local pi2 = math.pi*2
   local osc
   if waveForm == 'sine' then
      osc = function()
	 phase = phase + pi2/sample.cfg.rate
	 if phase == pi2 then
	    phase = phase - pi2
	 end
	 return math.sin(phase*freq)
      end
   else
      local step = math.floor(sample.cfg.rate/freq)
      osc = function()
	 phase = phase + 1
	 if phase == step then
	    phase = -step
	 end
	 return phase/step
      end
   end
   return osc
end


makeNoise = function(id)
   pads[id.row].btn[id.pos].src:play()
end

stopNoise = function(id)
   pads[id.row].btn[id.pos].src:stop()
end

updatePad = function(rowNum, newId, pos)
   local row = pads[rowNum]
   row.pad.pos = pos
   row.pad.id = newId
   for i, btn in ipairs(row.btn) do
      -- If microchromatics are off then
      -- sets normalized tone step,
      -- otherwise sounds like a sad elephant
      local pitch = microchromatics
	 and pos 
	 or setFreq(btn.freq,(math.ceil((pos - 1)*12)*100))/btn.freq
      btn.src:setPitch(pitch)
   end
end

setFreq = function(referenceFreq, cents)
   return referenceFreq*2^(cents/1200)
end

loadSound = function(pads)
   for i, pad in ipairs(pads) do
      for j, btn in ipairs(pad.btn) do 
	 local len = math.floor(sample.cfg.rate/btn.freq) 
	 local padOsc = Oscillator('saw', btn.freq)
	 btn.sound = love.sound.newSoundData(
	    math.floor(sample.cfg.len/btn.freq),
	    sample.cfg.rate,
	    sample.cfg.bits,
	    sample.cfg.channel
	 )   
	 for i = 0, len - 1 do
	    local smpl = padOsc() * sample.cfg.amp
	    btn.sound:setSample(i,smpl)
	 end
	 btn.src = love.audio.newSource(btn.sound)
	 btn.src:setLooping(true)
      end
   end
end

--[[
loadSound = function(pads)
   for i, pad in ipairs(pads) do
--      for j, btn in ipairs(pad.btn) do 
      pad.len = math.floor(sample.cfg.rate/pad.freq) -- single period
      local padOsc = Oscillator('saw',pad.freq)
      pad.sound = love.sound.newSoundData(
	 math.floor(sample.cfg.len/pads[i].freq),
	 sample.cfg.rate,
	 sample.cfg.bits,
	 sample.cfg.channel
      )   
      for i = 0, pad.len - 1 do
	 local smpl = padOsc() * sample.cfg.amp
	 pad.sound:setSample(i,smpl)
      end
      pad.src = love.audio.newSource(pad.sound)
      pad.src:setLooping(true)
   end
end
--]]
