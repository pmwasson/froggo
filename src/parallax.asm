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
TILE_WIDTH                  = 2
TILE_HEIGHT                 = 1

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    jsr         testParallax
    jmp         quit
.endproc

;-----------------------------------------------------------------------------
; Testing generated parallax code
;-----------------------------------------------------------------------------
.proc testParallax

offset0Mask     =   $FF     ; 1 out of 256
offset1Mask     =   $0F     ; 1 out of 16
offset2Mask     =   $03     ; 1 out of 4
offset3Mask     =   $00     ; every time

    sta         MIXCLR
    sta         LOWSCR
    sta         HIRES
    sta         TXTCLR

    ; draw once since never changes
    jsr         parallaxConsantColorRowsScreen0
    jsr         parallaxConsantColorRowsScreen1

    sta         HISCR

    lda         #$00
    sta         drawPage
    jsr         drawTitle
    lda         #$20
    sta         drawPage
    jsr         drawTitle

    lda         #1
    sta         music           ; well sorta music

loop:

    jsr         sound

    ; display hi, draw lo
    sta         HISCR

    jsr         incTime
    jsr         parallaxGroup0Screen0
    jsr         parallaxGroup1Screen0
    jsr         parallaxGroup2Screen0
    jsr         parallaxGroup3Screen0

    jsr         sound

    ; display lo, draw hi
    sta         LOWSCR

    jsr         incTime
    jsr         parallaxGroup0Screen1
    jsr         parallaxGroup1Screen1
    jsr         parallaxGroup2Screen1
    jsr         parallaxGroup3Screen1

    lda         KBD
    bpl         loop
    bit         KBDSTRB

    cmp         #KEY_ESC
    bne         :+
    rts
:
    lda         direction
    eor         #1
    sta         direction

    jmp         loop

incTime:
    inc         time
    bne         :+
    inc         time+1
:
    lda         direction
    beq         incOffset0
    jmp         decOffset0

incOffset0:
    lda         time
    and         #offset0Mask
    bne         incOffset1
    inc         index0
    ldx         index0
    cpx         #49
    bne         :+
    ldx         #0
    stx         index0
:
    lda         shiftOffsets,x
    sta         parallaxGroup0Offset

incOffset1:
    lda         time
    and         #offset1Mask
    bne         incOffset2
    inc         index1
    ldx         index1
    cpx         #49
    bne         :+
    ldx         #0
    stx         index1
:
    lda         shiftOffsets,x
    sta         parallaxGroup1Offset

incOffset2:
    lda         time
    and         #offset2Mask
    bne         incOffset3
    inc         index2
    ldx         index2
    cpx         #49
    bne         :+
    ldx         #0
    stx         index2
:
    lda         shiftOffsets,x
    sta         parallaxGroup2Offset

incOffset3:
    lda         time
    and         #offset3Mask
    bne         incOffset4
    inc         index3
    ldx         index3
    cpx         #49
    bne         :+
    ldx         #0
    stx         index3
:
    lda         shiftOffsets,x
    sta         parallaxGroup3Offset

incOffset4:
    rts

decOffset0:
    lda         time
    and         #offset0Mask
    bne         decOffset1
    dec         index0
    ldx         index0
    bpl         :+
    ldx         #48
    stx         index0
:
    lda         shiftOffsets,x
    sta         parallaxGroup0Offset

decOffset1:
    lda         time
    and         #offset1Mask
    bne         decOffset2
    dec         index1
    ldx         index1
    bpl         :+
    ldx         #48
    stx         index1
:
    lda         shiftOffsets,x
    sta         parallaxGroup1Offset

decOffset2:
    lda         time
    and         #offset2Mask
    bne         decOffset3
    dec         index2
    ldx         index2
    bpl         :+
    ldx         #48
    stx         index2
:
    lda         shiftOffsets,x
    sta         parallaxGroup2Offset

decOffset3:
    lda         time
    and         #offset3Mask
    bne         decOffset4
    dec         index3
    ldx         index3
    bpl         :+
    ldx         #48
    stx         index3
:
    lda         shiftOffsets,x
    sta         parallaxGroup3Offset

decOffset4:
    rts


drawTitle:
    lda         #0
    sta         index
    lda         #14
    sta         tileY
    lda         #12
    sta         tileX
titleLoop:
    ldx         index
    lda         parallaxTitle,x
    bne         :+
    rts
:
    jsr         drawTile

    inc         index
    lda         tileX
    clc
    adc         #TILE_WIDTH
    sta         tileX
    jmp         titleLoop

sound:
    lda         music
    beq         done
    ldx         time
    bne         loadSound
    lda         time+1
    and         #$3
    clc
    adc         #>soundData
    sta         loadSound+2
    lda         time+1
    cmp         #4*8
    bne         loadSound
    lda         #0
    sta         music
loadSound:
    lda         soundData,x
    beq         done
    sta         SPEAKER
done:
    rts

time:           .word 0
music:          .byte 1
direction:      .byte 0
index0:         .byte 0
index1:         .byte 0
index2:         .byte 0
index3:         .byte 0

shiftOffsets:  ;+0   +2   +4   +6   +8   +10  +12 (*14)
    .byte       0,   28,  56,  84,  113, 141, 169
    .byte       2,   30,  58,  86,  115, 143, 171
    .byte       4,   32,  60,  88,  117, 145, 173
    .byte       6,   34,  62,  90,  119, 147, 175
    .byte       8,   36,  64,  92,  121, 149, 177
    .byte       10,  38,  66,  94,  123, 151, 179
    .byte       12,  40,  68,  96,  125, 153, 181

index:          .byte   0
parallaxTitle:  MapText "PARALLAX"
                .byte   0

.align 256
soundData:
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
    .byte   0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1

    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
    .byte   0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1

    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
    .byte   0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1

    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


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
;   tileX - column to start drawing 0..39
;-----------------------------------------------------------------------------

.proc drawTile

    jsr         initTile

    ldx         tileY
    lda         tileX
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
; Utilities
;-----------------------------------------------------------------------------
.include        "inline_print.asm"

;-----------------------------------------------------------------------------
; Globals
;-----------------------------------------------------------------------------

.align 256

; pack lookup tables on page (192 + 24 + 24 = 240)

fullLineOffset:
    .byte       <$2000, <$2400, <$2800, <$2C00, <$3000, <$3400, <$3800, <$3C00
    .byte       <$2080, <$2480, <$2880, <$2C80, <$3080, <$3480, <$3880, <$3C80
    .byte       <$2100, <$2500, <$2900, <$2D00, <$3100, <$3500, <$3900, <$3D00
    .byte       <$2180, <$2580, <$2980, <$2D80, <$3180, <$3580, <$3980, <$3D80
    .byte       <$2200, <$2600, <$2A00, <$2E00, <$3200, <$3600, <$3A00, <$3E00
    .byte       <$2280, <$2680, <$2A80, <$2E80, <$3280, <$3680, <$3A80, <$3E80
    .byte       <$2300, <$2700, <$2B00, <$2F00, <$3300, <$3700, <$3B00, <$3F00
    .byte       <$2380, <$2780, <$2B80, <$2F80, <$3380, <$3780, <$3B80, <$3F80
    .byte       <$2028, <$2428, <$2828, <$2C28, <$3028, <$3428, <$3828, <$3C28
    .byte       <$20A8, <$24A8, <$28A8, <$2CA8, <$30A8, <$34A8, <$38A8, <$3CA8
    .byte       <$2128, <$2528, <$2928, <$2D28, <$3128, <$3528, <$3928, <$3D28
    .byte       <$21A8, <$25A8, <$29A8, <$2DA8, <$31A8, <$35A8, <$39A8, <$3DA8
    .byte       <$2228, <$2628, <$2A28, <$2E28, <$3228, <$3628, <$3A28, <$3E28
    .byte       <$22A8, <$26A8, <$2AA8, <$2EA8, <$32A8, <$36A8, <$3AA8, <$3EA8
    .byte       <$2328, <$2728, <$2B28, <$2F28, <$3328, <$3728, <$3B28, <$3F28
    .byte       <$23A8, <$27A8, <$2BA8, <$2FA8, <$33A8, <$37A8, <$3BA8, <$3FA8
    .byte       <$2050, <$2450, <$2850, <$2C50, <$3050, <$3450, <$3850, <$3C50
    .byte       <$20D0, <$24D0, <$28D0, <$2CD0, <$30D0, <$34D0, <$38D0, <$3CD0
    .byte       <$2150, <$2550, <$2950, <$2D50, <$3150, <$3550, <$3950, <$3D50
    .byte       <$21D0, <$25D0, <$29D0, <$2DD0, <$31D0, <$35D0, <$39D0, <$3DD0
    .byte       <$2250, <$2650, <$2A50, <$2E50, <$3250, <$3650, <$3A50, <$3E50
    .byte       <$22D0, <$26D0, <$2AD0, <$2ED0, <$32D0, <$36D0, <$3AD0, <$3ED0
    .byte       <$2350, <$2750, <$2B50, <$2F50, <$3350, <$3750, <$3B50, <$3F50
    .byte       <$23D0, <$27D0, <$2BD0, <$2FD0, <$33D0, <$37D0, <$3BD0, <$3FD0

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

.align 256

fullLinePage:
    .byte       >$2000, >$2400, >$2800, >$2C00, >$3000, >$3400, >$3800, >$3C00
    .byte       >$2080, >$2480, >$2880, >$2C80, >$3080, >$3480, >$3880, >$3C80
    .byte       >$2100, >$2500, >$2900, >$2D00, >$3100, >$3500, >$3900, >$3D00
    .byte       >$2180, >$2580, >$2980, >$2D80, >$3180, >$3580, >$3980, >$3D80
    .byte       >$2200, >$2600, >$2A00, >$2E00, >$3200, >$3600, >$3A00, >$3E00
    .byte       >$2280, >$2680, >$2A80, >$2E80, >$3280, >$3680, >$3A80, >$3E80
    .byte       >$2300, >$2700, >$2B00, >$2F00, >$3300, >$3700, >$3B00, >$3F00
    .byte       >$2380, >$2780, >$2B80, >$2F80, >$3380, >$3780, >$3B80, >$3F80
    .byte       >$2028, >$2428, >$2828, >$2C28, >$3028, >$3428, >$3828, >$3C28
    .byte       >$20A8, >$24A8, >$28A8, >$2CA8, >$30A8, >$34A8, >$38A8, >$3CA8
    .byte       >$2128, >$2528, >$2928, >$2D28, >$3128, >$3528, >$3928, >$3D28
    .byte       >$21A8, >$25A8, >$29A8, >$2DA8, >$31A8, >$35A8, >$39A8, >$3DA8
    .byte       >$2228, >$2628, >$2A28, >$2E28, >$3228, >$3628, >$3A28, >$3E28
    .byte       >$22A8, >$26A8, >$2AA8, >$2EA8, >$32A8, >$36A8, >$3AA8, >$3EA8
    .byte       >$2328, >$2728, >$2B28, >$2F28, >$3328, >$3728, >$3B28, >$3F28
    .byte       >$23A8, >$27A8, >$2BA8, >$2FA8, >$33A8, >$37A8, >$3BA8, >$3FA8
    .byte       >$2050, >$2450, >$2850, >$2C50, >$3050, >$3450, >$3850, >$3C50
    .byte       >$20D0, >$24D0, >$28D0, >$2CD0, >$30D0, >$34D0, >$38D0, >$3CD0
    .byte       >$2150, >$2550, >$2950, >$2D50, >$3150, >$3550, >$3950, >$3D50
    .byte       >$21D0, >$25D0, >$29D0, >$2DD0, >$31D0, >$35D0, >$39D0, >$3DD0
    .byte       >$2250, >$2650, >$2A50, >$2E50, >$3250, >$3650, >$3A50, >$3E50
    .byte       >$22D0, >$26D0, >$2AD0, >$2ED0, >$32D0, >$36D0, >$3AD0, >$3ED0
    .byte       >$2350, >$2750, >$2B50, >$2F50, >$3350, >$3750, >$3B50, >$3F50
    .byte       >$23D0, >$27D0, >$2BD0, >$2FD0, >$33D0, >$37D0, >$3BD0, >$3FD0




;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------

.include        "..\build\parallaxData.asm"

.align 256
tileSheet:
.include        "font.asm"




