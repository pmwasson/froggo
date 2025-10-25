;-----------------------------------------------------------------------------
; Paul Wasson - 2024
;-----------------------------------------------------------------------------
; Game
;-----------------------------------------------------------------------------

.include        "defines.asm"
.include        "macros.asm"

.segment        "CODE"
.org            $6000

;-----------------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------------

SCROLL_MASK     =   $FE

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.macro writeScreen adrs,row
    sta     adrs+((row)&7)*$400+(((row)>>3)&7)*$80+(((row)>>6)&7)*$28
.endmacro

.proc main

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

.proc game


game_loop:

; Switch display

    lda         PAGE2           ; bit 7 = page2 displayed
    bmi         switchTo1

;switchTo2
    ; switch page
    bit         HISCR           ; display high screen
    lda         #$00            ; update low screen
    sta         drawPage
    jmp         game_loop

switchTo1:
    ; switch page
    bit         LOWSCR          ; display low screen
    lda         #$20            ; update high screen
    sta         drawPage

    ; wait for keypress
    lda         KBD
    bmi         :+
    jmp         game_loop
:
    bit         KBDSTRB
    cmp         #KEY_ESC
    beq         :+
    jmp         quit
:
    jmp         monitor

.endproc

;-----------------------------------------------------------------------------
; initTile
;
;-----------------------------------------------------------------------------
.proc initTile

    sta         tileIdx
    asl
    asl
    asl
    asl
    sta         tilePtr0

    lda         tileIdx
    lsr
    lsr
    lsr
    lsr
    clc
    adc         #>tileSheet
    sta         tilePtr1

    rts

.endproc

;-----------------------------------------------------------------------------
; drawTile -- draw 2-byte x 8 row tile
;
;   tileY - row to start drawing 0..23
;   tileX - column to start drawing 0..19
;-----------------------------------------------------------------------------

.proc drawTile

    jsr         initTile

    ldx         tileY
    lda         tileX
    asl                         ; x2
    clc
    adc         lineOffset,x
    sta         screenPtr0
    lda         linePage,x
    adc         drawPage
    sta         screenPtr1

    ldx         #8              ; 8 rows
    ldy         #0

drawLoop:
    lda         (tilePtr0),y
    sta         (screenPtr0),y
    iny
    lda         (tilePtr0),y
    sta         (screenPtr0),y
    dey

    ; advance tile pointer
    inc         tilePtr0
    inc         tilePtr0

    ; next row
    lda         screenPtr1
    adc         #4
    sta         screenPtr1
    dex
    bne         drawLoop

    rts

.endproc

;-----------------------------------------------------------------------------
; Clear Screen
;
;   Clear screen to color in X, preserving screen holes
;
;-----------------------------------------------------------------------------
.proc clearScreen
    lda     #$00
    sta     screenPtr0
    lda     #$80
    sta     tilePtr0
    clc
    lda     #$20
    adc     drawPage
    sta     screenPtr1
    sta     tilePtr1

loop:
    ldy     #$77            ; preserve screen holes
    lda     #0
loopPage:
    sta     (screenPtr0),y
    sta     (tilePtr0),y
    dey
    sta     (screenPtr0),y
    sta     (tilePtr0),y
    dey
    bpl     loopPage

    inc     tilePtr1
    inc     screenPtr1
    lda     screenPtr1
    and     #$1f
    bne     loop

    rts

.endproc

;-----------------------------------------------------------------------------
; Monitor
;
;  Exit to monitor
;-----------------------------------------------------------------------------
.proc monitor

    jsr         TEXT

    ; Set ctrl-y vector
    lda         #$4c        ; JMP
    sta         $3f8
    lda         #<quit
    sta         $3f9
    lda         #>quit
    sta         $3fa

    jmp         MONZ        ; enter monitor

.endproc

;-----------------------------------------------------------------------------
; Quit
;
;   Exit to ProDos
;-----------------------------------------------------------------------------
.proc quit

    sta         LOWSCR          ; page 1
    sta         TXTSET          ; text mode

    jsr         MLI
    .byte       CMD_QUIT
    .word       quitParams


quitParams:
    .byte       4               ; 4 parameters
    .byte       0               ; 0 is the only quit type
    .word       0               ; Reserved pointer for future use (what future?)
    .byte       0               ; Reserved byte for future use (what future?)
    .word       0               ; Reserved pointer for future use (what future?)

.endproc

;-----------------------------------------------------------------------------
; Globals
;-----------------------------------------------------------------------------

lineOffset:
    .byte       <$2000
    .byte       <$2080
    .byte       <$2100
    .byte       <$2180
    .byte       <$2200
    .byte       <$2280
    .byte       <$2300
    .byte       <$2380
    .byte       <$2028
    .byte       <$20A8
    .byte       <$2128
    .byte       <$21A8
    .byte       <$2228
    .byte       <$22A8
    .byte       <$2328
    .byte       <$23A8
    .byte       <$2050
    .byte       <$20D0
    .byte       <$2150
    .byte       <$21D0
    .byte       <$2250
    .byte       <$22D0
    .byte       <$2350
    .byte       <$23D0

linePage:
    .byte       >$2000
    .byte       >$2080
    .byte       >$2100
    .byte       >$2180
    .byte       >$2200
    .byte       >$2280
    .byte       >$2300
    .byte       >$2380
    .byte       >$2028
    .byte       >$20A8
    .byte       >$2128
    .byte       >$21A8
    .byte       >$2228
    .byte       >$22A8
    .byte       >$2328
    .byte       >$23A8
    .byte       >$2050
    .byte       >$20D0
    .byte       >$2150
    .byte       >$21D0
    .byte       >$2250
    .byte       >$22D0
    .byte       >$2350
    .byte       >$23D0


;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------
.align 256
tileSheet:
.include        "font.asm"

.align 256
mapData:
.include        "map.asm"




