;-----------------------------------------------------------------------------
; Paul Wasson - 2024
;-----------------------------------------------------------------------------
; Game
;-----------------------------------------------------------------------------

.segment        "CODE"
.org            $2000

.include        "defines.asm"

;-----------------------------------------------------------------------------
; Macros
;-----------------------------------------------------------------------------

.include        "macros.asm"

.macro  DrawStringCord stringX, stringY, string
    lda         #stringX
    sta         tileX
    lda         #stringY
    sta         tileY
    lda         #<string
    sta         stringPtr0
    lda         #>string
    sta         stringPtr1
    jsr         drawString
.endmacro

.macro  DrawStringBoth stringX, stringY, string
    DrawStringCord stringX, stringY, string
    lda         drawPage
    eor         #$20
    sta         drawPage
    lda         #stringX
    sta         tileX
    jsr         drawString
    lda         drawPage
    eor         #$20
    sta         drawPage
.endmacro

.macro  DrawImageParam imgX, imgY, imgWidth, imgHeight, imgPtr
    lda     #imgX
    sta     imageX
    lda     #imgY
    sta     imageY
    lda     #imgWidth
    sta     imageWidth
    lda     #imgHeight
    sta     imageHeight
    lda     #<imgPtr
    sta     tilePtr0
    lda     #>imgPtr
    sta     tilePtr1
    jsr     drawImage
.endmacro

;-----------------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------------

; reuse zero page addresses
bufferPtr0                  := mapPtr0      ; and +1
bufferPtr1                  := maskPtr0     ; and +1

; Memory Mapping
;---------------
DISPATCH_CODE               = $C00                          ; Dispatch code very small (<256 bytes)
                                                            ; Keep above prodos file buffer ($800..$BFF)
AUX_LEVEL_DATA              = $D00                          ; $D00 .. $2FFF
COLUMN_CODE_START           = $3000                         ; page0 offset $0000..$3048, page1 $3049..$6091
COLUMN_CODE_START_PAGE2     = COLUMN_CODE_START + $3049     ; include some padding after code to align buffers
COLUMN_BUFFER_START         = COLUMN_CODE_START + $6100     ; size=$1000
                                                            ; Total size = $7100

; Constants for draw loop unrolling
MAX_COLUMNS                 = 16
MAX_COLUMN_PAIRS            = MAX_COLUMNS/2

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
MAP_HORIZONTAL_TILES        = (MAP_RIGHT-MAP_LEFT)/TILE_WIDTH
MAP_VERTICAL_TILES          = (MAP_BOTTOM-MAP_TOP)/TILE_HEIGHT

MAP_INDEX_MIDDLE            = 0
MAP_INDEX_TOP               = 20
MAP_INDEX_BOTTOM            = 40

STATE_IDLE                  = 0
STATE_START_UP              = 1
STATE_MOVE_UP               = 2
STATE_START_DOWN            = 3
STATE_MOVE_DOWN             = 4
STATE_START_RIGHT           = 5
STATE_MOVE_RIGHT            = 6
STATE_START_LEFT            = 7
STATE_MOVE_LEFT             = 8
STATE_GAME_OVER             = $80
STATE_DEAD                  = $FF

PLAYER_INIT_X               = MAP_LEFT+TILE_WIDTH
PLAYER_INIT_Y               = MAP_BOTTOM-TILE_HEIGHT*2
PLAYER_INIT_STATE           = STATE_IDLE

MOVE_DELAY                  = 5
DEAD_DELAY                  = 150

TILE_GRASS                  = $46
TILE_GRASS_ROAD             = $47
TILE_ROAD                   = $57
TILE_ROAD_GRASS             = $45
TILE_GRASS_WATER            = $4D
TILE_WATER                  = $4E
TILE_WATER_GRASS            = $4F

TILE_CAR1_BLUE              = $44
TILE_CAR1_RED               = $53
TILE_CAR1_PURPLE            = $55
TILE_CAR2_A                 = $43
TILE_CAR2_B                 = $4B
TILE_TRUCKD_A               = $40
TILE_TRUCKD_B               = $48
TILE_TRUCKD_C               = $50
TILE_TRUCKU_A               = $41
TILE_TRUCKU_B               = $49
TILE_TRUCKU_C               = $51
TILE_TRAIN_A                = $61
TILE_TRAIN_B                = $69
TILE_TRAIN_C                = $71

TILE_LOG_A                  = $42
TILE_LOG_B                  = $4A
TILE_LOG_C                  = $52

TILE_TREE_A                 = $4C
TILE_TREE_MID               = $5C       ; use in middle of stack of trees
TILE_TREE_B                 = $54
TILE_ROCK                   = $58
TILE_CONE                   = $59
TILE_BUSH_WATER             = $5A       ; left of water
TILE_BUSH_ROAD              = $5B       ; left of road
TILE_COIN                   = $5F

TILE_BUFFER0                = $80
TILE_BUFFER1                = $81
TILE_BUFFER2                = $82
TILE_BUFFER3                = $83
TILE_BUFFER4                = $84
TILE_BUFFER5                = $85
TILE_BUFFER6                = $86
TILE_BUFFER7                = $87

TILE_TYPE_FREE              = $00
TILE_TYPE_MOVEMENT          = $01
TILE_TYPE_BLOCKED           = $02
TILE_TYPE_DEATH             = $04

TILE_TYPE_BUFFER0           = $80
TILE_TYPE_BUFFER1           = $90
TILE_TYPE_BUFFER2           = $A0
TILE_TYPE_BUFFER3           = $B0
TILE_TYPE_BUFFER4           = $C0
TILE_TYPE_BUFFER5           = $D0
TILE_TYPE_BUFFER6           = $E0
TILE_TYPE_BUFFER7           = $F0

PLAYER_OFFSET_IDLE          = $00
PLAYER_OFFSET_IDLE_MASK     = $10
PLAYER_OFFSET_DEAD          = $20
PLAYER_OFFSET_UP_1          = $30
PLAYER_OFFSET_UP_2          = $40
PLAYER_OFFSET_DOWN_1        = $50
PLAYER_OFFSET_DOWN_2        = $60
PLAYER_OFFSET_LEFT_1        = $70
PLAYER_OFFSET_LEFT_2        = $80
PLAYER_OFFSET_RIGHT_1       = $90
PLAYER_OFFSET_RIGHT_2       = $A0

SKIP_CHAR                   = '`' - $20

LEVEL_COLUMN_START          = $2F

;-----------------------------------------------------------------------------
; Title image
;-----------------------------------------------------------------------------
; Have the system load the title screen (first 3 bytes converted to jump)

.incbin "..\build\froggo.bin"

;-----------------------------------------------------------------------------
; Init code (run once)
;
; This code lives on the second hires page and will get overwritten.
; Only initial code to run once should be here.
;-----------------------------------------------------------------------------

.proc init
    jsr         HOME        ; clear screen
    jsr         TEXT        ; put cursor at the bottom

    ; restore image
    lda         #127
    sta         $2000
    sta         $2001
    sta         $2002

    ; display screen
    sta         MIXCLR
    sta         LOWSCR
    sta         HIRES
    sta         TXTCLR

    jsr         initCode
    jsr         uncompressScreen
    jsr         installLevelData

    jmp         main

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

    jsr         inline_print
    StringCR    "CHECKING MEMORY SIZE..."

    lda         $BF98
    bmi         :+
    jsr         inline_print
    StringCR    "128K MEMORY NOT DETECTED, EXITING"
    jmp         monitor
:

    jsr         inline_print
    StringCR    "Installing AUX code..."

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
; uncompressScreen
;
;   Set up pause screen on low-res page
;-----------------------------------------------------------------------------
.proc uncompressScreen

BG                  = $F
FG                  = $4
IMAGE               = img_pause_compressed

    lda         #$00
    sta         screenPtr0
    lda         #$04
    sta         screenPtr1

    lda         #0
    sta         index
    ldy         #0
loop:
    ldx         index
    lda         IMAGE,x
    sta         tempZP
    jsr         writeByte
    jsr         writeByte
    jsr         writeByte
    jsr         writeByte
    inc         index
    cpy         #128+120
    beq         next
    cpy         #120
    beq         skip
    jmp         loop
skip:
    ldy         #128
    jmp         loop
next:
    ldy         #0
    inc         screenPtr1
    lda         screenPtr1
    cmp         #8
    bne         loop
    rts

writeByte:
    lda         tempZP
    and         #%00000011
    tax
    lda         colorLookup,x
    sta         (screenPtr0),y
    iny
    lda         tempZP
    lsr
    lsr
    sta         tempZP
    rts

index:          .byte   0
colorLookup:    .byte   BG+BG*16,FG+BG*16,BG+FG*16,FG+FG*16

; qrcode
.include        "..\build\qrcode.asm"

.endproc


;-----------------------------------------------------------------------------
; Install Level Data to aux memory
;-----------------------------------------------------------------------------

.proc installLevelData

    lda         #<LEVEL_DATA_START
    sta         bufferPtr0
    lda         #>LEVEL_DATA_START
    sta         bufferPtr0+1

    lda         #<AUX_LEVEL_DATA
    sta         bufferPtr1
    lda         #>AUX_LEVEL_DATA
    sta         bufferPtr1+1

    sta         RAMWRTON            ; Write to AUX

    ldy         #0
loop1:
    lda         (bufferPtr0),y
    sta         (bufferPtr1),y
    iny
    bne         loop1

    inc         bufferPtr0+1
    inc         bufferPtr1+1
    lda         bufferPtr0+1
    cmp         #>LEVEL_DATA_END
    bne         loop1

    sta         RAMWRTOFF           ; Write to Main

    rts

; start and end aligned
.align 256
; level column data
LEVEL_DATA_START:
.include        "levels.asm"
.align 256
LEVEL_DATA_END:

.endproc

;-----------------------------------------------------------------------------
; Data to be used or copied to aux memory (will get overwritten)
;-----------------------------------------------------------------------------

; pretend there is more data to keep the linker happy
.res            $1A00

;=============================================================================
.align $100
;=============================================================================

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    PlaySongPtr songGameStart
    jsr         initGameState
    jsr         waitForKey
    jsr         initDisplay

reset_loop:
    jsr         loadLevel
    jsr         drawScreen
    jsr         initLevelState

game_loop:

    jsr         drawRoad
    jsr         updatePlayer

    ; Flip display page
    ;---------------------------

    lda         PAGE2           ; bit 7 = page2 displayed
    bmi         switchTo1

;switchTo2
    ; switch page
    jsr         drawPlayer1
    bit         HISCR           ; display high screen
    lda         #$00            ; update low screen
    sta         drawPage
    jsr         erasePlayer0
    jmp         game_loop

switchTo1:
    ; switch page
    jsr         drawPlayer0
    bit         LOWSCR          ; display low screen
    lda         #$20            ; update high screen
    sta         drawPage
    jsr         erasePlayer1

    ; Check for user input
    ;---------------------------

    ; wait for keypress
    lda         KBD
    bmi         :+
    jmp         game_loop
:
    bit         KBDSTRB

    cmp         #KEY_TAB
    bne         :+
    jsr         showPause
    jmp         game_loop
:

    cmp         #KEY_ESC
    bne         :+
    jmp         quit
:
    cmp         #KEY_ASTERISK
    bne         :+
    jmp         monitor
:
    cmp         #KEY_RETURN
    bne         :+
    jsr         finishLevel
    jmp         reset_loop
:

    ; if game over, hit a key to restart
    ldx         playerState
    cpx         #STATE_GAME_OVER
    bne         :+
    jsr         initGameState
    PlaySongPtr songGameStart
    jmp         reset_loop  ; restart game
:
    ; only process movement keypress if player is idle
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
    jsr         updateState
    jmp         game_loop
:
    jmp         game_loop

goRight:
    ; check if at right edge
    lda         playerX
    cmp         #(MAP_RIGHT-TILE_WIDTH*2)
    beq         atRightEdge
    lda         playerX
    sta         tileX
    lda         playerTileY
    sta         tileY
    inc         tileX
    inc         tileX               ; check right
    jsr         movementCheck
    bne         :+
    lda         #STATE_START_RIGHT
    jsr         updateState
:
    jmp         game_loop

atRightEdge:
    jsr         finishLevel
    jmp         reset_loop

goLeft:
    ; check if at left edge
    lda         playerX
    cmp         #(MAP_LEFT+TILE_WIDTH)
    beq         :+
    lda         playerX
    sta         tileX
    lda         playerTileY
    sta         tileY
    dec         tileX
    dec         tileX               ; check right
    jsr         movementCheck
    bne         :+
    lda         #STATE_START_LEFT
    jsr         updateState
:
    jmp         game_loop

goUp:
    ; check if at top
    lda         playerTileY
    cmp         #(MAP_TOP+TILE_HEIGHT)
    beq         :+
    lda         playerX
    sta         tileX
    lda         playerTileY
    sta         tileY
    dec         tileY               ; check above
    jsr         movementCheck
    bne         :+
    lda         #STATE_START_UP
    jsr         updateState
:
    jmp         game_loop

goDown:
    ; check if at bottom
    lda         playerTileY
    cmp         #(MAP_BOTTOM-TILE_HEIGHT*2)
    beq         :+
    lda         playerX
    sta         tileX
    lda         playerTileY
    sta         tileY
    inc         tileY               ; check below
    jsr         movementCheck
    bne         :+
    lda         #STATE_START_DOWN
    jsr         updateState
:
    jmp         game_loop

drawPlayer0:
    lda         drawTileX0
    sta         eraseTileX0_0
    lda         drawTileY0
    sta         eraseTileY0_0
    lda         drawTileX1
    sta         eraseTileX1_0
    lda         drawTileY1
    sta         eraseTileY1_0
    rts

drawPlayer1:
    lda         drawTileX0
    sta         eraseTileX0_1
    lda         drawTileY0
    sta         eraseTileY0_1
    lda         drawTileX1
    sta         eraseTileX1_1
    lda         drawTileY1
    sta         eraseTileY1_1
    rts

erasePlayer0:
    lda         eraseTileX0_0
    sta         tileX
    lda         eraseTileY0_0
    sta         tileY
    jsr         eraseTile

    dec         tileY
    jsr         eraseTile
    inc         tileY
    inc         tileY
    lda         tileY
    cmp         #MAP_BOTTOM-TILE_HEIGHT
    beq         :+
    jsr         eraseTile
:
    lda         eraseTileX1_0
    sta         tileX
    lda         eraseTileY1_0
    sta         tileY
    jsr         eraseTile
    rts

erasePlayer1:
    lda         eraseTileX0_1
    sta         tileX
    lda         eraseTileY0_1
    sta         tileY
    jsr         eraseTile

    dec         tileY
    jsr         eraseTile
    inc         tileY
    inc         tileY
    lda         tileY
    cmp         #MAP_BOTTOM-TILE_HEIGHT
    beq         :+
    jsr         eraseTile
:
    lda         eraseTileX1_1
    sta         tileX
    lda         eraseTileY1_1
    sta         tileY
    jsr         eraseTile
    rts

.endproc

;-----------------------------------------------------------------------------
; Finish Level
;-----------------------------------------------------------------------------
.proc finishLevel

    lda         displayLevel
    clc
    sed
    adc         #1
    sta         displayLevel
    cld

    ; Drawing on high screen

    ; Display image
    DrawImageParam  MAP_LEFT,MAP_TOP*8,(MAP_RIGHT-MAP_LEFT),(MAP_BOTTOM-MAP_TOP)*8,cutScene
    DrawStringCord  0, 22, stringLevelComplete

    ; display Image
    bit         HISCR
    PlaySongPtr songLevelComplete

    ; Preload next cutscene
    inc         sceneFileNameEnd-1
    lda         sceneFileNameEnd-1
    cmp         #'7'
    bne         :+
    lda         #'0'
    sta         sceneFileNameEnd-1
:
    jsr         loadCutScene
    jsr         waitForKey

    bit         LOWSCR
    rts
.endproc

.proc waitForKey
    ; kill extra keypress
    bit         KBDSTRB

    lda         #15         ; about 10 seconds
    sta         wait
    ldy         #0
    ldx         #0
loop:
    lda         KBD
    bmi         done
    dex
    bne         loop
    dey
    bne         loop
    dec         wait
    bne         loop
    ; timeout
done:
    bit         KBDSTRB
    rts

wait:           .byte   0
.endproc


;-----------------------------------------------------------------------------
; Load Cut Scene
;-----------------------------------------------------------------------------
.proc loadCutScene
    ldx         #FILE_SCENE
    jsr         loadData
    lda         fileError
    beq         :+
    jsr         monitor
:
    rts
.endproc

;-----------------------------------------------------------------------------
; Update State
;-----------------------------------------------------------------------------
.proc updateState
    sta         playerState
    ldx         #0
    stx         count
    stx         count+1
    cmp         #STATE_DEAD
    bne         :+
    DrawStringBoth  0, 22, stringGameOver
    PlaySongPtr songOuch
    rts
:
    cmp         #STATE_GAME_OVER
    bne         :+
    DrawStringBoth  0, 22, stringPressKey
    PlaySongPtr songDead
    rts
:
    rts
.endproc

;-----------------------------------------------------------------------------
; Set Movement
;-----------------------------------------------------------------------------
.proc setMovement

    ; check if on dynamic column
    lda         playerX
    lsr
    tay
    lda         bgTiles,y
    bpl         :+
    and         #$07
    tax
    lda         bufferOffset1,x
    clc
    adc         playerY
    sta         initialOffset
    rts
:
    ; Make Y align to tiles
    lda         playerY
    clc
    adc         #4
    lsr
    lsr
    lsr
    sta         playerTileY
    asl
    asl
    asl
    sta         playerY
    rts

.endproc

;-----------------------------------------------------------------------------
; Update Player
;-----------------------------------------------------------------------------
.proc updatePlayer
    inc         count
    bne         :+
    inc         count+1
:
    lda         playerX
    sta         tileX
    sta         drawTileX0
    sta         drawTileX1
    lda         playerTileY
    sta         tileY
    sta         drawTileY0
    sta         drawTileY1

    ; check final states
    lda         playerState
    cmp         #STATE_GAME_OVER
    bne         :+
    rts
:
    cmp         #STATE_DEAD
    bne         :+
    lda         #PLAYER_OFFSET_DEAD
    jsr         drawPlayerOR
    lda         count
    cmp         #DEAD_DELAY
    bne         doneDead
    lda         #STATE_GAME_OVER
    jmp         updateState
doneDead:
    rts
:

    ; player is alive, so check environment before processing state

    ; Above the top?
    lda         playerY
    cmp         #(MAP_TOP+TILE_HEIGHT)*8-6
    bcs         :+
    lda         #STATE_DEAD
    jmp         updateState
:

    ; Below the bottom?
    cmp         #(MAP_BOTTOM-2*TILE_HEIGHT)*8+7
    bcc         :+
    lda         #STATE_DEAD
    jmp         updateState
:

    jsr         tile2array
    tax
    lda         tileTypeArray,x
    sta         currentTileType
    and         #TILE_TYPE_DEATH
    beq         :+
    lda         #STATE_DEAD
    jmp         updateState
:
    ; dynamic column?
    lda         currentTileType
    bmi         :+
    jmp         doneDynamic
:

    ; calculate indexes into buffer
    and         #$70
    sta         columnBase
    lsr
    lsr
    lsr
    lsr         ; column #
    tax
    lda         bufferOffset1,x
    sta         currentOffset
    clc
    adc         playerY
    adc         #256-(MAP_TOP*8-1)
    sta         playerOffset
    lsr
    lsr
    lsr         ; divide by 8
    and         #$f
    sta         tileTop             ; playerY + offset + 1

    lda         playerOffset
    clc
    adc         #4
    lsr
    lsr
    lsr         ; divide by 8
    and         #$f
    sta         tileMiddle

    lda         playerOffset
    clc
    adc         #5
    and         #$7f
    lsr
    lsr
    lsr         ; divide by 8
    and         #$f
    sta         tileBottom          ; playerY + offset + 6

    ; check for movement first
    lda         columnBase
    ora         tileMiddle
    tax
    lda         tileDynamicType,x
    and         #TILE_TYPE_MOVEMENT
    beq         :+

    lda         initialOffset
    sec
    sbc         currentOffset
    sta         playerY
    clc
    adc         #4
    lsr
    lsr
    lsr                             ; /8
    sta         playerTileY
    jmp         doneDynamic
:

    lda         columnBase
    ora         tileTop
    tax
    lda         tileDynamicType,x
    and         #TILE_TYPE_DEATH
    beq         :+
    jmp         dead
:
    lda         columnBase
    ora         tileBottom
    tax
    lda         tileDynamicType,x
    and         #TILE_TYPE_DEATH
    beq         :+
dead:
    lda         #STATE_DEAD
    jsr         updateState
    rts
:

doneDynamic:
    ; check alive states
    lda         playerState
    cmp         #STATE_IDLE
    bne         :+
    lda         #PLAYER_OFFSET_IDLE
    jsr         drawPlayerOR
    rts
:
    cmp         #STATE_START_LEFT
    bne         :+
    dec         drawTileX1
    dec         drawTileX1
    lda         #PLAYER_OFFSET_LEFT_2
    jsr         drawPlayerOR
    dec         playerX
    dec         playerX
    lda         #PLAYER_OFFSET_LEFT_1
    jsr         drawPlayerOR
    inc         playerX
    inc         playerX
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneLeft
    lda         #STATE_MOVE_LEFT
    jsr         updateState
doneLeft:
    rts
:
    cmp         #STATE_MOVE_LEFT
    bne         :+
    dec         drawTileX0
    dec         drawTileX0
    dec         playerX
    dec         playerX
    lda         #PLAYER_OFFSET_IDLE
    jsr         drawPlayerOR
    lda         #STATE_IDLE
    jsr         updateState
    jsr         setMovement
    rts
:
    cmp         #STATE_START_RIGHT
    bne         :+
    inc         drawTileX1
    inc         drawTileX1
    lda         #PLAYER_OFFSET_RIGHT_1
    jsr         drawPlayerOR
    inc         playerX
    inc         playerX
    lda         #PLAYER_OFFSET_RIGHT_2
    jsr         drawPlayerOR
    dec         playerX
    dec         playerX
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneRight
    lda         #STATE_MOVE_RIGHT
    jsr         updateState
doneRight:
    rts
:
    cmp         #STATE_MOVE_RIGHT
    bne         :+
    inc         drawTileX0
    inc         drawTileX0
    inc         playerX
    inc         playerX
    lda         #PLAYER_OFFSET_IDLE
    jsr         drawPlayerOR
    lda         #STATE_IDLE
    jsr         updateState
    jsr         setMovement
    rts
:
    cmp         #STATE_START_UP
    bne         :+
    dec         drawTileY1
    lda         #PLAYER_OFFSET_UP_2
    jsr         drawPlayerOR
    lda         playerY
    sta         saveY
    sec
    sbc         #8
    sta         playerY
    lda         #PLAYER_OFFSET_UP_1
    jsr         drawPlayerOR
    lda         saveY
    sta         playerY
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneUp
    lda         #STATE_MOVE_UP
    jsr         updateState
doneUp:
    rts
:
    cmp         #STATE_MOVE_UP
    bne         :+
    dec         drawTileY0
    lda         playerY
    sec
    sbc         #8
    sta         playerY
    lda         initialOffset
    sec
    sbc         #8
    sta         initialOffset
    dec         playerTileY
    lda         #PLAYER_OFFSET_IDLE
    jsr         drawPlayerOR
    lda         #STATE_IDLE
    jsr         updateState
    rts
:
    cmp         #STATE_START_DOWN
    bne         :+
    inc         drawTileY1
    lda         #PLAYER_OFFSET_DOWN_1
    jsr         drawPlayerOR
    lda         playerY
    sta         saveY
    clc
    adc         #8
    sta         playerY
    lda         #PLAYER_OFFSET_DOWN_2
    jsr         drawPlayerOR
    lda         saveY
    sta         playerY
    sta         SPEAKER
    lda         count
    cmp         #MOVE_DELAY
    bmi         doneDown
    lda         #STATE_MOVE_DOWN
    jsr         updateState
doneDown:
    rts
:
    cmp         #STATE_MOVE_DOWN
    bne         :+
    inc         drawTileY0
    lda         playerY
    clc
    adc         #8
    sta         playerY
    lda         initialOffset
    clc
    adc         #8
    sta         initialOffset
    inc         playerTileY
    lda         #PLAYER_OFFSET_IDLE
    jsr         drawPlayerOR
    lda         #STATE_IDLE
    jsr         updateState
    rts
:
    cmp         #STATE_GAME_OVER
    bne         :+
    rts
:
    brk         ; unknown state

saveY:              .byte   0
currentTileType:    .byte   0
columnBase:         .byte   0
playerOffset:       .byte   0
tileTop:            .byte   0
tileMiddle:         .byte   0
tileBottom:         .byte   0
currentOffset:      .byte   0
.endproc

;-----------------------------------------------------------------------------
; Tile 2 array
;
;   Convert (tileX,tileY) to an array index
;-----------------------------------------------------------------------------

.proc tile2array
    lda         tileX
    lsr                                     ; / TILE_WIDTH
    sta         index
    dec         index                       ; -1 to ignore left
    lda         tileY
    sec
    sbc         #(MAP_TOP+1)
    tax
    lda         mult18Table,x               ; mult Y by 18
    clc
    adc         index
    rts

index:          .byte   0

.endproc

;-----------------------------------------------------------------------------
; Erase Tile
;-----------------------------------------------------------------------------
; Read tile cache and erase
.proc eraseTile
    jsr         tile2array
    tax
    lda         tileCacheArray,x
    bmi         :+                  ; ignore active columns
    jmp         drawTile            ; chain returns
:
    rts

.endproc

;-----------------------------------------------------------------------------
; Movement check
;
;   Return 0 if not blocked
;-----------------------------------------------------------------------------
.proc movementCheck
    jsr         tile2array
    tax
    lda         tileTypeArray,x
    and         #TILE_TYPE_BLOCKED
    rts
.endproc

;-----------------------------------------------------------------------------
; Draw Road
;-----------------------------------------------------------------------------

.proc drawRoad

    ldx         #0

    lda         playerState
    cmp         #STATE_DEAD
    beq         :+

incOffsetLoop:
    clc
    lda         bufferOffset0,x
    adc         bufferSpeed0,x
    sta         bufferOffset0,x
    lda         bufferOffset1,x
    adc         bufferSpeed1,x
    sta         bufferOffset1,x
    inx
    cpx         activeColumns
    bne         incOffsetLoop

:

    ; point to first odd buffer
    lda         #$FF
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START+1
    sta         bufferPtr0+1

    ldx         #0
    ldy         #0
    sta         RAMWRTON        ; write to AUX
writeOffsetLoop:
    lda         bufferOffset1,x
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

mapLoop:
    lda         #0
    sta         index
drawRow:
    lda         #MAP_LEFT
    sta         tileX
rowLoop:
    ldy         index
    lda         bgTiles,y
    bmi         :+              ; skip active columns
    jsr         drawTile
:
    inc         index
    lda         tileX
    clc
    adc         #TILE_WIDTH
    sta         tileX
    cmp         #MAP_RIGHT
    bne         rowLoop

    inc         tileY
    lda         tileY
    cmp         #MAP_BOTTOM
    bne         mapLoop

    ldy         #0
    jsr         drawMisc
    rts

drawMisc:                       ; draw list of tiles (x,y,#) ending with 0
    sty         index

tileLoop:
    ldy         index
    lda         (scriptPtr0),y
    beq         doneDrawMisc
    sta         tileX
    iny
    lda         (scriptPtr0),y
    sta         tileY
    iny
    lda         (scriptPtr0),y
    iny
    sty         index
    jsr         drawTile
    jmp         tileLoop

doneDrawMisc:
    rts

index:          .byte   0

.endproc

;-----------------------------------------------------------------------------
; Draw text - add info to the screen
;-----------------------------------------------------------------------------
stringBoxTop:       TileText "/------------------\"
stringLevel:        TileText "_    LEVEL:        _"
stringBoxBottom:    TileText "[------------------]"
stringArrow:        TileText ">"
stringFroggo:       TileText "_ @    FROGGO    @ _"
stringGameOver:     TileText "_ @  GAME  OVER  @ _"
stringPressKey:     TileText "_   PRESS ANY KEY  _"
stringLevelComplete:TileText "_  LEVEL COMPLETE! _"
stringHint:         TileText "_MOVE KEYS: A,Z,<,>_"

LEVEL_X = 12*TILE_WIDTH
LEVEL_Y = 1*TILE_HEIGHT

.proc drawText
    DrawStringCord  0, 0,  stringBoxTop
    DrawStringCord  0, 1,  stringLevel
    DrawStringCord  0, 2,  stringBoxBottom
    DrawStringCord  38,3,  stringArrow
    DrawStringCord  38,20, stringArrow
    DrawStringCord  0, 21, stringBoxTop
    DrawStringCord  0, 22, stringFroggo
    DrawStringCord  0, 23, stringBoxBottom

    lda         #LEVEL_X
    sta         tileX
    lda         #LEVEL_Y
    sta         tileY
    lda         displayLevel
    lsr
    lsr
    lsr
    lsr
    and         #$f
    tax
    lda         digitTile,x
    jsr         drawTile
    lda         #LEVEL_X+TILE_WIDTH
    sta         tileX
    lda         displayLevel
    and         #$f
    tax
    lda         digitTile,x
    jsr         drawTile

    rts

digitTile:      .byte   $10,$11,$12,$13,$14,$15,$16,$17,$18,$19
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
; drawTile -- draw aligned 2-byte x 8 row tile
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
; drawPlayerOR -- OR 2x8 player shape, unaligned Y, aligned X
;
;   A       - start of shape in playerShapes
;   playerY - row to start drawing 0..183 (191-8)
;   playerX - column to start drawing 0..39
;-----------------------------------------------------------------------------


.proc drawPlayerOR

    sta         shapeOffset
    bne         :+
    jsr         drawPlayerAND       ; only shape 0 (idle) gets a mask
:
    lda         playerY
    sta         row
    clc
    adc         #8
    sta         lastRow

loop:
    ldx         row
    lda         playerX
    clc
    adc         fullLineOffset,x
    sta         screenPtr0
    lda         fullLinePage,x
    adc         drawPage
    sta         screenPtr1

    ldy         #0
    ldx         shapeOffset
    lda         (screenPtr0),y
    ora         playerShapes,x
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    ora         playerShapes+1,x
    sta         (screenPtr0),y
    inc         shapeOffset
    inc         shapeOffset
    inc         row
    lda         row
    cmp         lastRow
    bne         loop
    rts

shapeOffset:    .byte   0
row:            .byte   0
lastRow:        .byte   0

    rts

.endproc


; This code in a copy of above with "ora" -> "and".
; Any changes should be reflected above and then re-copied and substituted.

.proc drawPlayerAND

    lda         #PLAYER_OFFSET_IDLE_MASK        ; hard coded
    sta         shapeOffset
    lda         playerY
    sta         row
    clc
    adc         #8
    sta         lastRow

loop:
    ldx         row
    lda         playerX
    clc
    adc         fullLineOffset,x
    sta         screenPtr0
    lda         fullLinePage,x
    adc         drawPage
    sta         screenPtr1

    ldy         #0
    ldx         shapeOffset
    lda         (screenPtr0),y
    and         playerShapes,x
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         playerShapes+1,x
    sta         (screenPtr0),y
    inc         shapeOffset
    inc         shapeOffset
    inc         row
    lda         row
    cmp         lastRow
    bne         loop
    rts

shapeOffset:    .byte   0
row:            .byte   0
lastRow:        .byte   0

    rts

.endproc



;-----------------------------------------------------------------------------
; drawImage
;
;   imageX      - start byte column
;   imageY      - start row
;   imageWidth  - width (in bytes)
;   imageHeight - height
;   tilePtr0    - data
;-----------------------------------------------------------------------------

.proc drawImage

    lda         imageY
    tax
    clc
    adc         imageHeight
    sta         lastRow

yLoop:
    lda         imageX
    clc
    adc         fullLineOffset,x
    sta         screenPtr0
    lda         fullLinePage,x
    adc         drawPage
    sta         screenPtr1

    ldy         #0
xLoop:
    lda         (tilePtr0),y
    sta         (screenPtr0),y
    iny
    cpy         imageWidth
    bne         xLoop

    lda         tilePtr0
    clc
    adc         imageWidth
    sta         tilePtr0
    lda         tilePtr1
    adc         #0
    sta         tilePtr1

    inx
    cpx         lastRow
    bne         yLoop
    rts

lastRow:        .byte   0

.endproc

;-----------------------------------------------------------------------------
; drawString
;   Draw string on screen
;-----------------------------------------------------------------------------

.proc drawString
    ldy     #0

    ; Print characters until bit 7 set (end-of-string)
drawLoop:
    lda     (stringPtr0),y
    bpl     :+
    rts                 ; done
:
    sty     index
    cmp     #SKIP_CHAR  ; Skip instead of draw to save time
    beq     :+
    jsr     drawTile
:
    inc     tileX
    inc     tileX
    ldy     index
    iny
    jmp     drawLoop

index:      .byte   0

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
; initGameState
;-----------------------------------------------------------------------------

.proc initGameState
    lda         #0
    sta         fileError
    lda         #'0'
    sta         sceneFileNameEnd-1
    jsr         loadCutScene


    lda         #1
    sta         displayLevel
    lda         #0
    sta         currentLevel

    rts
.endproc

;-----------------------------------------------------------------------------
; initLevelState
;-----------------------------------------------------------------------------

.proc initLevelState
    lda         #0
    sta         fileError
    lda         #PLAYER_INIT_X
    sta         playerX
    sta         eraseTileX0_0
    sta         eraseTileX1_0
    sta         eraseTileX0_1
    sta         eraseTileX1_1
    lda         #PLAYER_INIT_Y*8
    sta         playerY
    lda         #PLAYER_INIT_Y
    sta         playerTileY
    sta         eraseTileY0_0
    sta         eraseTileY1_0
    sta         eraseTileY0_1
    sta         eraseTileY1_1
    lda         #PLAYER_INIT_STATE
    jsr         updateState
    lda         #0
    sta         count
    sta         count+1
    rts
.endproc

;-----------------------------------------------------------------------------
; initDisplay - Initialize display
;-----------------------------------------------------------------------------

.proc initDisplay

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
    rts

.endproc

;-----------------------------------------------------------------------------
; Draw Screen
;-----------------------------------------------------------------------------

.proc drawScreen
    ; display map on both pages
    lda         #$20
    sta         drawPage
    jsr         drawMap
    jsr         drawText
    jsr         drawRoad

    sta         HISCR       ; show high while drawing low
    lda         #$00
    sta         drawPage
    jsr         drawMap
    jsr         drawText
    jsr         drawRoad

    ; start with showing page1 and drawing on page2
    sta         LOWSCR
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

    inc         bufferPtr0+1
    inx
    cpx         #MAX_COLUMNS
    bne         zeroLoop

    sta         RAMWRTOFF       ; Write to MAIN

    rts

.endproc


;-----------------------------------------------------------------------------
; Set Active Buffers
;-----------------------------------------------------------------------------

.proc setActiveBuffers

    ldx         #0

    ; point to first even buffer
    lda         #$FF
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START
    sta         bufferPtr0+1

    ldx         #0
    ldy         #0
    sta         RAMWRTON        ; write to AUX
writeXLoop:
    lda         bufferX,x
    sta         (bufferPtr0),y
    inc         bufferPtr0+1
    inc         bufferPtr0+1
    inx
    cpx         #MAX_COLUMN_PAIRS
    bne         writeXLoop
    sta         RAMWRTOFF       ; write to MAIN
    rts

.endproc

.proc loadAuxLevel

    ; set level pointer
    lda         currentLevel
    asl
    asl
    asl
    asl
    asl                             ; *32
    sta         scriptPtr0
    lda         currentLevel
    lsr
    lsr
    lsr                             ; /8
    clc
    adc         #>AUX_LEVEL_DATA    ; assume page aligned
    sta         scriptPtr1

    rts
.endproc

;-----------------------------------------------------------------------------
; Load Level
;-----------------------------------------------------------------------------
; Format:
; [2]                           - link to next level
; [20]                          - background tiles (repeated for every row)
; [8]                           - column pair x coordinate ($FF for inactive)
; [8]                           - column pair speed (low byte)
; [8]                           - column pair speed (high byte)
; [1]                           - active columns (must be even)
; [16] x active-column-pairs    - tiles to copy to column-pair
; [1]                           - $00 [end of column data]
; [3] x misc-tile-count         - x,y,tile to draw on screen
; [1]                           - $00 [end of tile list]
;
; -> load bg tiles, buffer - x, speed*2
; -> sets activeColumns (used by draw road, could get rid of)
; -> copies tiles to active buffers
; -> copies tile type to dynamic array for collisions
; -> sets pointer to misc tiles
;-----------------------------------------------------------------------------

.proc loadLevel
    ; point to first level
    lda         #<levelData
    sta         scriptPtr0
    lda         #>levelData
    sta         scriptPtr1

    ldy         #2
configLoop:
    lda         (scriptPtr0),y
    sta         bgTiles-2,y
    iny
    cpy         #2+20+3*8
    bne         configLoop

    lda         (scriptPtr0),y
    sta         activeColumns
    iny
    sty         index

    lda         #0
    sta         tileX
columnLoop:
    lda         #0
    sta         tileY
tileLoop:
    ldy         index
    lda         (scriptPtr0),y
    beq         doneWithColumns
    sta         tileIndex
    jsr         copyTileToBuffers

    ldx         tileIndex
    lda         tileTypeTable,x
    ldy         index
    sta         tileDynamicType-LEVEL_COLUMN_START,y

    inc         index

    lda         tileY
    clc
    adc         #8
    sta         tileY
    cmp         #128
    bne         tileLoop

    inc         tileX
    inc         tileX
    jmp         columnLoop
doneWithColumns:

    ; set pointer to point to misc tiles for draw map
    iny
    tya
    clc
    adc         scriptPtr0
    sta         scriptPtr0
    lda         scriptPtr1
    adc         #0
    sta         scriptPtr1

    jsr         setActiveBuffers
    jsr         initTileArray       ; Set up collision detection

    rts

index:          .byte   0
tileIndex:      .byte   0

.endproc

;-----------------------------------------------------------------------------
; Init tile array
;   Tile array used for collision detection
;-----------------------------------------------------------------------------
; 18x14 array < 256 so can use absoluted index addressing
; Ignore first, last row and column (blocked from movement):
;   Columns = 20 - 2 = 18
;   Rows = 16 - 2 = 14
; Array values:
;   <$80    : bespoke type (see defines)
;   $80..$87: use column data 0..7
;-----------------------------------------------------------------------------
.proc initTileArray

    ; copy BG row down
    ldy         #0
    sty         index
bgYLoop:
    ldx         #0
bgXLoop:
    ldy         bgTiles+1,x                 ; ignore row columns 0 & 19
    sty         tileIndex
    lda         tileTypeTable,y
    ldy         index
    sta         tileTypeArray,y
    lda         tileIndex
    sta         tileCacheArray,y
    inc         index
    inx
    cpx         #MAP_HORIZONTAL_TILES-2     ; -2 for ignore left-most/right-most
    bne         bgXLoop
    lda         index
    cmp         #(MAP_HORIZONTAL_TILES-2)*(MAP_VERTICAL_TILES-2)
    bne         bgYLoop

    ; process misc tiles
    ldy         #0
miscTileLoop:
    lda         (scriptPtr0),y              ; x cord
    beq         doneMiscTiles
    lsr                                     ; / TILE_WIDTH
    sta         index
    dec         index                       ; -1 to ignore left

    iny
    lda         (scriptPtr0),y              ; y cord
    sec
    sbc         #(MAP_TOP+1)
    bmi         skipTile                    ; skip top row
    tax
    lda         mult18Table,x               ; mult Y by 18
    clc
    adc         index
    sta         index

    iny
    lda         (scriptPtr0),y              ; tile #
    sta         tileIndex
    tax
    lda         tileTypeTable,x
    ldx         index
    sta         tileTypeArray,x
    lda         tileIndex
    sta         tileCacheArray,x

    iny
    jmp         miscTileLoop

skipTile:
    iny                                     ; tile #
    iny                                     ; next tile
    jmp         miscTileLoop

doneMiscTiles:
    rts

index:      .byte   0
tileIndex:  .byte   0

.endproc


;-----------------------------------------------------------------------------
; Show Pause
;-----------------------------------------------------------------------------
.proc showPause
    lda         PAGE2       ; remember screen we were on
    sta         page
    ; display pause screen
    sta         LOWSCR
    sta         LORES

wait:
    lda         KBD
    bpl         wait
    sta         KBDSTRB

    sta         HIRES
    lda         page
    bmi         :+
    rts                     ; still on low
:
    sta         HISCR       ; switch to high
    rts

page:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; Monitor
;
;  Exit to monitor
;-----------------------------------------------------------------------------
.proc monitor

    jsr         TEXT
    jsr         inline_print
    StringCR    "CTRL-Y TO EXIT"

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
    .word       quit_params

.endproc


;-----------------------------------------------------------------------------
; Load Data
;   Load data using ProDOS
;-----------------------------------------------------------------------------
.proc loadData

    ; Set parameters
    lda         fileParameters,x
    sta         open_params+1
    lda         fileParameters+1,x
    sta         open_params+2

    lda         fileParameters+2,x
    sta         rw_params+2
    lda         fileParameters+3,x
    sta         rw_params+3
    lda         fileParameters+4,x
    sta         rw_params+4
    lda         fileParameters+5,x
    sta         rw_params+5

    ; open file
    jsr         MLI
    .byte       CMD_OPEN
    .word       open_params
    bcc         :+
    jsr         printPath
    jsr         inline_print
    StringCR    "File not found"
    inc         fileError
    rts
:

    ; set reference number
    lda         open_params+5
    sta         rw_params+1
    sta         close_params+1

    ; read data
    jsr         MLI
    .byte       CMD_READ
    .word       rw_params
    bcc         :+

    jsr         printPath
    jsr         inline_print
    StringCR    "Read Error"
    inc         fileError
    rts
:

    jsr         MLI
    .byte       CMD_CLOSE
    .word       close_params
    bcc         :+

    jsr         inline_print
    StringCR    "File close error"
    inc         fileError
:
    rts

printPath:
    jsr         HOME
    jsr         TEXT
    jsr         inline_print
    String      "Pathname:"

    lda         open_params+1
    sta         stringPtr0
    lda         open_params+2
    sta         stringPtr1
    jsr         print_length

    lda         #KEY_RETURN
    jsr         COUT
    rts

.endproc

;-----------------------------------------------------------------------------
; Utilities
;-----------------------------------------------------------------------------
.include        "inline_print.asm"
.include        "tones.asm"
seed:           .word       $1234
.include        "galois16o.asm"


;-----------------------------------------------------------------------------
; Global ProDos parameters
;-----------------------------------------------------------------------------

FILE_TILE           = 0*8
FILE_SCENE          = 1*8

tileFileName:       StringLen "DATA/TILE.0"
sceneFileName:      StringLen "DATA/SCENE.0"
sceneFileNameEnd:

fileParameters:
    .word       tileFileName,   tileSheet,  16*128,     0   
    .word       sceneFileName,  cutScene,   40*128,     0

fileError:      .byte   0
assetNum:       .byte   0

open_params:
    .byte       $3              ; 3 parameters
    .word       tileFileName    ; pathname*
    .word       FILEBUFFER      ; ProDos buffer
    .byte       $0              ; reference number

create_params:
    .byte       $7              ; 7 parameters
    .word       tileFileName    ; pathname*
    .byte       $C3             ; access bits (full access)
    .byte       $6              ; file type (binary)
    .word       $2000           ; binary file load address
    .byte       $1              ; storage type (standard)
    .word       $0              ; creation date
    .word       $0              ; creation time

rw_params:
    .byte       $4
    .byte       $0              ; reference number*
    .word       $2000           ; address of data buffer*
    .word       $2000           ; number of bytes to read/write*
    .word       $0              ; number of bytes read/written

close_params:
    .byte       $1              ; 1 parameter
    .byte       $0              ; reference number*

quit_params:
    .byte       4               ; 4 parameters
    .byte       0               ; 0 is the only quit type
    .word       0               ; Reserved pointer for future use (what future?)
    .byte       0               ; Reserved byte for future use (what future?)
    .word       0               ; Reserved pointer for future use (what future?)

;-----------------------------------------------------------------------------
; Globals
;-----------------------------------------------------------------------------
count:          .word       0
playerX:        .byte       0
playerY:        .byte       0
playerTileY:    .byte       0
playerState:    .byte       STATE_IDLE
activeColumns:  .byte       0
initialOffset:  .byte       0
displayLevel:   .byte       0
currentLevel:   .byte       0

; player drawing
drawTileX0:     .byte       0
drawTileY0:     .byte       0
drawTileX1:     .byte       0
drawTileY1:     .byte       0
eraseTileX0_0:  .byte       0
eraseTileY0_0:  .byte       0
eraseTileX1_0:  .byte       0
eraseTileY1_0:  .byte       0
eraseTileX0_1:  .byte       0
eraseTileY0_1:  .byte       0
eraseTileX1_1:  .byte       0
eraseTileY1_1:  .byte       0

imageX:         .byte       0
imageY:         .byte       0
imageWidth:     .byte       0
imageHeight:    .byte       0

; 2tone Songs
songGameStart:
    .byte   NOTE_C4,    NOTE_C6,    NOTE_HALF
    .byte   NOTE_D4,    NOTE_D6,    NOTE_HALF
    .byte   NOTE_E4,    NOTE_E6,    NOTE_HALF
    .byte   NOTE_C4,    NOTE_C6,    NOTE_HALF
    .byte   NOTE_D4,    NOTE_D6,    NOTE_HALF
    .byte   NOTE_E4,    NOTE_E6,    NOTE_HALF
    .byte   NOTE_REST,  NOTE_REST,  NOTE_DONE

songLevelComplete:
    .byte   NOTE_C4,    NOTE_C5,    NOTE_HALF
    .byte   NOTE_C5,    NOTE_C6,    NOTE_HALF
    .byte   NOTE_C6,    NOTE_C7,    NOTE_HALF
    .byte   NOTE_REST,  NOTE_REST,  NOTE_DONE

songDead:
    .byte   NOTE_E5,    NOTE_REST,  NOTE_HALF
    .byte   NOTE_REST,  NOTE_REST,  NOTE_QUARTER
    .byte   NOTE_D5,    NOTE_REST,  NOTE_HALF
    .byte   NOTE_REST,  NOTE_REST,  NOTE_QUARTER
    .byte   NOTE_C5,    NOTE_C4,    NOTE_HALF
    .byte   NOTE_REST,  NOTE_REST,  NOTE_DONE

songOuch:
    .byte   NOTE_C4,    NOTE_C6,    NOTE_QUARTER
    .byte   NOTE_REST,  NOTE_REST,  NOTE_DONE

; Current level data (expecting order of bgTiles, bufferX, bufferSpeed0&1)
bgTiles:        .res        20
bufferX:        .res        8
bufferSpeed0:   .res        8
bufferSpeed1:   .res        8
bufferOffset0:  .res        8
bufferOffset1:  .res        8

; Valid index 0..13
mult18Table:    .byte   18*0, 18*1, 18*2, 18*3,  18*4,  18*5,  18*6
                .byte   18*7, 18*8, 18*9, 18*10, 18*11, 18*12, 18*13


.align 256
tileTypeArray:      .res        256         ; collision detection (18x14 array)
tileCacheArray:     .res        256         ; track tile index for BG
tileDynamicType:    .res        MAX_COLUMN_PAIRS*COLUMN_ROWS/8

levelData:
; Level 1
levelData1:
    .word   levelData2                                                          ; link to next level
    ; Background
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS_ROAD                    ; [4] grass->road
    .byte   TILE_BUFFER0,TILE_BUFFER1,TILE_BUFFER2,TILE_ROAD,TILE_BUFFER3       ; [5] road
    .byte   TILE_ROAD_GRASS,TILE_GRASS,TILE_GRASS_WATER                         ; [3] road->grass->water
    .byte   TILE_BUFFER4,TILE_BUFFER5,TILE_BUFFER6,TILE_WATER,TILE_BUFFER7      ; [5] water
    .byte   TILE_WATER_GRASS,TILE_GRASS,TILE_GRASS                              ; [3] water->grass
    ; Scrolling columns
    .byte     8, 10, 12, 16, 24, 26, 28, 32                                     ; column pair offset, locations ($FF for inactive)
    .byte   $80,$10,$A0,$50,$40,$30,$20,$90                                     ; column pair speed (lower)
    .byte   $01,$FF,$00,$01,$00,$FF,$00,$00                                     ; column pair speed (upper)
    .byte     8                                                                 ; active column pairs

    ; column pair 0
    .byte   TILE_CAR1_BLUE,TILE_ROAD,TILE_CAR1_PURPLE,TILE_ROAD,TILE_CAR1_BLUE,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

    ;.byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C
    ;.byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C

    ; column pair 1
    .byte   TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_TRUCKD_A,TILE_TRUCKD_B
    .byte   TILE_TRUCKD_C,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

    ; column pair 2
    .byte   TILE_CAR1_RED,TILE_ROAD,TILE_CAR1_RED,TILE_ROAD,TILE_CAR1_BLUE,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

    ; column pair 3
    .byte   TILE_TRUCKU_A,TILE_TRUCKU_B,TILE_TRUCKU_C,TILE_ROAD,TILE_TRUCKU_A,TILE_TRUCKU_B,TILE_TRUCKU_C,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

    ; column pair 4
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

    ; column pair 5
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

    ; column pair 6
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

    ; column pair 7
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

    .byte   0                                                                   ; end of column data

    ; Misc tiles [x,y,tile] (end with 0)
    .byte   14, 4,TILE_CONE,14, 5,TILE_CONE,14, 6,TILE_CONE
    .byte   14, 9,TILE_CONE,14,10,TILE_CONE
    .byte                   14,13,TILE_CONE,14,14,TILE_CONE
    .byte   14,17,TILE_CONE,14,18,TILE_CONE,14,19,TILE_CONE
    .byte   2,5,TILE_TREE_A,2,6,TILE_TREE_B
    .byte   4,4,TILE_TREE_A,4,5,TILE_TREE_MID,4,6,TILE_TREE_B
    .byte   6,18,TILE_BUSH_ROAD
    .byte   20,12,TILE_TREE_A,20,13,TILE_TREE_B
    .byte   34,4,TILE_TREE_A,34,5,TILE_TREE_MID,34,6,TILE_TREE_B
    .byte   36,4,TILE_TREE_A,36,5,TILE_TREE_MID,36,6,TILE_TREE_MID,36,7,TILE_TREE_B
    .byte   22,4,TILE_BUSH_WATER,22,5,TILE_BUSH_WATER,22,7,TILE_BUSH_WATER,22,10,TILE_BUSH_WATER
    .byte   22,14,TILE_BUSH_WATER,22,15,TILE_BUSH_WATER,22,18,TILE_BUSH_WATER,22,19,TILE_BUSH_WATER
    .byte   30,8,TILE_ROCK,30,10,TILE_ROCK,30,12,TILE_ROCK,30,13,TILE_ROCK
    .byte   0                                                                   ; end of tile list

levelData2:

.align 256

tileTypeTable:
    .res        $40,TILE_TYPE_BLOCKED       ;00..3F - ASCII characters, treat as "blocked"
    .byte       TILE_TYPE_DEATH             ;40     - Truck down A
    .byte       TILE_TYPE_DEATH             ;41     - Truck up A
    .byte       TILE_TYPE_MOVEMENT          ;42     - Log A
    .byte       TILE_TYPE_DEATH             ;43     - Car2 A
    .byte       TILE_TYPE_DEATH             ;44     - Car1 Blue
    .byte       TILE_TYPE_FREE              ;45     - road/grass
    .byte       TILE_TYPE_FREE              ;46     - grass
    .byte       TILE_TYPE_FREE              ;47     - grass/road
    .byte       TILE_TYPE_DEATH             ;48     - Truck down B
    .byte       TILE_TYPE_DEATH             ;49     - Truck up B
    .byte       TILE_TYPE_MOVEMENT          ;4A     - Log B
    .byte       TILE_TYPE_DEATH             ;4B     - Car2 B
    .byte       TILE_TYPE_BLOCKED           ;4C     - Tree A
    .byte       TILE_TYPE_FREE              ;4D     - grass/water
    .byte       TILE_TYPE_DEATH             ;4E     - water
    .byte       TILE_TYPE_FREE              ;4F     - water/grass
    .byte       TILE_TYPE_DEATH             ;50     - Truck down C
    .byte       TILE_TYPE_DEATH             ;51     - Truck up C
    .byte       TILE_TYPE_MOVEMENT          ;52     - Log C
    .byte       TILE_TYPE_DEATH             ;53     - Car1 Red
    .byte       TILE_TYPE_BLOCKED           ;54     - Tree B
    .byte       TILE_TYPE_DEATH             ;55     - Car1 Purple
    .byte       TILE_TYPE_BLOCKED           ;56     -
    .byte       TILE_TYPE_FREE              ;57     - Road
    .byte       TILE_TYPE_FREE              ;58     - Rock
    .byte       TILE_TYPE_BLOCKED           ;59     - Cone
    .byte       TILE_TYPE_BLOCKED           ;5A     - Bush (grass->water)
    .byte       TILE_TYPE_BLOCKED           ;5B     - Bush (grass->road)
    .byte       TILE_TYPE_BLOCKED           ;5C     - Tree A*
    .byte       TILE_TYPE_BLOCKED           ;5D     - Divider (road->road)
    .byte       TILE_TYPE_BLOCKED           ;5E     -
    .byte       TILE_TYPE_FREE              ;5F     - Coin
    .res        $20,TILE_TYPE_FREE          ;60..7f - Unused
    .byte       TILE_TYPE_BUFFER0           ;80     - Active column
    .byte       TILE_TYPE_BUFFER1           ;81     - Active column
    .byte       TILE_TYPE_BUFFER2           ;82     - Active column
    .byte       TILE_TYPE_BUFFER3           ;83     - Active column
    .byte       TILE_TYPE_BUFFER4           ;84     - Active column
    .byte       TILE_TYPE_BUFFER5           ;85     - Active column
    .byte       TILE_TYPE_BUFFER6           ;86     - Active column
    .byte       TILE_TYPE_BUFFER7           ;87     - Active column


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

.align 256

worldMap:       .res 16*20

;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------

.align 256
.include        "playerShapes.asm"

.align 256
tileSheet:
.include        "font.asm"

.align 256
cutScene:






