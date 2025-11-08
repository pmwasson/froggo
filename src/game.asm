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

; reuse zero page addresses
bufferPtr0                  := mapPtr0      ; and mapPtr1
bufferPtr1                  := scriptPtr0   ; and scriptPt1

; Constants for draw loop unrolling
MAX_COLUMNS                 = 16
COLUMN_CODE_START           = $2000     ; page0 $2000..$5048, page1 $5049..$8091
COLUMN_CODE_START_PAGE2     = $5049
COLUMN_BUFFER_START         = $8100     ;       $8100..$90FF
DISPATCH_CODE               = $C00

COLUMN_ROWS                 = 128
COLUMN_STARTING_ROW         = 32

INSTRUCTION_BPL             = $10
INSTRUCTION_LDA_Y           = $B9
INSTRUCTION_LDX             = $AE
INSTRUCTION_LDY             = $AC
INSTRUCTION_RTS             = $60
INSTRUCTION_STA_X           = $9D

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

ROAD_X                      = 4 * TILE_WIDTH

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

MOVE_DELAY                  = 3

TILE_GRASS                  = $46
TILE_PLAYER_GREEN_IDLE      = $6E
TILE_PLAYER_GREEN_DEAD      = $6F
TILE_PLAYER_GREEN_UP_1      = $62
TILE_PLAYER_GREEN_UP_2      = $6A
TILE_PLAYER_GREEN_DOWN_1    = $63
TILE_PLAYER_GREEN_DOWN_2    = $6B

TILE_CAR1_BLUE              = $44
TILE_CAR1_RED               = $53

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    jsr         initCode
    jsr         initBuffers
    jsr         initDisplay
    jsr         initState

    ; set up buffers
    lda         #0
    sta         tileX
    sta         tileY
    lda         #TILE_CAR1_BLUE
    jsr         copyTileToBuffers

    lda         #20
    sta         tileY
    lda         #TILE_CAR1_BLUE
    jsr         copyTileToBuffers

    lda         #40
    sta         tileY
    lda         #TILE_CAR1_BLUE
    jsr         copyTileToBuffers

    lda         #2
    sta         tileX
    lda         #15
    sta         tileY
    lda         #TILE_CAR1_RED
    jsr         copyTileToBuffers

    lda         #45
    sta         tileY
    lda         #TILE_CAR1_RED
    jsr         copyTileToBuffers

    lda         #75
    sta         tileY
    lda         #TILE_CAR1_RED
    jsr         copyTileToBuffers

    lda         #2
    sta         activeColumns

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

    ldx         #0

incOffsetLoop:
    clc
    lda         roadOffset0,x
    adc         roadSpeed0,x
    sta         roadOffset0,x
    lda         roadOffset1,x
    adc         roadSpeed1,x
    sta         roadOffset1,x
    inx
    cpx         activeColumns
    bne         incOffsetLoop

    ; point to first odd buffer
    lda         #$FF
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START+1
    sta         bufferPtr0+1

    ldx         #0
    ldy         #0
    sta         RAMWRTON        ; write to AUX
writeOffsetLoop:
    lda         roadOffset1,x
    and         #$7f
    sta         (bufferPtr0),y
    inc         bufferPtr0+1
    inc         bufferPtr0+1
    inx
    cpx         activeColumns
    bne         writeOffsetLoop
    sta         RAMWRTOFF       ; write to MAIN

    jsr         DISPATCH_CODE
    rts

.endproc

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
; copyTileToBuffers
;   Copies 2x8 tile to a buffer pair twice ($80 bytes apart)
;   Even bytes to the first buffer, odd bytes to the second buffer
;   A       - tile to copy
;   tileY   - offset line into buffer (must be < $80)
;   tileX   - first buffer number of the pair
;-----------------------------------------------------------------------------

.proc copyTileToBuffers

    ; set up tile pointer
    jsr         initTile

    ; set up buffer pointer
    lda         tileY
    sta         bufferPtr0
    sta         bufferPtr1
    lda         #>COLUMN_BUFFER_START
    clc
    adc         tileX
    sta         bufferPtr0+1
    sta         bufferPtr1+1
    inc         bufferPtr1+1

    ldx         #8              ; 8 rows
    ldy         #0

    sta         CLR80COL        ; Use RAMWRT for aux mem
    sta         RAMWRTON        ; Write to AUX

drawLoop:
    ; even
    ldy         #0
    lda         (tilePtr0),y
    sta         (bufferPtr0),y
    ldy         #$80
    sta         (bufferPtr0),y
    inc         tilePtr0
    ; odd
    ldy         #0
    lda         (tilePtr0),y
    sta         (bufferPtr1),y
    ldy         #$80
    sta         (bufferPtr1),y
    inc         tilePtr0
    inc         bufferPtr0
    inc         bufferPtr1
    dex
    bne         drawLoop

    sta         RAMWRTOFF       ; Write to MAIN
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
    lda         #$00
    sta         screenPtr0
    lda         #$80
    sta         tilePtr0
    clc
    lda         #$20
    adc         drawPage
    sta         screenPtr1
    sta         tilePtr1

loop:
    ldy         #$77            ; preserve screen holes
loopPage:
    lda         colorOdd
    sta         (screenPtr0),y
    sta         (tilePtr0),y
    dey
    lda         colorEven
    sta         (screenPtr0),y
    sta         (tilePtr0),y
    dey
    bpl         loopPage

    inc         tilePtr1
    inc         screenPtr1
    lda         screenPtr1
    and         #$1f
    bne         loop

    rts

.endproc

;-----------------------------------------------------------------------------
; Init code
;
;  Write unrolled column drawing routines to aux memory
;-----------------------------------------------------------------------------

.proc initCode

; Reuse zero page addresses

columnCount     := tileX
pageCount       := tileY
codePtr0        := tilePtr0
codePtr1        := tilePtr1

    jsr         HOME
    jsr         inline_print
    String      "Installing AUX code..."

    ; Use zero page for storage so can read/write even if only writing aux
    sta         CLR80COL        ; Use RAMWRT for aux mem
    sta         RAMWRTON        ; Write to AUX

    ; Init code pointer
    lda         #<COLUMN_CODE_START
    sta         codePtr0
    lda         #>COLUMN_CODE_START
    sta         codePtr1

    lda         #0
    sta         pageCount
    sta         drawPage

page_loop:
    ; Init buffer pointer (shared between pages)
    lda         #$00            ; Assuming page aligned
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START
    sta         bufferPtr1

    lda         #0
    sta         columnCount

column_loop:
    ldx         #COLUMN_STARTING_ROW

    ldy         #0

    ; If an even column, load x,y from last byte of buffer pair
    lda         columnCount
    and         #1
    bne         write_loop      ; skip if odd

    ; **    LDX BUFFER+$FF
    ; **    BPL NO_EXIT
    ; **    RTS
    ; ** NO_EXIT:
    ; **    LDY BUFFER+$1FF
    ; **    ...

    lda         #INSTRUCTION_LDX
    sta         (codePtr0),y
    iny
    lda         #$FF            ; end of buffer
    sta         (codePtr0),y
    iny
    lda         bufferPtr1
    sta         (codePtr0),y
    iny

    lda         #INSTRUCTION_BPL
    sta         (codePtr0),y
    iny
    lda         #$01            ; skip 1 byte (RTS)
    sta         (codePtr0),y
    iny

    lda         #INSTRUCTION_RTS
    sta         (codePtr0),y
    iny

    lda         #INSTRUCTION_LDY
    sta         (codePtr0),y
    iny
    lda         #$FF            ; end of buffer
    sta         (codePtr0),y
    iny
    lda         bufferPtr1
    clc
    adc         #1
    sta         (codePtr0),y
    iny

    ; increment code pointer
    clc
    tya
    adc         codePtr0
    sta         codePtr0
    lda         codePtr1
    adc         #0
    sta         codePtr1

write_loop:
    ldy         #0

    ; ** LDA BUFFER+ROW,Y
    ; ** STA SCREEN_ADRS,X

    lda         #INSTRUCTION_LDA_Y
    sta         (codePtr0),y
    iny
    lda         bufferPtr0
    sta         (codePtr0),y
    iny
    lda         bufferPtr1
    sta         (codePtr0),y
    iny

    lda         #INSTRUCTION_STA_X
    sta         (codePtr0),y
    iny
    lda         columnCount         ; If column odd, +1
    and         #1
    clc
    adc         fullLineOffset,x
    sta         (codePtr0),y
    iny
    lda         fullLinePage,x
    adc         drawPage
    sta         (codePtr0),y
    iny

    ; increment code pointer
    clc
    tya
    adc         codePtr0
    sta         codePtr0
    lda         codePtr1
    adc         #0
    sta         codePtr1

    ; increment buffer pointer
    inc         bufferPtr0          ; will deal with upper byte later

    inx
    cpx         #COLUMN_STARTING_ROW+COLUMN_ROWS
    bne         write_loop

    ; move to next buffer
    lda         #0
    sta         bufferPtr0
    inc         bufferPtr1

    inc         columnCount
    lda         columnCount
    cmp         #MAX_COLUMNS
    beq         doneColumns
    jmp         column_loop

doneColumns:
    ; ** RTS
    ldy         #0
    lda         #INSTRUCTION_RTS
    sta         (codePtr0),y
    iny

    clc
    tya
    adc         codePtr0
    sta         codePtr0
    lda         codePtr1
    adc         #0
    sta         codePtr1

    lda         #$20
    sta         drawPage

    inc         pageCount
    lda         pageCount
    cmp         #2
    beq         donePage
    jmp         page_loop

donePage:

    ; Dispatch
    jsr         copyDispatch        ; copy to aux
    sta         RAMWRTOFF           ; Write to Main
    jsr         copyDispatch        ; copy to main

    rts

copyDispatch:
    ldx         #0
copyLoop:
    lda         dispatchStart,x
    sta         DISPATCH_CODE,x
    inx
    cpx         #dispatchEnd-dispatchStart
    bne         copyLoop
    rts

dispatchStart:
    ; This code is being used as data to be copied to lower memory
    ; location in both main and aux memory to call the aux code.
    ; It must be relocatable.

    ; Determine what page to draw on
    lda         PAGE2           ; bit 7 = page2 displayed
    bmi         draw1
draw2:
    sta         RAMRDON         ; read from aux (including instructions)
    jsr         COLUMN_CODE_START_PAGE2
    sta         RAMRDOFF
    rts
draw1:
    sta         RAMRDON         ; read from aux (including instructions)
    jsr         COLUMN_CODE_START
    sta         RAMRDOFF
    rts
dispatchEnd:

.endproc

;-----------------------------------------------------------------------------
; Init buffers in aux memory
;-----------------------------------------------------------------------------

.proc initBuffers
    ; Init buffer pointer (shared between pages)
    lda         #$00            ; Assuming page aligned
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START
    sta         bufferPtr0+1

    lda         #0
    ldx         #0
    ldy         #0

    sta         CLR80COL        ; Use RAMWRT for aux mem
    sta         RAMWRTON        ; Write to AUX

zeroLoop:
    sta         (bufferPtr0),y
    iny
    bne         zeroLoop

    lda         bufferConfig,x
    ldy         #$FF
    sta         (bufferPtr0),y
    lda         #0

    inc         bufferPtr0+1
    inx
    cpx         #MAX_COLUMNS
    bne         zeroLoop

    sta         RAMWRTOFF       ; Write to MAIN

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

count:          .byte       0
playerX:        .byte       MAP_LEFT+TILE_WIDTH
playerY:        .byte       MAP_BOTTOM-TILE_HEIGHT*2
playerState:    .byte       STATE_IDLE

activeColumns:  .byte       2

roadOffset0:    .byte       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
roadOffset1:    .byte       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
roadSpeed0:     .byte       $40,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
roadSpeed1:     .byte       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

bufferConfig:   ; even bytes column X, odd byte column offset
                .byte       8,0
                .byte       10,0
                .byte       $FF,0
                .byte       $FF,0
                .byte       $FF,0
                .byte       $FF,0
                .byte       $FF,0
                .byte       $FF,0

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

.align 256
tileSheet:
.include        "font.asm"




