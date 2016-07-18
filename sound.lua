
sample = {
   cfg = {
      sec = 2,
      rate = 44100,
      bits = 16,
      channel = 1,
      amp = 0.2,
   },
}

sample.cfg.len = sample.cfg.sec*sample.cfg.rate

sample.sound = love.sound.newSoundData(
   sample.cfg.len,
   sample.cfg.rate,
   sample.cfg.bits,
   sample.cfg.channel
)

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

laOsc = Oscillator(440)

for i = 0, sample.cfg.len - 1 do
   local smpl = laOsc() * sample.cfg.amp
--   print(i)
   sample.sound:setSample(i,smpl)
end



makeNoise = function(src)
   love.audio.play(src)
--   print('done')
end

stopNoise = function(src)
   love.audio.stop(src)
end
