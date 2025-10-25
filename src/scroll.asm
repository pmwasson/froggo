

SCROLL_MASK     =   $FE

.macro writeScreen adrs,row
    sta     adrs+((row)&7)*$400+(((row)>>3)&7)*$80+(((row)>>6)&7)*$28
.endmacro

.proc scrollV

    jsr             HGR

drawLoop:

    lda             offset1
    and             #SCROLL_MASK
    tay
.repeat 128,row
    lda             buffer0+row*2,y
    writeScreen     $2000, row+16
    lda             buffer0+row*2+1,y
    writeScreen     $2001, row+16
.endrepeat
    inc             offset1
    inc             offset1

    lda             offset2
    and             #SCROLL_MASK
    tay
.repeat 128,row
    lda             buffer0+row*2,y
    writeScreen     $2002, row+16
    lda             buffer0+row*2+1,y
    writeScreen     $2003, row+16
.endrepeat
    inc             offset2

    lda             offset3
    and             #SCROLL_MASK
    tay
.repeat 128,row
    lda             buffer1+row*2,y
    writeScreen     $2004, row+16
    lda             buffer1+row*2+1,y
    writeScreen     $2005, row+16
.endrepeat
    dec             offset3
    dec             offset3

    lda             offset4
    and             #SCROLL_MASK
    tay
.repeat 128,row
    lda             buffer0+row*2,y
    writeScreen     $2006, row+16
    lda             buffer0+row*2+1,y
    writeScreen     $2007, row+16
.endrepeat
    clc
    lda             offset4
    adc             #4
    sta             offset4

;    ldx             #0
;:
;    dex
;    bne     :-

    ; wait for keypress
    lda             KBD
    bmi             :+
    jmp             drawLoop
:
    bit             KBDSTRB
    cmp             #KEY_ESC
    bne             :+
    jmp             quit
:
    sta             SPEAKER
    jmp             drawLoop

offset1:    .byte   0
offset2:    .byte   12
offset3:    .byte   64
offset4:    .byte   0

.align 256

; 256 bytes, x2
buffer0:
.repeat 2

; car1 blue (16)
    .byte $D0,$82,$DC,$86,$DC,$86,$D0,$82
    .byte $D0,$82,$DC,$86,$DC,$86,$D0,$82

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; car2 (32)
    .byte $40,$01,$70,$07,$74,$0B,$34,$0B
    .byte $30,$07,$30,$07,$30,$07,$30,$07
    .byte $30,$07,$30,$07,$30,$07,$30,$07
    .byte $34,$0B,$74,$0B,$70,$07,$40,$01

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

;; truck down (48)
;    .byte $00,$00,$FC,$9F,$FD,$AF,$FD,$AF
;    .byte $FD,$AF,$FD,$AF,$FC,$9F,$FC,$9F
;    .byte $FC,$9F,$FC,$9F,$FC,$9F,$FD,$AF
;    .byte $FD,$AF,$FD,$AF,$FD,$AF,$FC,$9F
;    .byte $00,$00,$FC,$9F,$FD,$AF,$FD,$AF
;    .byte $8D,$AE,$8D,$AE,$FC,$9F,$00,$00

; truck up (48)
    .byte $00,$00,$FC,$9F,$8D,$AE,$8D,$AE
    .byte $FD,$AF,$FD,$AF,$FC,$9F,$00,$00
    .byte $FC,$9F,$FD,$AF,$FD,$AF,$FD,$AF
    .byte $FD,$AF,$FC,$9F,$FC,$9F,$FC,$9F
    .byte $FC,$9F,$FC,$9F,$FD,$AF,$FD,$AF
    .byte $FD,$AF,$FD,$AF,$FC,$9F,$80,$80

; ----

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; car1 red (16)
    .byte $A0,$85,$AC,$9D,$AC,$9D,$A0,$85
    .byte $A0,$85,$AC,$9D,$AC,$9D,$A0,$85

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

.endrepeat

; 256 bytes, x2
buffer1:
.repeat 2

; car1 blue (16)
    .byte $D0,$82,$DC,$86,$DC,$86,$D0,$82
    .byte $D0,$82,$DC,$86,$DC,$86,$D0,$82

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; car2 (32)
    .byte $40,$01,$70,$07,$74,$0B,$34,$0B
    .byte $30,$07,$30,$07,$30,$07,$30,$07
    .byte $30,$07,$30,$07,$30,$07,$30,$07
    .byte $34,$0B,$74,$0B,$70,$07,$40,$01

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; truck down (48)
    .byte $00,$00,$FC,$9F,$FD,$AF,$FD,$AF
    .byte $FD,$AF,$FD,$AF,$FC,$9F,$FC,$9F
    .byte $FC,$9F,$FC,$9F,$FC,$9F,$FD,$AF
    .byte $FD,$AF,$FD,$AF,$FD,$AF,$FC,$9F
    .byte $00,$00,$FC,$9F,$FD,$AF,$FD,$AF
    .byte $8D,$AE,$8D,$AE,$FC,$9F,$00,$00

;; truck up (48)
;    .byte $00,$00,$FC,$9F,$8D,$AE,$8D,$AE
;    .byte $FD,$AF,$FD,$AF,$FC,$9F,$00,$00
;    .byte $FC,$9F,$FD,$AF,$FD,$AF,$FD,$AF
;    .byte $FD,$AF,$FC,$9F,$FC,$9F,$FC,$9F
;    .byte $FC,$9F,$FC,$9F,$FD,$AF,$FD,$AF
;    .byte $FD,$AF,$FD,$AF,$FC,$9F,$80,$80

; ----

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; car1 red (16)
    .byte $A0,$85,$AC,$9D,$AC,$9D,$A0,$85
    .byte $A0,$85,$AC,$9D,$AC,$9D,$A0,$85

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; blank (16)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

.endrepeat

.endproc