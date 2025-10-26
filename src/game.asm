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

MAP_LEFT                    = 0
MAP_RIGHT                   = 40
MAP_TOP                     = 4
MAP_BOTTOM                  = 20

MAP_INDEX_MIDDLE            = 0
MAP_INDEX_TOP               = 20
MAP_INDEX_BOTTOM            = 40
MAP_INDEX_SCORE             = 60
MAP_INDEX_CREDITS1          = 80
MAP_INDEX_CREDITS2          = 100

ROAD_X                      = 6 * TILE_WIDTH

STATE_IDLE                  = 0
STATE_START_UP              = 1
STATE_MOVE_UP               = 2
STATE_DONE_UP               = 3
STATE_START_DOWN            = 4
STATE_MOVE_DOWN             = 5
STATE_DONE_DOWN             = 6
STATE_DEAD                  = $FF

PLAYER_INIT_X               = MAP_LEFT+TILE_WIDTH
PLAYER_INIT_Y               = MAP_BOTTOM-TILE_HEIGHT*2
PLAYER_INIT_STATE           = STATE_IDLE

MOVE_DELAY                  = 20

TILE_GRASS                  = $46
TILE_PLAYER_GREEN_IDLE      = $6E
TILE_PLAYER_GREEN_DEAD      = $6F
TILE_PLAYER_GREEN_UP_1      = $62
TILE_PLAYER_GREEN_UP_2      = $6A
TILE_PLAYER_GREEN_DOWN_1    = $63
TILE_PLAYER_GREEN_DOWN_2    = $6B

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    jsr         initDisplay
    jsr         initState

game_loop:

    jsr         drawRoad
    jsr         updatePlayer

    ; Flip display page
    ;---------------------------

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

    ; Check for user input
    ;---------------------------


    ; wait for keypress
    lda         KBD
    bmi         :+
    jmp         game_loop
:
    bit         KBDSTRB

    cmp         #KEY_ESC
    bne         :+
    jmp         quit
:
    cmp         #KEY_TAB
    bne         :+
    jmp         monitor
:

    ; only process movement keypress if player is idle
    ldx         playerState
    cpx         #STATE_IDLE
    beq         :+
    jmp         game_loop   ; not in idle, so no movement
:

    cmp         #KEY_A
    bne         :+
    jmp         goUp
:
    cmp         #KEY_Z
    bne         :+
    jmp         goDown
:
    cmp         #KEY_RIGHT
    bne         :+
    jmp         goRight
:
    cmp         #KEY_LEFT
    bne         :+
    jmp         goLeft
:
    cmp         #KEY_X
    bne         :+
    lda         #STATE_DEAD
    sta         playerState
    jmp         game_loop
:
    jmp         game_loop

goUp:
    ; check if at top
    lda         playerY
    cmp         #MAP_TOP+TILE_HEIGHT
    beq         :+
    lda         #STATE_START_UP
    sta         playerState
    lda         #0
    sta         count
:
    jmp         game_loop

goDown:
    ; check if at top
    lda         playerY
    cmp         #MAP_BOTTOM-TILE_HEIGHT*2
    beq         :+
    lda         #STATE_START_DOWN
    sta         playerState
    lda         #0
    sta         count
:
    jmp         game_loop

goRight:
goLeft:
    jmp         game_loop


.endproc


;-----------------------------------------------------------------------------
; Update Player
;-----------------------------------------------------------------------------
.proc updatePlayer

    inc         count

    lda         playerX
    sta         tileX
    lda         playerY
    sta         tileY

    lda         playerState
    cmp         #STATE_DEAD
    bne         :+
    lda         #TILE_PLAYER_GREEN_DEAD
    jsr         drawTile
    rts
:

    lda         playerState
    cmp         #STATE_IDLE
    bne         :+
    lda         #TILE_PLAYER_GREEN_IDLE
    jsr         drawTile
    rts
:
    cmp         #STATE_START_UP
    bne         :+
    lda         count
    and         #1
    beq         noNoiseUp
    sta         SPEAKER
noNoiseUp:
    lda         #TILE_PLAYER_GREEN_UP_2
    jsr         drawTile
    dec         tileY
    lda         #TILE_PLAYER_GREEN_UP_1
    jsr         drawTile
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneUp
    lda         #STATE_MOVE_UP
    sta         playerState
doneUp:
    rts
:
    cmp         #STATE_MOVE_UP
    bne         :+
    lda         #TILE_GRASS
    jsr         drawTile
    dec         tileY
    lda         #TILE_PLAYER_GREEN_IDLE
    jsr         drawTile
    dec         playerY
    lda         #STATE_DONE_UP
    sta         playerState
    rts
:
    cmp         #STATE_DONE_UP
    bne         :+
    lda         #TILE_PLAYER_GREEN_IDLE
    jsr         drawTile
    inc         tileY
    lda         #TILE_GRASS
    jsr         drawTile
    lda         #STATE_IDLE
    sta         playerState
    rts
:

    cmp         #STATE_START_DOWN
    bne         :+
    lda         count
    and         #1
    beq         noNoiseDown
    sta         SPEAKER
noNoiseDown:
    lda         #TILE_PLAYER_GREEN_DOWN_1
    jsr         drawTile
    inc         tileY
    lda         #TILE_PLAYER_GREEN_DOWN_2
    jsr         drawTile
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneDown
    lda         #STATE_MOVE_DOWN
    sta         playerState
doneDown:
    rts
:
    cmp         #STATE_MOVE_DOWN
    bne         :+
    lda         #TILE_GRASS
    jsr         drawTile
    inc         tileY
    lda         #TILE_PLAYER_GREEN_IDLE
    jsr         drawTile
    inc         playerY
    lda         #STATE_DONE_DOWN
    sta         playerState
    rts
:
    cmp         #STATE_DONE_DOWN
    bne         :+
    lda         #TILE_PLAYER_GREEN_IDLE
    jsr         drawTile
    dec         tileY
    lda         #TILE_GRASS
    jsr         drawTile
    lda         #STATE_IDLE
    sta         playerState
    rts
:
    brk

.endproc


;-----------------------------------------------------------------------------
; Sound "Move"
;-----------------------------------------------------------------------------

.proc soundMove
    ldy         #$14
loop:
    sta         SPEAKER
    ldx         #$5A
pause:
    dex
    bne         pause
    dey
    bne         loop
    rts
.endproc

;-----------------------------------------------------------------------------
; Draw Road
;-----------------------------------------------------------------------------

.proc drawRoad

    ldx         #ROAD_X

    clc
    lda         roadOffset+0
    adc         roadSpeed +0
    sta         roadOffset+0
    lda         roadOffset+1
    adc         roadSpeed +1
    sta         roadOffset+1

    and         #$7f
    tay

    lda         PAGE2           ; bit 7 = page2 displayed
    bmi         draw1           ; display2, draw 1

;draw2:
    jsr         drawColumn0Page0
    jsr         drawColumn1Page0
    rts

draw1:
    jsr         drawColumn0Page1
    jsr         drawColumn1Page1
    rts

.endproc

;-----------------------------------------------------------------------------
; drawColumn#Page#
;
;   Draw a scrolling column per display page
;   X - display column
;   Y - scroll offset
;
;   Each column has a dedicated buffer (shared between pages)
;-----------------------------------------------------------------------------

COLUMN_ROWS             = 126
COLUMN_STARTING_ROW     = 33
; convert row # to row address
.macro writeScreen adrs,row
    sta     adrs+((row)&7)*$400+(((row)>>3)&7)*$80+(((row)>>6)&7)*$28,x
.endmacro

.macro drawColumn adrs,buffer
.repeat COLUMN_ROWS,row
    lda             buffer+row,y
    writeScreen     adrs, row+COLUMN_STARTING_ROW
.endrepeat
    rts
.endmacro

drawColumn0Page0:   drawColumn  $2000,buffer0
drawColumn1Page0:   drawColumn  $2001,buffer1
;drawColumn2Page0:   drawColumn  $2000,buffer2
;drawColumn3Page0:   drawColumn  $2000,buffer3
;drawColumn4Page0:   drawColumn  $2000,buffer4
;drawColumn5Page0:   drawColumn  $2000,buffer5
;drawColumn6Page0:   drawColumn  $2000,buffer6
;drawColumn7Page0:   drawColumn  $2000,buffer7
;drawColumn8Page0:   drawColumn  $2000,buffer8
;drawColumn9Page0:   drawColumn  $2000,buffer9

drawColumn0Page1:   drawColumn  $4000,buffer0
drawColumn1Page1:   drawColumn  $4001,buffer1
;drawColumn2Page1:   drawColumn  $4000,buffer2
;drawColumn3Page1:   drawColumn  $4000,buffer3
;drawColumn4Page1:   drawColumn  $4000,buffer4
;drawColumn5Page1:   drawColumn  $4000,buffer5
;drawColumn6Page1:   drawColumn  $4000,buffer6
;drawColumn7Page1:   drawColumn  $4000,buffer7
;drawColumn8Page1:   drawColumn  $4000,buffer8
;drawColumn9Page1:   drawColumn  $4000,buffer9

;-----------------------------------------------------------------------------
; Draw Map
;-----------------------------------------------------------------------------

.proc drawMap
    lda         #MAP_TOP
    sta         tileY

    ; top row
    lda         #MAP_INDEX_TOP
    sta         index
    jsr         drawRow
    lda         #MAP_TOP+TILE_HEIGHT
    sta         tileY

    ; middle rows
mapLoop:
    lda         #MAP_INDEX_MIDDLE
    sta         index
    jsr         drawRow
    lda         tileY
    clc
    adc         #TILE_HEIGHT
    sta         tileY
    cmp         #MAP_BOTTOM-TILE_HEIGHT
    bne         mapLoop

    ; bottom row
    lda         #MAP_INDEX_BOTTOM
    sta         index
    jsr         drawRow

    ; score
    lda         #1
    sta         tileY
    lda         #MAP_INDEX_SCORE
    jsr         drawRow

    ; credits
    lda         #22
    sta         tileY
    lda         #MAP_INDEX_CREDITS1
    jsr         drawRow
    lda         #23
    sta         tileY
    lda         #MAP_INDEX_CREDITS2
    jsr         drawRow

    rts


;-------------------------
drawRow:
    lda         #MAP_LEFT
    sta         tileX
rowLoop:
    ldx         index
    lda         mapTiles,x
    jsr         drawTile

    inc         index
    lda         tileX
    clc
    adc         #TILE_WIDTH
    sta         tileX
    cmp         #MAP_RIGHT
    bne         rowLoop
    rts

index:      .byte   0

mapTiles:
            ; index 0 - MIDDLE (default)
            .byte $46,$46,$46               ; grass
            .byte $47,$57,$57,$57,$57,$45   ; road
            .byte $46,$46,$46               ; grass
            .byte $4D,$4E,$4E,$4E,$4E,$4F   ; water
            .byte $46,$46                   ; grass

            ; index 20 - TOP
            .byte $55,$55,$55               ; grass
            .byte $47,$57,$57,$57,$57,$45   ; road
            .byte $55,$55,$55               ; grass
            .byte $4D,$56,$56,$56,$56,$4F   ; water
            .byte $55,$55                   ; grass

            ; index 40 - BOTTOM
            .byte $5D,$5D,$5D               ; grass
            .byte $47,$57,$57,$57,$57,$45   ; road
            .byte $5D,$5D,$5D               ; grass
            .byte $4D,$5E,$5E,$5E,$5E,$4F   ; water
            .byte $5D,$5D

            ; index 80 - SCORE
            MapText     "    SCORE: 00000    "

            ; index 100 - CREDITS 1
            MapText     "====== FROGGO ======"

            ; index 120 - CREDITS 2
            MapText     " PAUL WASSON - 2025 "
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
; initState
;-----------------------------------------------------------------------------

.proc initState
    lda         #PLAYER_INIT_X
    sta         playerX
    lda         #PLAYER_INIT_Y
    sta         playerY
    lda         #PLAYER_INIT_STATE
    sta         playerState
    rts
.endproc

;-----------------------------------------------------------------------------
; initDisplay - Initialize display
;-----------------------------------------------------------------------------

.proc initDisplay
    ; assuming title is being displayed, so show page1 graphics while clearing 2
    sta         MIXCLR
    sta         LOWSCR
    sta         HIRES
    sta         TXTCLR

    ; clear page2
    lda         #$00
    sta         colorOdd
    sta         colorEven
    lda         #$20
    sta         drawPage
    jsr         clearScreen

    ; clear page1
    lda         #$00
    sta         drawPage
    jsr         clearScreen

    ; display map on both pages
    lda         #$20
    sta         drawPage
    jsr         drawMap
    lda         #$00
    sta         drawPage
    jsr         drawMap

    ; start with showing page1 and drawing on page2
    lda         #$20
    sta         drawPage

    rts

.endproc

;-----------------------------------------------------------------------------
; Clear Screen
;
;   Clear screen to color in colorEven/Odd, preserving screen holes
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
loopPage:
    lda     colorOdd
    sta     (screenPtr0),y
    sta     (tilePtr0),y
    dey
    lda     colorEven
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

count:          .byte       0
playerX:        .byte       MAP_LEFT+TILE_WIDTH
playerY:        .byte       MAP_BOTTOM-TILE_HEIGHT*2
playerState:    .byte       STATE_IDLE

roadOffset:     .word       $0000
roadSpeed:      .word       $0033

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
; Data
;-----------------------------------------------------------------------------
.align 256

buffer0:        .res 128-8
                .byte $D0,$DC,$DC,$D0,$D0,$DC,$DC,$D0
                .res 128-8
                .byte $D0,$DC,$DC,$D0,$D0,$DC,$DC,$D0

buffer1:        .res 128-8
                .byte $82,$86,$86,$82,$82,$86,$86,$82
                .res 128-8
                .byte $82,$86,$86,$82,$82,$86,$86,$82

;buffer2:        .res 256
;buffer3:        .res 256
;buffer4:        .res 256
;buffer5:        .res 256
;buffer6:        .res 256
;buffer7:        .res 256
;buffer8:        .res 256
;buffer9:        .res 256

;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------
.align 256
tileSheet:
.include        "font.asm"

.align 256
mapData:
.include        "map.asm"




