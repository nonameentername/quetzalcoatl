instr $INSTRUMENT_NAME
	SInstrName = "$INSTRUMENT_NAME"
	SInstrMixer = "$INSTRUMENT_NAME._mixer"
	aSendL, aSendR ASynth SInstrName, p2, p3, p4, p5, p6
    print p1, p2, p3, p4, p5, p6
	ASynthMixerSend SInstrName, SInstrMixer, aSendL, aSendR
endin

instr $INSTRUMENT_NAME._midi, $INSTRUMENT_NUMBER
	SInstrName = "$INSTRUMENT_NAME"
	iChannel = p4
	iMidiKey = p5
	iMidiVelocity = p6
    print p1, p2, p3, p4, p5, p6

    kplay_instrument chnget "play_$INSTRUMENT_NAME"
    kRelease release
  
    if timeinstk() == 1 then
        if kplay_instrument == 1 then
	        ASynthInput SInstrName, iChannel, iMidiKey, iMidiVelocity
        endif
    endif

    if kRelease == 1 then
        ASynthInput SInstrName, iChannel, iMidiKey, 0
    endif
endin

instr $INSTRUMENT_NAME._mixer
	SInstrName = "$INSTRUMENT_NAME"
	SInstrMixer = "$INSTRUMENT_NAME._mixer"

    iNum = 1

    aSendL, aSendR ASynthMixerReceive SInstrName, SInstrMixer
    aSendL, aSendR ASynthOverDrive SInstrName, iNum, aSendL, aSendR
    aSendL, aSendR ASynthReverb SInstrName, iNum, aSendL, aSendR

    aClipL clip aSendL, 0, 0.9
    aClipR clip aSendR, 0, 0.9

    chnset aSendL, "$INSTRUMENT_NAME._left_channel"
    chnset aSendR, "$INSTRUMENT_NAME._right_channel"

    ;outs aSendL, aSendR
    clear aSendL, aSendR
endin

maxalloc "$INSTRUMENT_NAME", 8, 1
massign $INSTRUMENT_CHANNEL, "$INSTRUMENT_NAME._midi"
