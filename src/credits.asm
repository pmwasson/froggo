; Credits
;--------------------------------------------------------------------------------
; Froggo - inspired by the classic Frogger and the more recent Crossy Road.
;
; Music and sound effects were generated using the Electric Duet song player, created by Paul Lutus (c) 1981.
; Please see https://arachnoid.com/electric_duet/index.html
;
; All other code was written by Paul Wasson. A big thanks goes out to people behind the AppleWin emulator, the cc65 tool-chain (especially the wonderful ca65 assembler), and the Apple Commander toolset.  All of these tools made Apple II 6052 assembly coding a dream.
;
; Some initial image concepts were AI-generated using Imagen 3 (Nano Banana Pro). However, the resulting visuals underwent extensive processing, including downscaling and palette reduction through custom Python scripts, to match the limited Apple II hi-res format. Every single pixel was ultimately refined and finalized by hand in Aseprite to ensure quality.
;
;--------------------------------------------------------------------------------

.proc scrollCredits

loop:
	jsr 		scroll1to2
    bit         HISCR
	jsr 		scroll2to1
    bit         LOWSCR
    lda 		KBD
    bpl 		loop
    sta 		KBDSTRB
    rts

scroll2to1:
	; Copy screen 2 to screen 1

	; Lines %8 == 0..6
	; Offset by $400

	lda 		#<$2000
	sta 		screenPtr0
	lda 		#>$2000
	sta 		screenPtr0+1
	lda 		#<$4400
	sta 		scriptPtr0
	lda 		#>$4400
	sta 		scriptPtr0+1
	lda 		#$3C 			; page to stop writing
	ldx 		#0
	jsr 		copyMemBig

	; wrap around source + 80
	; Line %8 == 7
	; Offset by $480
	lda 		#<$4080
	sta 		scriptPtr0
	lda 		#>$4080
	sta 		scriptPtr0+1
	lda 		#$3F
	ldx 		#$80
	jsr 		copyMemBig

	lda 		#<$3F80
	sta 		screenPtr0
	lda 		#<$4028
	sta 		scriptPtr0
	lda 		#>$4028
	sta 		scriptPtr0+1
	ldx 		#80 			; 2 lines
	jsr 		copyMemSmall
	rts

scroll1to2:
	; Copy screen 1 to screen 2
	lda 		#<$4000
	sta 		screenPtr0
	lda 		#>$4000
	sta 		screenPtr0+1
	lda 		#<$2400
	sta 		scriptPtr0
	lda 		#>$2400
	sta 		scriptPtr0+1
	lda 		#$5C 			; page to stop writing
	ldx 		#0
	jsr 		copyMemBig

	lda 		#<$2080
	sta 		scriptPtr0
	lda 		#>$2080
	sta 		scriptPtr0+1
	lda 		#$5F
	ldx 		#$80
	jsr 		copyMemBig

	lda 		#<$5F80
	sta 		screenPtr0
	lda 		#<$2028
	sta 		scriptPtr0
	lda 		#>$2028
	sta 		scriptPtr0+1
	ldx 		#80 			; 2 lines
	jsr 		copyMemSmall
	rts

copyMemBig:
	sta 		stopPage
	ldy 		#0
copyLoop:
	lda 		(scriptPtr0),y
	sta 		(screenPtr0),y
	iny
	bne 		copyLoop
	inc 		scriptPtr0+1
	inc 		screenPtr0+1
	lda 		screenPtr0+1
	cmp 		stopPage
	bne 		copyLoop
	txa
	bne 		copyLoopSmall
	rts
	; copy "extra"
copyMemSmall:
	ldy 		#0
copyLoopSmall:
	lda 		(scriptPtr0),y
	sta 		(screenPtr0),y
	iny
	dex
	bne 		copyLoopSmall
	rts

stopPage: 		.byte 	0

.endproc

