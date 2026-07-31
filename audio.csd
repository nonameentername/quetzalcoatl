<CoundSynthesizer>
<CsOptions>
-+rtmidi=NULL -M0 --midi-key=5 --midi-velocity=6 -n -t120
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

iDrumsSF2 sfload "assets/128-016-Power.sf2"
sfpassign 0, iDrumsSF2

chnset 0, "play_drums"
chnset 0, "play_dirty_bass"
chnset 0, "play_atmosphere"
chnset 0, "play_ambience"
chnset 0, "play_space"
chnset 24, "bit_depth"

massign 0, 0

opcode SendMidiNote, 0, iii
  iChan, iNote, iVel xin

  xtratim 0.25

  if timeinstk() == 1 then
    midiout 144, iChan, iNote, iVel
    ;midion iChan, iNote, iVel
  endif

  kRelease release
  kChanged changed kRelease

  if kChanged == 1 && kRelease == 1 then
    midiout 128, iChan, iNote, 0
    ;noteoff iChan, iNote, 0
  endif
endop


instr drums, 1
  inum  init    p5
  ivel  init    p6
  kenv  linsegr 1, 1, 1, .1, 0
  kamp  = kenv * ivel * 0.0000003 
  kfreq init 1

  kplay_drums chnget "play_drums"

  if kplay_drums == 1 then
    a1, a2 sfplay3 ivel, inum, kamp, kfreq, 0
  else
    a1 = 0
    a2 = 0
  endif

  outs a1, a2
endin

;instr dirty_bass_route, 4
;  SendMidiNote 4, p5, p6
;endin

instr marker, 8
  rewindscore
endin


#include "addons/synths/amsynth_common.inc"

#define INSTRUMENT_NUMBER #13#
#define INSTRUMENT_NAME #synth#
#define INSTRUMENT_CHANNEL #1#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #2#
#define INSTRUMENT_NAME #guitar#
#define INSTRUMENT_CHANNEL #2#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #3#
#define INSTRUMENT_NAME #bass1#
#define INSTRUMENT_CHANNEL #3#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #4#
#define INSTRUMENT_NAME #dirty_bass#
#define INSTRUMENT_CHANNEL #4#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #5#
#define INSTRUMENT_NAME #atmosphere#
#define INSTRUMENT_CHANNEL #5#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #6#
#define INSTRUMENT_NAME #ambience#
#define INSTRUMENT_CHANNEL #6#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #7#
#define INSTRUMENT_NAME #space#
#define INSTRUMENT_CHANNEL #7#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #9#
#define INSTRUMENT_NAME #bass2#
#define INSTRUMENT_CHANNEL #9#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #10#
#define INSTRUMENT_NAME #jump#
#define INSTRUMENT_CHANNEL #10#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #11#
#define INSTRUMENT_NAME #shoot#
#define INSTRUMENT_CHANNEL #11#

#include "amsynth_instr.inc"

#define INSTRUMENT_NUMBER #12#
#define INSTRUMENT_NAME #swap#
#define INSTRUMENT_CHANNEL #12#

#include "amsynth_instr.inc"


iTempo = 120
tempo iTempo, 120

instr update_tempo, 100
  kTempo init 120
  kTempo chnget "tempo"
  tempo kTempo, 120

  kCurrentTime times
  chnset kCurrentTime, "time"
endin


opcode Bitcrush, a, akk
  ain, kbit, ksrate xin

  klevels = 2^kbit
  aout = int(ain * klevels) / klevels
  kfold = max(1, sr / ksrate)
  aout fold aout, kfold

  xout aout
endop


instr mixer, 10000
  aSynthLeft chnget "synth_left_channel"
  aSynthRight chnget "synth_right_channel"

  aGuitarLeft chnget "guitar_left_channel"
  aGuitarRight chnget "guitar_right_channel"

  aBass1Left chnget "bass1_left_channel"
  aBass1Right chnget "bass1_right_channel"

  aDirtyBassLeft chnget "dirty_bass_left_channel"
  aDirtyBassRight chnget "dirty_bass_right_channel"

  aAtmosphereLeft chnget "atmosphere_left_channel"
  aAtmosphereRight chnget "atmosphere_right_channel"

  aAmbienceLeft chnget "ambience_left_channel"
  aAmbienceRight chnget "ambience_right_channel"

  aSpaceLeft chnget "space_left_channel"
  aSpaceRight chnget "space_right_channel"

  aBass2Left chnget "bass2_left_channel"
  aBass2Right chnget "bass2_right_channel"

  aJumpLeft chnget "jump_left_channel"
  aJumpRight chnget "jump_right_channel"

  aShootLeft chnget "shoot_left_channel"
  aShootRight chnget "shoot_right_channel"

  aSwapLeft chnget "swap_left_channel"
  aSwapRight chnget "swap_right_channel"

  aLeft = aSynthLeft + aGuitarLeft + aBass1Left + aDirtyBassLeft + aAtmosphereLeft + aAmbienceLeft + aSpaceLeft + aBass2Left + aJumpLeft + aShootLeft + aSwapLeft
  aRight = aGuitarRight + aSynthRight + aBass1Right + aDirtyBassRight + aAtmosphereRight + aAmbienceRight + aSpaceRight + aBass2Right + aJumpRight + aShootRight + aSwapRight

  kBitDepth init 24
  kBitDepth chnget "bit_depth"

  aLeft Bitcrush aLeft, kBitDepth, 48000
  aRight Bitcrush aRight, kBitDepth, 48000

  outs aLeft, aRight
endin

massign 0, 0
;massign 0, "dirty_bass_midi"

</CsInstruments>
<CsScore>
f 1 0 16384 10 1 ;sine
f 0 z
i "synth_mixer" 0 -1
i "guitar_mixer" 0 -1
i "bass1_mixer" 0 -1
i "dirty_bass_mixer" 0 -1
i "atmosphere_mixer" 0 -1
i "ambience_mixer" 0 -1
i "space_mixer" 0 -1
i "bass2_mixer" 0 -1
i "jump_mixer" 0 -1
i "shoot_mixer" 0 -1
i "swap_mixer" 0 -1
i "mixer" 0 -1

#include "music.sco"

</CsScore>
</CsoundSynthesizer>
