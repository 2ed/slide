
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

Oscillator = function(freq)
   local phase = 0
   local pi2 = math.pi*2
   return function()
      phase = phase + pi2/sample.cfg.rate
      if phase == pi2 then
	 phase = phase - pi2
      end
      return math.sin(phase*freq)
   end
end

loadSound = function(pads)
   for i, pad in ipairs(pads) do      
      pad.sound = love.sound.newSoundData(
	 sample.cfg.len,
	 sample.cfg.rate,
	 sample.cfg.bits,
	 sample.cfg.channel
      )   
      local padOsc = Oscillator(pad.freq)
      for i = 0, sample.cfg.len - 1 do
	 local smpl = padOsc() * sample.cfg.amp
	 pad.sound:setSample(i,smpl)
      end
      pad.src = love.audio.newSource(pad.sound)
      pad.src:setLooping(true)
   end
end

makeNoise = function(id)
   pads[id.row].src:play()
   --  love.audio.play(src)
   --   print('done')
end

stopNoise = function(id)
   pads[id.row].src:stop()
   --   love.audio.stop(src)
end
