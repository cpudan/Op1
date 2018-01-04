// Op 1: an original composition by Daniel Meyer

(// SynthDefs required for Patterns
SynthDef(\sea, {
	arg freq=400, amp=1, deg=0, dur=2, pan=0.1, out=0;
	var sig, env;
	freq = freq*deg.midiratio;
	env = LPF.ar(WhiteNoise.ar(amp), freq);
	sig = SinOsc.ar(freq) * env;
	env = EnvGen.kr(Env.new(times:[dur,dur]), doneAction:2);
	sig = sig*env;
	//sig = PanAz.ar(8,sig,0,1,2);
	sig = PanAz.ar(2,sig,SinOsc.ar(1/32,mul:1));
	Out.ar(out, sig);
}).add;

SynthDef.new(\playbuf, {
	arg amp=1, out=0, buf, rate=1, da=2, t_trig=1, start=0, loop=0;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, t_trig, start, loop, doneAction:da);
	sig = HPF.ar(sig, 600);
	sig = sig*amp;
	sig = sig*EnvGen.ar(Env.new([0,0.51,0.5,0.25,0.1,0],[0,0.5,1,1.5,2,2.5]));
	sig = Decay.ar(sig,1,amp);
	Out.ar(out,sig);
}).add;

SynthDef(\heart, {
	arg freq=440, deg1=0, deg2=0,
	phase=0, amp=1,
	atk=0.01, sus=0, rel=0.5,
	dur=1, out=0;
	var sig,env,decay;
	freq = freq * deg1.midiratio;
	sig = SinOsc.ar(XLine.ar(freq,freq*deg2.midiratio),phase,amp);
	env = EnvGen.kr(Env.linen(atk,sus,rel,curve:-4), doneAction:2);
	decay = Decay.ar(sig, dur,amp);
	sig = sig*env;
	sig = [sig, DelayN.ar(sig,0.125,0.125)];
	Out.ar(out,sig);
}).add;
)


( // Patterns
var dir;

// Synthetic waves
~sea = Pdef(\sea,
	Pbind(\instrument, \sea,
		\freq, Pseq([440,220,440],inf),
		\amp, 0.8,
		\deg, Pseq([-8],inf),
));



// Gull noises

dir = thisProcess.nowExecutingPath.dirname;
dir = dir ++ "/gulls";
dir.postln;
d = Dictionary.new;
PathName(dir).entries.do{
	arg subfolder;
	d.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size, { arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	);
};

~gull = Pdef(\gull, Pbind(\instrument, \playbuf,
	\buf, Prand(d[\high]++d[\low],inf),
	\stretch, 2,
	\amp, 0.2,
	\out, Prand([0,1],inf),
));

// Synthetic Heartbeat
~heart = Pdef(\heart,
	Pbind(\instrument, \heart,
		\freq, Pseq([300],inf),
		\deg1, Pseq([-40],inf),
		\deg2, Pseq([-7],inf),
		\rel, 1.25,
		\amp, 0.75,
		\dur, 1.26,//Pseq([1.75],inf),
		\out, 0
));
)

( // Play all
~sea.play();
~gull.play();
~heart.play();
)

( // Stop all
~sea.stop();
~gull.stop();
~heart.stop();
)