"""Rebuild the original Berry Bounce track. Requires Python/numpy and ffmpeg.

All melodies, harmonies, and synthetic instruments below were composed for
CritterCare; no samples, external recordings, or third-party songs are used.
Normal play/export uses the included OGG and needs neither Python nor ffmpeg.
"""
from pathlib import Path
import math, subprocess, tempfile, wave
import numpy as np

RATE = 44100
BEAT = 0.6
COUNT_IN = 4 * BEAT
DURATION = 88 * BEAT
LANES = [0, 1, 2, 1, 0, 2, 1, 2, 0, 1, 0, 2, 1, 2, 0, 1]
CHORDS = [(60,64,67),(60,64,67),(60,65,69),(60,65,69),
          (59,62,67),(59,62,67),(60,64,67),(60,64,67),
          (60,64,69),(60,64,69),(60,65,69),(60,65,69),
          (59,62,67),(59,62,67),(60,64,67),(60,64,67),
          (60,65,69),(59,62,67),(60,64,67),(60,64,67)]
song = np.zeros((round(DURATION * RATE), 2), dtype=np.float64)
rng = np.random.default_rng(1450)

def add(at, signal, gain=1.0, pan=0.0):
    start = round(at * RATE)
    count = min(len(signal), len(song)-start)
    if count <= 0: return
    theta = (pan+1)*math.pi/4
    song[start:start+count,0] += signal[:count]*gain*math.cos(theta)
    song[start:start+count,1] += signal[:count]*gain*math.sin(theta)

def tone(midi, length, kind='pluck'):
    t = np.arange(round(length*RATE))/RATE
    f = 440 * 2**((midi-69)/12)
    if kind == 'pad':
        signal = np.sin(2*np.pi*f*t)+0.18*np.sin(2*np.pi*f*2*t)
        envelope = np.minimum(t/0.10,1)*np.minimum((length-t)/0.18,1)*0.7
    elif kind == 'bass':
        signal = np.sin(2*np.pi*f*t)+0.25*np.sin(2*np.pi*f*2*t)
        envelope = np.minimum(t/0.008,1)*np.exp(-t*4)*np.minimum((length-t)/0.04,1)
    else:
        signal = np.sin(2*np.pi*f*t)+0.28*np.sin(2*np.pi*f*2*t)*np.exp(-t*9)+0.10*np.sin(2*np.pi*f*3*t)
        envelope = np.minimum(t/0.003,1)*np.exp(-t*5)*np.minimum((length-t)/0.025,1)
    return signal*envelope

def drum(kind):
    t = np.arange(round(0.22*RATE))/RATE
    if kind == 'kick':
        return np.sin(2*np.pi*(48*t+45*0.035*(1-np.exp(-t/0.035))))*np.exp(-t*23)*np.minimum(t/0.003,1)
    noise = rng.uniform(-1,1,len(t))
    if kind == 'hat':
        noise = np.concatenate(([0.0],np.diff(noise)))*0.5
        return noise*np.exp(-t*80)*np.minimum(t/0.001,1)
    return (noise*0.75+0.25*np.sin(2*np.pi*190*t))*np.exp(-t*28)*np.minimum(t/0.002,1)

# Four clear, gentle count-in taps; the first snack lands on the downbeat.
for beat in range(4):
    add(beat*BEAT,tone(84 if beat==0 else 79,0.16),0.15)
for bar,chord in enumerate(CHORDS):
    at = COUNT_IN+bar*4*BEAT
    for pitch in chord:
        add(at,tone(pitch-12,4*BEAT,'pad'),0.035,0.18)
    for b in range(4):
        beat = bar*4+b
        now = COUNT_IN+beat*BEAT
        lane = LANES[beat%len(LANES)]
        add(now,tone(chord[lane]+12,0.65),0.21,(-0.3,0,0.3)[lane])
        add(now,drum('kick' if b%2==0 else 'snare'),0.17)
        add(now,tone(chord[0]-24,0.48,'bass'),0.20)
        add(now+BEAT/2,drum('hat'),0.045,-0.15)
        if beat%2==1:
            extra = (lane+1)%3
            add(now+BEAT/2,tone(chord[extra]+12,0.32),0.095,(-0.3,0,0.3)[extra])
# A warm final chord gives the last note room to resolve before results.
for pitch in (48,60,64,67,72):
    add(COUNT_IN+80*BEAT,tone(pitch,4*BEAT,'pad'),0.075)
song *= 0.82/max(0.001,float(np.max(np.abs(song))))
song[-round(0.5*RATE):] *= np.linspace(1,0,round(0.5*RATE))[:,None]
out = Path(__file__).resolve().parents[1]/'assets/audio/snack_jam.ogg'
with tempfile.TemporaryDirectory() as temp:
    wav = Path(temp)/'berry_bounce.wav'
    with wave.open(str(wav),'wb') as f:
        f.setnchannels(2); f.setsampwidth(2); f.setframerate(RATE)
        f.writeframes((song*32767).astype('<i2').tobytes())
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(wav),'-c:a','libvorbis','-q:a','5',str(out)],check=True)
print(f'{out.name}: {DURATION:.1f}s, {out.stat().st_size} bytes, peak {np.max(np.abs(song)):.3f}')
