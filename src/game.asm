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

MAP_WIDTH               = 20
MAP_HEIGHT              = 24

MAX_OBJECTS             = 4
PLAYER_START_X          = 4
PLAYER_START_Y          = 12
BLOCK1_START_X          = 7
BLOCK1_START_Y          = 10

TILE_EMPTY              = $40
TILE_DOOR_PARTIAL       = $5A

TILE_FLAG_WALK_THROUGH  = 1<<0
TILE_FLAG_FALLING       = 1<<1
TILE_FLAG_LADDER        = 1<<2

STATE_WALL_LEFT         = 1<<0
STATE_WALL_RIGHT        = 1<<1
STATE_STANDING          = 1<<2
STATE_LADDER            = 1<<3
STATE_TOP_LADDER        = 1<<4

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    jsr         scrollV          ; test speed of hard coded scroll

    ; init
    jsr         HOME            ; clear screen
    lda         #23             ; put cursor on last line
    sta         CV
    jsr         VTAB

    sta         TXTCLR          ; graphics mode
    sta         HIRES           ; highres
    sta         MIXCLR          ; full screen

    lda         #$00
    sta         drawPage        ; screen1
    jsr         drawMap

    lda         #$20
    sta         drawPage        ; screen2
    jsr         drawMap


    ; Set up player
    jsr         resetPlayer

    ; Set up block1
    lda         #<spriteBox
    sta         spritePtr0+1
    lda         #>spriteBox
    sta         spritePtr1+1
    lda         #0
    sta         posX0+1
    sta         posY0+1
    lda         #BLOCK1_START_X
    sta         posX1+1
    lda         #BLOCK1_START_Y*8
    sta         posY1+1
    lda         #0
    sta         deltaY0+1
    lda         #0
    sta         deltaX0+1
    sta         deltaX1+1
    sta         deltaY1+1

game_loop:

    inc         timer
    lda         timer
    and         #3
    sta         frame
    eor         #2
    sta         frame_m2    ; current frame -2

    ; debug
    lda         #1
    sta         tileX
    sta         tileY
    lda         posX1
    jsr         drawByte
    lda         posX0
    jsr         drawByte

    lda         #1
    sta         tileX
    lda         #2
    sta         tileY
    lda         posY1
    jsr         drawByte
    lda         posY0
    jsr         drawByte

    lda         #6
    sta         tileX
    lda         #1
    sta         tileY
    lda         state
    jsr         drawByte

    jsr         script

    ; Button?
    lda         BUTTON0
    bpl         :+

    lda         state
    and         #STATE_STANDING
    beq         :+
    lda         #$40
    sta         deltaY0
    lda         #$ff
    sta         deltaY1
    jmp         doneMoveRightLeft
:
    lda         BUTTON1
    bpl         :+
    jsr         resetPlayer
    jmp         doneMove
:

    ; only move if standing
    lda         state
    and         #STATE_STANDING
    beq         doneMoveRightLeft

    ldx         paddleX
walking:
    ; Check left
    lda         leftSpeed,x
    beq         notLeft
    sta         deltaX0
    lda         #$ff
    sta         deltaX1
    lda         #<spritePlayerPushingLeft
    sta         spritePtr0
    lda         #>spritePlayerPushingLeft
    sta         spritePtr1
    jmp         doneMoveRightLeft
notLeft:

    ; Check right
    lda         rightSpeed,x
    beq         notRight
    sta         deltaX0
    lda         #$00
    sta         deltaX1
    lda         #<spritePlayerPushingRight
    sta         spritePtr0
    lda         #>spritePlayerPushingRight
    sta         spritePtr1
    jmp         doneMoveRightLeft

notRight:
    lda         #0
    sta         deltaX0
    sta         deltaX1
    lda         #<spritePlayerIdleLeft
    sta         spritePtr0


doneMoveRightLeft:

    ; only climb if on ladder
    lda         state
    and         #STATE_LADDER
    beq         checkDown

    lda         paddleY
    cmp         #$00
    bne         checkDown
    dec         posY1           ; ladder up
    jmp         finishLadder

checkDown:
    lda         state
    and         #STATE_TOP_LADDER
    bne         :+
    lda         state
    and         #STATE_LADDER
    beq         doneMove
:
    lda         paddleY
    cmp         #$f0
    bne         doneMove
    inc         posY1           ; ladder down

finishLadder:
    lda         posY1
    and         #$08
    bne         :+
    lda         #<spritePlayerClimbingLeft
    sta         spritePtr0
    lda         #>spritePlayerClimbingLeft
    sta         spritePtr1
    jmp         doneMove
:
    lda         #<spritePlayerClimbingRight
    sta         spritePtr0
    lda         #>spritePlayerClimbingRight
    sta         spritePtr1


doneMove:
    lda         #0
    sta         currentObject

object_loop:
    ldx         currentObject

    jsr         setTileXY
    jsr         setObjectState

    ; check if on ladder
    ldx         currentObject
    lda         state,x
    and         #STATE_LADDER
    beq         :+
    lda         #0
;    sta         deltaX0,x
;    sta         deltaX1,x
    sta         deltaY0,x
    sta         deltaY1,x
    jmp         notFalling
:
    ; check if falling
    ldx         currentObject
    lda         state,x
    and         #STATE_STANDING
    bne         notFalling
    lda         #<spritePlayerJumpingLeft
    sta         spritePtr0
    clc
    lda         deltaY0,x
    adc         #8
    sta         deltaY0,x
    lda         deltaY1,x
    adc         #0
    sta         deltaY1,x
notFalling:

    ; update position
    clc
    lda         posX0,x
    adc         deltaX0,x
    sta         posX0,x
    lda         posX1,x
    adc         deltaX1,x
    sta         posX1,x
    clc
    lda         posY0,x
    adc         deltaY0,x
    sta         posY0,x
    lda         posY1,x
    adc         deltaY1,x
    sta         posY1,x

    ; check if landing on floor
    ldx         currentObject
    jsr         setTileXY
    jsr         checkFallingCollision
    bcc         floorGood
    ldx         currentObject
    lda         posY1,x
    and         #$f8
    sta         posY1,x
    lda         #0
    sta         posY0,x
    sta         deltaY0,x
    sta         deltaY1,x
floorGood:

    ; check for walking into wall
    ldx         currentObject
    jsr         setTileXY
    jsr         checkWalkingCollision   ; check wall to left
    bcc         doneWallLeft
    ldx         currentObject
    inc         posX1,x
    lda         #0
    sta         posX0,x
    sta         deltaX0,x
    sta         deltaX1,x
doneWallLeft:

    inc         tileX
    jsr         checkWalkingCollision   ; check wall to right
    bcc         doneWallRight
    ldx         currentObject
    dec         posX1,x
    lda         #255
    sta         posX0,x
    lda         #0
    sta         deltaX0,x
    sta         deltaX1,x
doneWallRight:
    dec         tileX                   ; restore

    ; erase object
    lda         currentObject
    asl
    asl                     ; x4
    sta         currentObject4
    ora         frame_m2
    tax
    lda         objTileX,x
    sta         tileX
    lda         objTileY,x
    sta         tileY
    jsr         drawPatch

    ; remember new coordinates
    ldy         currentObject
    lda         currentObject4
    ora         frame
    tax
    lda         posX1,y
    sta         objTileX,x
    lda         posY1,y
    lsr
    lsr
    lsr
    sta         objTileY,x

    ; draw new
    jsr         drawSprite

    inc         currentObject
    lda         currentObject
    cmp         numObjects
    beq         :+

    jmp         object_loop
:

; Switch display

    lda         PAGE2           ; bit 7 = page2 displayed
    bmi         switchTo1

;switchTo2
    ; switch page
    bit         HISCR           ; display high screen
    lda         #$00            ; update low screen
    sta         drawPage

    ; Update X
    ldx         #0
    jsr         PREAD           ; read joystick X
    tya
    lsr
    lsr
    lsr
    lsr                         ; 16 divisions
    and         #$0f
    sta         paddleX
    ora         paddleY
    sta         prevXY0
    jmp         game_loop

switchTo1:
    ; switch page
    bit         LOWSCR          ; display low screen
    lda         #$20            ; update high screen
    sta         drawPage

    ; Update Y
    ldx         #1
    jsr         PREAD           ; read joystick Y
    tya
    and         #$f0            ; 4 upper bits
    sta         paddleY
    ora         paddleX
    sta         prevXY1

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

rightSpeed:     .byte   0,      0,      0,      0,      0,      0,      0,      0,  0, 3,   6,  9,  12, 15, 18, 21
leftSpeed:      .byte   256-21, 256-18, 256-15, 256-12, 256-9,  256-6,  256-3,  0,  0, 0,   0,  0,  0,  0,  0,  0
.endproc


.proc setTileXY
    ; set tileX&Y
    lda         posX1,x
    sta         tileX
    lda         posY1,x
    lsr
    lsr
    lsr
    sta         tileY
    lda         posY1,x
    and         #$7
    beq         :+
    inc         tileY
:
    rts
.endproc

;-----------------------------------------------------------------------------
; resetPlayer
;-----------------------------------------------------------------------------

.proc resetPlayer
    lda         #<spritePlayerIdleRight
    sta         spritePtr0
    lda         #>spritePlayerIdleRight
    sta         spritePtr1
    lda         #0
    sta         posX0
    sta         posY0
    lda         #PLAYER_START_X
    sta         posX1
    lda         #PLAYER_START_Y*8
    sta         posY1
    lda         #0
    sta         deltaX0
    sta         deltaX1
    sta         deltaY0
    sta         deltaY1
    rts
.endproc

;-----------------------------------------------------------------------------
; drawByte
;-----------------------------------------------------------------------------

.proc drawByte
    sta         temp
    lsr
    lsr
    lsr
    lsr
    and         #$f
    tax
    lda         nibble,x
    jsr         drawTile
    inc         tileX
    lda         temp
    and         #$f
    tax
    lda         nibble,X
    jsr         drawTile
    inc         tileX
    rts

temp:           .byte   0
nibble:         .byte   $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$21,$22,$23,$24,$25,$26

.endproc
;-----------------------------------------------------------------------------
; script
;-----------------------------------------------------------------------------
.proc script
    ; top of door
    lda         #20
    sta         tileY
    lda         #11
    sta         tileX

    lda         update
    beq         :+
    jsr         drawPatch
    lda         #0
    sta         update

:
    ; exit quick if done
    lda         state
    bpl         :+
    rts
:
    ; delay
    lda         timer
    and         #$1f
    beq         :+
    rts

:
    jsr         setMapRow

    lda         state           ; state = 0
    bne         :+
    ldy         #11+MAP_WIDTH
    lda         #TILE_DOOR_PARTIAL
    sta         (mapPtr0),y
    jmp         done
:
    cmp         #1              ; state = 1
    bne         :+
    ldy         #11+MAP_WIDTH
    lda         #TILE_EMPTY
    sta         (mapPtr0),y
    jmp         done
:
    cmp         #2              ; state = 2
    bne         :+
    ldy         #11
    lda         #TILE_DOOR_PARTIAL
    sta         (mapPtr0),y
    jmp         done
:
                                ; state = 3
    ldy         #11
    lda         #TILE_EMPTY
    sta         (mapPtr0),y
    lda         #$80
    sta         state

done:
    jsr         drawPatch
    inc         update
    inc         state
    rts

state:      .byte   0
update:     .byte   0
.endproc


;-----------------------------------------------------------------------------
; setObjectState
;
;   Update object state with the following
;       standing:  Y %8 and a solid tile below
;       wallLeft:  wall left and   x0 == 0
;       wallRight: wall right and x0 == 255
;       ladder:    occupying ladder (not on top)
;       topLadder: standing on ladder
;-----------------------------------------------------------------------------

.proc setObjectState
    lda     #0
    sta     newState

    jsr     setMapRow
    clc

    ldx     currentObject
    lda     posX0,x
    sta     checkPosX0
    lda     posY1,x
    and     #$07
    bne     checkWallLeft      ; if y0%8 != 0, not standing

checkStanding:
    ; check floor (x,y+2)
    lda     #MAP_WIDTH*2
    adc     tileX
    tay
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_LADDER
    bne     setTopLadder        ; standing on ladder
    lda     tileInfo,x
    and     #TILE_FLAG_FALLING
    beq     setStanding         ; not falling
    ; check floor (x+1,y+2)
    iny
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_LADDER
    bne     setTopLadder        ; standing on ladder
    lda     tileInfo,x
    and     #TILE_FLAG_FALLING
    beq     setStanding         ; not falling
    jmp     checkWallLeft
setTopLadder:
    lda     newState
    ora     #STATE_TOP_LADDER
    sta     newState
setStanding:
    lda     newState
    ora     #STATE_STANDING
    sta     newState

checkWallLeft:
    lda     checkPosX0
    bne     checkWallRight      ; if x0 != 0 not against wall left
    ; Check wall left (x-1,y)
    ldy     tileX
    dey                         ; x - 1
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+                  ; not wall
    jmp     setWallLeft
:   ; Check wall left (x-1,y+1)
    tya
    adc     #MAP_WIDTH          ; check next row
    tay
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+                  ; not wall
setWallLeft:
    lda     newState
    ora     #STATE_WALL_LEFT
    sta     newState
:

checkWallRight:
    lda     checkPosX0
    cmp     #$ff
    bne     checkLadder         ; if x0 != 255 not against wall right

    ; Check wall right (x+1,y)
    ldy     tileX
    iny                         ; x + 1
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+                  ; 0 = wall
    jmp     setWallRight
:   ; Check wall right (x+1,y+1)
    tya
    adc     #MAP_WIDTH          ; check next row
    tay
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+                  ; 0 = wall
setWallRight:
    lda     newState
    ora     #STATE_WALL_RIGHT
    sta     newState
:

checkLadder:
    ; check ladder (x,y)
    ldy     tileX
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_LADDER
    bne     setLadder
    ; check ladder (x,y+1)
    tya
    adc     #MAP_WIDTH          ; check next row
    tay
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_LADDER
    beq     done
setLadder:
    lda     newState
    ora     #STATE_LADDER
    sta     newState

done:
    ldx     currentObject
    lda     newState
    sta     state,x
    rts

newState:       .byte   0
checkPosX0:     .byte   0

.endproc

;-----------------------------------------------------------------------------
; checkWalkingCollision
;-----------------------------------------------------------------------------
.proc checkWalkingCollision
    jsr     setMapRow
    ldy     tileX
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+
    sec
    rts                         ; collision
:
    clc
    tya
    adc     #MAP_WIDTH
    tay
    lda     (mapPtr0),y
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_WALK_THROUGH
    bne     :+
    sec
    rts                         ; collision
:
    clc
    rts                         ; good!
.endproc

;-----------------------------------------------------------------------------
; checkFallingCollision
;-----------------------------------------------------------------------------
.proc checkFallingCollision
    jsr     setMapRow
    clc
    lda     tileX
    adc     #MAP_WIDTH*1
    tay
    lda     (mapPtr0),y         ; check (x,y+1)
    tax
    lda     tileInfo,x
    and     #TILE_FLAG_FALLING
    bne     :+
    sec
    rts                         ; collision
:
;    clc
;    iny
;    lda     (mapPtr0),y         ; check (x+1,y+2)
;    lda     tileInfo,x
;    and     #TILE_FLAG_FALLING
;    bne     :+
;    sec
;    rts                         ; collision
;:
    clc
    rts                         ; good!
.endproc

;-----------------------------------------------------------------------------
; setMapRow
;
;   set mapPtr based on tileY
;
;-----------------------------------------------------------------------------

.proc setMapRow

    ; y * map_width(20)
    ldx         tileY
    lda         mapPage,x
    clc
    adc         #>mapData
    sta         mapPtr1
    lda         mapOffset,x
    ;adc        #<mapData      ; Skip if map data is align to page
    sta         mapPtr0
    rts

.endproc

;-----------------------------------------------------------------------------
; drawPatch
;
;       draw 2x3 patch
;-----------------------------------------------------------------------------

.proc drawPatch
    jsr         setMapRow
    lda         tileX
    sta         mapIndex

    tay
    lda         (mapPtr0),y
    jsr         drawTile
    inc         tileX
    inc         mapIndex
    ldy         mapIndex
    lda         (mapPtr0),y
    jsr         drawTile

    inc         tileY
    dec         tileX

    clc
    lda         mapIndex
    adc         #MAP_WIDTH-1
    sta         mapIndex

    tay
    lda         (mapPtr0),y
    jsr         drawTile
    inc         tileX
    inc         mapIndex
    ldy         mapIndex
    lda         (mapPtr0),y
    jsr         drawTile

    inc         tileY
    dec         tileX

    clc
    lda         mapIndex
    adc         #MAP_WIDTH-1
    sta         mapIndex

    tay
    lda         (mapPtr0),y
    jsr         drawTile
    inc         tileX
    inc         mapIndex
    ldy         mapIndex
    lda         (mapPtr0),y
    jsr         drawTile

    rts

mapIndex:       .byte   0

.endproc

;-----------------------------------------------------------------------------
; drawMap
;
;   Display map
;
;-----------------------------------------------------------------------------

.proc drawMap
    lda         #<mapData
    sta         mapPtr0
    lda         #>mapData
    sta         mapPtr1

    lda         #0
    sta         mapIdx
    sta         tileY

loopY:
    lda         #0
    sta         tileX
loopX:
    ldy         #0
    lda         (mapPtr0),y
    jsr         drawTile

    inc         mapPtr0
    bne         :+
    inc         mapPtr1
:
    inc         tileX
    lda         tileX
    cmp         #MAP_WIDTH
    bne         loopX

    inc         tileY
    lda         tileY
    cmp         #MAP_HEIGHT
    bne         loopY

    rts

mapIdx:     .byte   0

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

.proc invertTile

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
    lda         (screenPtr0),y
    eor         #$7f
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    eor         #$7f
    sta         (screenPtr0),y
    dey

    ; next row
    lda         screenPtr1
    adc         #4
    sta         screenPtr1
    dex
    bne         drawLoop

    rts

.endproc


;-----------------------------------------------------------------------------
; drawSprite -- 4 byte wide x 16 rows
;
;   Using different scales for x vs y
;       posX0 - fraction within 2 bytes (7 positions)
;       posX1 - aligned 2-bytes within row (0..19)
;       posY0 - fraction of pixel (not used for drawing)
;       posY1 - row to start drawing (0..191)
;-----------------------------------------------------------------------------

.proc drawSprite

    ldx         currentObject

    ; tile pointers
    clc
    ldy         posX0,x             ; fraction -> offset page
    lda         spritePtr1,x
    adc         div7offset,y        ; x2 divide by 7
    sta         tilePtr1
    lda         spritePtr0,x
    sta         tilePtr0

    ; mask pointer
    lda         #>spriteMask
    lda         div7offset,y        ; x2 divide by 7
    asl
    asl                             ; x4
    adc         #<spriteMask
    sta         maskPtr0

    lda         #>spriteMask
    sta         maskPtr1

    ; First row

    lda         posX1,x
    asl                             ; x2
    sta         drawOffset

    lda         posY1,x
    tax
    adc         #16
    sta         finalY

drawLoop:
    lda         drawPage
    adc         fullLinePage,x
    sta         screenPtr1
    lda         drawOffset
    adc         fullLineOffset,x
    sta         screenPtr0

    ldy         #0
    lda         (screenPtr0),y
    and         (maskPtr0),y
    ora         (tilePtr0),y
    sta         (screenPtr0),y

    iny
    lda         (screenPtr0),y
    and         (maskPtr0),y
    ora         (tilePtr0),y
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         (maskPtr0),y
    ora         (tilePtr0),y
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         (maskPtr0),y
    ora         (tilePtr0),y
    sta         (screenPtr0),y

    lda         tilePtr0
    adc         #4
    sta         tilePtr0

    ; Don't need to increment mask since every line the same
    ;lda         maskPtr0
    ;adc         #4
    ;sta         maskPtr0

    inx
    cpx         finalY
    bne         drawLoop

    rts

drawOffset:     .byte       0
finalY:         .byte       0

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

.align 256

spriteMask:     .byte   $80,$80,$FC,$FF   ;Offset 0
                .byte   $83,$80,$F0,$FF   ;Offset 2
                .byte   $8F,$80,$C0,$FF   ;Offset 4
                .byte   $BF,$80,$80,$FE   ;Offset 6
                .byte   $FF,$81,$80,$F8   ;Offset 1
                .byte   $FF,$87,$80,$E0   ;Offset 3
                .byte   $FF,$9F,$80,$80   ;Offset 5

timer:          .byte   0
frame:          .byte   0
frame_m2:       .byte   0

prevXY0:        .byte   0
prevXY1:        .byte   0
paddleX:        .byte   0
paddleY:        .byte   0

; Object data
; 0 = player, 1+ = blocks
currentObject:  .byte   0
currentObject4: .byte   0               ; current object x4
numObjects:     .byte   1               ; number of active objects
spritePtr0:     .res    MAX_OBJECTS
spritePtr1:     .res    MAX_OBJECTS
posX0:          .res    MAX_OBJECTS
posX1:          .res    MAX_OBJECTS
posY0:          .res    MAX_OBJECTS
posY1:          .res    MAX_OBJECTS
deltaX0:        .res    MAX_OBJECTS
deltaX1:        .res    MAX_OBJECTS
deltaY0:        .res    MAX_OBJECTS
deltaY1:        .res    MAX_OBJECTS
state:          .res    MAX_OBJECTS

objTileX:       .res    4*MAX_OBJECTS
objTileY:       .res    4*MAX_OBJECTS

; Flags
; 1 = walk through
; 2 = falling
; 4 = ladder
; Tiles with flags set
; 40 = blank
; 7B and 7D = ladder (only left side of ladder for climbing)
                ;        x0   x1   x2   x3   x4   x5   x6   x7   x8   x9   xA   xB   xC   xD   xE   xF
tileInfo:       .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 0x -- Text
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 1x
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 2x
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 3x
                .byte   $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 4x -- Graphics
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 5x
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; 6x
                .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $03, $00, $00  ; 7x
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

mapOffset:
    .byte       <(MAP_WIDTH*0 ), <(MAP_WIDTH*1 ), <(MAP_WIDTH*2 ), <(MAP_WIDTH*3 ), <(MAP_WIDTH*4),  <(MAP_WIDTH*5),  <(MAP_WIDTH*6),  <(MAP_WIDTH*7)
    .byte       <(MAP_WIDTH*8 ), <(MAP_WIDTH*9 ), <(MAP_WIDTH*10), <(MAP_WIDTH*11), <(MAP_WIDTH*12), <(MAP_WIDTH*13), <(MAP_WIDTH*14), <(MAP_WIDTH*15)
    .byte       <(MAP_WIDTH*16), <(MAP_WIDTH*17), <(MAP_WIDTH*18), <(MAP_WIDTH*19), <(MAP_WIDTH*20), <(MAP_WIDTH*21), <(MAP_WIDTH*22), <(MAP_WIDTH*23)

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

mapPage:
    .byte       >(MAP_WIDTH*0 ), >(MAP_WIDTH*1 ), >(MAP_WIDTH*2 ), >(MAP_WIDTH*3 ), >(MAP_WIDTH*4),  >(MAP_WIDTH*5),  >(MAP_WIDTH*6),  >(MAP_WIDTH*7)
    .byte       >(MAP_WIDTH*8 ), >(MAP_WIDTH*9 ), >(MAP_WIDTH*10), >(MAP_WIDTH*11), >(MAP_WIDTH*12), >(MAP_WIDTH*13), >(MAP_WIDTH*14), >(MAP_WIDTH*15)
    .byte       >(MAP_WIDTH*16), >(MAP_WIDTH*17), >(MAP_WIDTH*18), >(MAP_WIDTH*19), >(MAP_WIDTH*20), >(MAP_WIDTH*21), >(MAP_WIDTH*22), >(MAP_WIDTH*23)

.align 256

div7offset:
    byteRep     0, 36   ;    0..35
    byteRep     1, 37   ;   36..72
    byteRep     2, 37   ;   73..109
    byteRep     3, 36   ;  110..145
    byteRep     4, 37   ;  146..182
    byteRep     5, 37   ;  183..219
    byteRep     6, 36   ;  220..255


;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------
.align 256
tileSheet:
.include        "font0.asm"

.align 256
.include        "spriteSheet.asm"


.align 256
mapData:
.include        "map.asm"

.include        "scroll.asm"




