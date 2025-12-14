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

.macro  DrawImageParam imgX, imgY, imgWidth, imgHeight, imgPtr, aux
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
.ifblank aux
    jsr     drawImage
.else
    jsr     DRAW_IMAGE_AUX
.endif
.endmacro


.macro PlaySongPtr song
    lda     #<song
    sta     songPtr
    lda     #>song
    sta     songPtr+1
    jsr     electricDuetPlayer
.endmacro

;-----------------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------------

; reuse zero page addresses
songPtr                     := curY         ; and +1
bufferPtr0                  := mapPtr0      ; and +1
bufferPtr1                  := maskPtr0     ; and +1
codePtr                     := tilePtr0     ; and +1
levelPtr                    := scriptPtr0   ; and +1

; Memory Mapping
;---------------
DISPATCH_CODE               = $C00                          ; Dispatch code very small (<256 bytes)
                                                            ; Keep above prodos file buffer ($800..$BFF)
AUX_LEVEL_DATA              = $E00                          ; $E00  .. $2FFF
                                                            ; $3000 .. $3FFF images
COLUMN_CODE_START           = $4000                         ; page0 offset $0000..$3048, page1 $3049..$6091
COLUMN_CODE_START_PAGE2     = COLUMN_CODE_START + $3049     ; include some padding after code to align buffers
COLUMN_BUFFER_START         = COLUMN_CODE_START + $6100     ; size=$1000
                                                            ; Total size = $7100
; relocated addresses
COPY_LEVEL_CODE             = DISPATCH_CODE + (initCode::copyLevelData-initCode::dispatchStart)
DRAW_IMAGE_AUX              = DISPATCH_CODE + (initCode::drawImageAux-initCode::dispatchStart)
MENU_IMAGE_RIGHT            = AUX_LEVEL_DATA+menuImageRight-LEVEL_DATA_START
MENU_IMAGE_BOTTOM           = AUX_LEVEL_DATA+menuImageBottom-LEVEL_DATA_START

AUX_IMAGES_START            = AUX_LEVEL_DATA+(LEVEL_DATA_END-LEVEL_DATA_START)
AUX_IMAGES_END              = AUX_IMAGES_START+(auxImagesEnd-auxImagesStart)

QUOTE_IMAGE_LEFT            = AUX_IMAGES_START+(quoteImageLeft-auxImagesStart)
QUOTE_IMAGE_RIGHT           = AUX_IMAGES_START+(quoteImageRight-auxImagesStart)
PAUSE_IMAGE                 = AUX_IMAGES_START+(pauseImage-auxImagesStart)

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

QUOTE_X                     = MAP_LEFT+TILE_WIDTH
QUOTE_Y                     = MAP_TOP+TILE_HEIGHT


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

TILE_BLANK                  = $00
TILE_PROMPT                 = $20

TILE_GRASS                  = $46
TILE_GRASS_ROAD             = $47
TILE_ROAD                   = $57
TILE_ROAD_GRASS             = $45
TILE_GRASS_WATER            = $4D
TILE_WATER                  = $4E
TILE_WATER_GRASS            = $4F

TILE_GRASS_NW               = $65
TILE_GRASS_N                = $66
TILE_GRASS_NE               = $67
TILE_GRASS_SW               = $6D
TILE_GRASS_S                = $6E
TILE_GRASS_SE               = $6F

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

TILE_TRAIN_TRACKS           = $60
TILE_TRAIN_A                = $61
TILE_TRAIN_B                = $62
TILE_TRAIN_C                = $63
TILE_TRAIN_TRACKS_WARNING   = $77

TILE_LOG_A                  = $42
TILE_LOG_B                  = $4A
TILE_LOG_C                  = $52
TILE_TURTLE_A               = $74
TILE_TURTLE_B               = $7C
TILE_TURTLE_SINK_A          = $75
TILE_TURTLE_SINK_B          = $7D
TILE_TURTLE_SUNK_A          = $76
TILE_TURTLE_SUNK_B          = $7E

TILE_TREE_A                 = $4C
TILE_TREE_MID               = $5C       ; use in middle of stack of trees
TILE_TREE_B                 = $54
TILE_CROSSWALK              = $56
TILE_ROCK                   = $58
TILE_CONE                   = $59
TILE_BUSH_WATER             = $5A       ; left of water
TILE_BUSH_ROAD              = $5B       ; left of road
TILE_SINGLE_LINE            = $5D
TILE_ROAD_BUSH              = $73       ; right of road
TILE_CARPET_LEFT            = $5E
TILE_CARPET                 = $5F
TILE_BRICK                  = $64
TILE_COIN                   = $70
TILE_CONVEYOR               = $71
TILE_FLOWER                 = $72

TILE_BUFFER0                = $80
TILE_BUFFER1                = $81
TILE_BUFFER2                = $82
TILE_BUFFER3                = $83
TILE_BUFFER4                = $84
TILE_BUFFER5                = $85
TILE_BUFFER6                = $86
TILE_BUFFER7                = $87

TILE_TYPE_FREE              = %00000000
TILE_TYPE_MOVEMENT          = %00000001
TILE_TYPE_BLOCKED           = %00000010
TILE_TYPE_DEATH             = %00000100
TILE_TYPE_ANIMATE_A         = %00001000
TILE_TYPE_ANIMATE_B         = %00010000

TILE_TYPE_MOVEMENT_AA       = TILE_TYPE_MOVEMENT | TILE_TYPE_ANIMATE_A
TILE_TYPE_MOVEMENT_AB       = TILE_TYPE_MOVEMENT | TILE_TYPE_ANIMATE_B
TILE_TYPE_DEATH_AA          = TILE_TYPE_DEATH    | TILE_TYPE_ANIMATE_A
TILE_TYPE_DEATH_AB          = TILE_TYPE_DEATH    | TILE_TYPE_ANIMATE_B

TILE_TYPE_BUFFER0           = $80
TILE_TYPE_BUFFER1           = $90
TILE_TYPE_BUFFER2           = $A0
TILE_TYPE_BUFFER3           = $B0
TILE_TYPE_BUFFER4           = $C0
TILE_TYPE_BUFFER5           = $D0
TILE_TYPE_BUFFER6           = $E0
TILE_TYPE_BUFFER7           = $F0

PLAYER_OFFSET_IDLE          = $00
PLAYER_OFFSET_UP_1          = $10
PLAYER_OFFSET_DOWN_1        = $20
PLAYER_OFFSET_LEFT_1        = $30
PLAYER_OFFSET_LEFT_2        = $40
PLAYER_OFFSET_DEAD          = $50

PLAYER_OFFSET_IDLE_MASK     = $80
PLAYER_OFFSET_UP_2          = $90
PLAYER_OFFSET_DOWN_2        = $A0
PLAYER_OFFSET_RIGHT_1       = $B0
PLAYER_OFFSET_RIGHT_2       = $C0

NEW_WORD                    = $40
END_OF_STRING               = $FF

LEVEL_COLUMN_START          = $2F

NUMBER_CUTSCENES            = 32

MAX_LEVELS                  = 12
INITIAL_LEVEL               = 0 ; MAX_LEVELS-1

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
    lda         #$7f
    sta         $2000
    sta         $2001
    sta         $2002

    ; display screen
    sta         MIXCLR
    sta         LOWSCR
    sta         HIRES
    sta         TXTCLR

    jsr         initCode

    ; Install Level Data
    lda         #<LEVEL_DATA_START
    sta         bufferPtr0
    lda         #>LEVEL_DATA_START
    sta         bufferPtr0+1
    lda         #<AUX_LEVEL_DATA
    sta         bufferPtr1
    lda         #>AUX_LEVEL_DATA
    sta         bufferPtr1+1
    lda         #<LEVEL_DATA_END
    sta         codePtr
    lda         #>LEVEL_DATA_END
    sta         codePtr+1
    sta         RAMWRTON            ; Write to AUX
    jsr         copyMemory
    sta         RAMWRTOFF           ; Write to Main

    ; Install Images in AUX

    lda         #<auxImagesStart    ; main memory starting address
    sta         bufferPtr0
    lda         #>auxImagesStart
    sta         bufferPtr0+1
    lda         #<AUX_IMAGES_START  ; AUX memory starting address
    sta         bufferPtr1
    lda         #>AUX_IMAGES_START
    sta         bufferPtr1+1
    lda         #<auxImagesEnd      ; main memory ending address
    sta         codePtr
    lda         #>auxImagesEnd
    sta         codePtr+1
    sta         RAMWRTON            ; Write to AUX
    jsr         copyMemory
    sta         RAMWRTOFF           ; Write to Main

    ; All done
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
    sta         codePtr
    lda         #>COLUMN_CODE_START
    sta         codePtr+1

    lda         #0
    sta         pageCount
    sta         drawPage

page_loop:
    ; Init buffer pointer (shared between pages)
    lda         #$00            ; Assuming page aligned
    sta         bufferPtr0
    lda         #>COLUMN_BUFFER_START
    sta         bufferPtr0+1

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
    sta         (codePtr),y
    iny
    lda         #$FF            ; end of buffer
    sta         (codePtr),y
    iny
    lda         bufferPtr0+1
    sta         (codePtr),y
    iny

    lda         #INSTRUCTION_BPL
    sta         (codePtr),y
    iny
    lda         #$01            ; skip 1 byte (RTS)
    sta         (codePtr),y
    iny

    lda         #INSTRUCTION_RTS
    sta         (codePtr),y
    iny

    lda         #INSTRUCTION_LDY
    sta         (codePtr),y
    iny
    lda         #$FF            ; end of buffer
    sta         (codePtr),y
    iny
    lda         bufferPtr0+1
    clc
    adc         #1
    sta         (codePtr),y
    iny

    ; increment code pointer
    clc
    tya
    adc         codePtr
    sta         codePtr
    lda         codePtr+1
    adc         #0
    sta         codePtr+1

write_loop:
    ldy         #0

    ; ** LDA BUFFER+ROW,Y
    ; ** STA SCREEN_ADRS,X

    lda         #INSTRUCTION_LDA_Y
    sta         (codePtr),y
    iny
    lda         bufferPtr0
    sta         (codePtr),y
    iny
    lda         bufferPtr0+1
    sta         (codePtr),y
    iny

    lda         #INSTRUCTION_STA_X
    sta         (codePtr),y
    iny
    lda         columnCount         ; If column odd, +1
    and         #1
    clc
    adc         fullLineOffset,x
    sta         (codePtr),y
    iny
    lda         fullLinePage,x
    adc         drawPage
    sta         (codePtr),y
    iny

    ; increment code pointer
    clc
    tya
    adc         codePtr
    sta         codePtr
    lda         codePtr+1
    adc         #0
    sta         codePtr+1

    ; increment buffer pointer
    inc         bufferPtr0          ; will deal with upper byte later

    inx
    cpx         #COLUMN_STARTING_ROW+COLUMN_ROWS
    bne         write_loop

    ; move to next buffer
    lda         #0
    sta         bufferPtr0
    inc         bufferPtr0+1

    inc         columnCount
    lda         columnCount
    cmp         #MAX_COLUMNS
    beq         doneColumns
    jmp         column_loop

doneColumns:
    ; ** RTS
    ldy         #0
    lda         #INSTRUCTION_RTS
    sta         (codePtr),y
    iny

    clc
    tya
    adc         codePtr
    sta         codePtr
    lda         codePtr+1
    adc         #0
    sta         codePtr+1

    lda         #$20
    sta         drawPage

    inc         pageCount
    lda         pageCount
    cmp         #2
    beq         donePage
    jmp         page_loop

donePage:

    ; Install Dispatch
    jsr         copyDispatch        ; copy to aux
    sta         RAMWRTOFF           ; Write to Main
    jsr         copyDispatch        ; copy to main

    rts

copyDispatch:
    ; source pointer
    lda         #<dispatchStart
    sta         bufferPtr0
    lda         #>dispatchStart
    sta         bufferPtr0+1
    ; destination pointer
    lda         #<DISPATCH_CODE
    sta         bufferPtr1
    lda         #>DISPATCH_CODE
    sta         bufferPtr1+1
    ; end of source
    lda         #<dispatchEnd
    sta         codePtr
    lda         #>dispatchEnd
    sta         codePtr+1

    jsr         copyMemory
    rts

; align dispatch code and add padding to avoid moving addresses
.align 256
dispatchStart:

dispatch:
    ; This code is being used as data to be copied to lower memory
    ; location in both main and aux memory to call the aux code.
    ; It must be relocatable (or destination addresses calculated)

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

; Zero page usage
currentColumn   := tempZP
columnPtr       := mapPtr0


; Set up map pointer before calling
; This read the column index and then copy of the referenced data to fixed locations
;   - column types (20 bytes)
;   - column tiles (20*16 bytes)
;   - column expanded speeds (8*2 bytes)

copyLevelData:                          ; aka COPY_LEVEL_CODE
    lda         #0
    sta         currentColumn

    sta         RAMRDON                 ; read from aux (including instructions)

columnLoop:
    ldy         currentColumn
    lda         (levelPtr),y
    tax                                 ; X = column index
    lda         AUX_LEVEL_DATA+levelColumnInfo-LEVEL_DATA_START,x       ; lookup column type
    sta         worldColumnType,y       ; static or dynamic
    txa                                 ; calc column tiles address
    tay                                 ; put a copy of the index in Y
    asl
    asl
    asl
    asl                                 ; *16
    sta         columnPtr
    tya
    lsr
    lsr
    lsr
    lsr                                 ; /16
    clc
    adc         #>(AUX_LEVEL_DATA + (levelColumnData-LEVEL_DATA_START))
    sta         columnPtr+1
    ldx         currentColumn

    ; Copy and transpose the column data
    ; (Could also consider working with non-transposed data)
    ldy         #0
columnTileLoop:
.repeat 16,index
    lda         (columnPtr),y
    sta         worldMap+index*20,x
    iny
.endrep
    cpy         #16
    beq         :+
    jmp         DISPATCH_CODE + (columnTileLoop-dispatchStart)      ; relocated jump!
:

    inc         currentColumn
    lda         currentColumn
    cmp         #20
    beq         :+
    jmp         DISPATCH_CODE + (columnLoop-dispatchStart)          ; relocated jump!
:
    ; expand speeds
    ldx         #0                          ; x = speed index
    ldy         #20                         ; currentColumn == 20
speedLoop:
    lda         (levelPtr),y
    and         #$F0
    sta         worldSpeed0,x               ; write lower byte

    lda         (levelPtr),y
    and         #$08                        ; check if upper bit of nibble is set
    beq         positiveSign
    lda         (levelPtr),y
    and         #$0F
    ora         #$F0
    jmp         DISPATCH_CODE + (speedContinue-dispatchStart)       ; relocated jump!
positiveSign:
    lda         (levelPtr),y
    and         #$0F
speedContinue:
    sta         worldSpeed1,x               ; write upper byte
    lda         #0
    sta         worldOffset0,x              ; init offset
    sta         worldOffset1,x              ; init offset
    inx
    iny
    cpy         #20+8
    bne         speedLoop

    lda         (levelPtr),y                ; starting location
    sta         playerStartingTileY

    iny
    lda         (levelPtr),y
    sta         columnTimingEven

    iny
    lda         (levelPtr),y
    sta         columnTimingOdd

    iny
    lda         (levelPtr),y
    sta         columnStateOffset


    sta         RAMRDOFF                    ; back to main memory

    rts

    ; Draw an image located in AUX memory
drawImageAux:
    lda         imageY
    tax
    clc
    adc         imageHeight
    sta         tempZP

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
    sta         RAMRDON
    lda         (tilePtr0),y                ; only this instruction running in AUX memory
    sta         RAMRDOFF
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
    cpx         tempZP
    bne         yLoop
    rts

dispatchEnd:

.endproc

;-----------------------------------------------------------------------------
; copyMemory
;
;   bufferPtr0  source (assumed page aligned)
;   bufferPtr1  destination (assumed page aligned)
;   codePointer address for last byte to copy+1
;
;   bufferPtr* modified during copy
;
;-----------------------------------------------------------------------------
.proc copyMemory
copyMemory:
    ldy         #0
pageLoop:
    ; Assume start is page-aligned for both source and destination
    lda         codePtr+1
    cmp         bufferPtr0+1
    beq         cont
copyLoop:
    lda         (bufferPtr0),y
    sta         (bufferPtr1),y
    iny
    bne         copyLoop
    inc         bufferPtr0+1
    inc         bufferPtr1+1
    bne         pageLoop            ; Always branch since not copying zero page
    brk                             ; Should never reach here
cont:
    lda         codePtr
    bne         lastLoop
    rts                             ; already done
lastLoop:
    lda         (bufferPtr0),y
    sta         (bufferPtr1),y
    iny
    cpy         codePtr
    bne         lastLoop
    rts
.endProc

; start and end aligned
.align 256
; level column data
LEVEL_DATA_START:
.include        "levels.asm"

.align 256
menuImageRight:
.incbin         "..\build\menu_right.bin"
menuImageBottom:
.incbin         "..\build\menu_bottom.bin"

.align 256
LEVEL_DATA_END:


;-----------------------------------------------------------------------------
; Data to be used or copied to aux memory (will get overwritten)
;-----------------------------------------------------------------------------

; pretend there is more data to keep the linker happy
.res            $A00

;=============================================================================
.align $100
;=============================================================================

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    PlaySongPtr songGameStart
    jsr         waitForKey
restart_loop:
    jsr         randomizeCutScenes  ; randomize cutscenes after waiting for 'random' seed
    jsr         initGameState

reset_loop:
    jsr         loadLevel
    jsr         initLevelState

redraw_loop:
    jsr         drawScreen

game_loop:

    ; Timer
    inc         time
    bne         :+
    inc         time+1
:

    jsr         animateColumns
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
    jmp         redraw_loop
:

    cmp         #KEY_QUESTION
    bne         :+
    jsr         showCredits
    jmp         redraw_loop
:

    cmp         #KEY_CTRL_C
    bne         :+
    jsr         showSetKeysMenu
    jmp         redraw_loop
:

    cmp         #KEY_CTRL_L
    bne         :+
    jsr         showLoadTiles
    bne         redraw_loop
    jmp         restart_loop
:
    cmp         #KEY_ESC
    bne         :+
    jsr         showQuit
    bne         redraw_loop
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

    cmp         inputUp

    bne         :+
    jmp         goUp
:
    cmp         inputDown
    bne         :+
    jmp         goDown
:
    cmp         inputRight
    bne         :+
    jmp         goRight
:
    cmp         inputLeft
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

    inc         currentLevel
    lda         currentLevel
    cmp         #MAX_LEVELS
    bne         :+
    lda         #0
    sta         currentLevel
:

    ; Drawing on high screen
    jsr         drawCutScene

    DrawStringCord  0, 22, stringLevelComplete

    ; display Image
    bit         HISCR
    PlaySongPtr songLevelComplete

    ; Preload next cutscene
    jsr         loadCutScene
    jsr         waitForKey

    bit         LOWSCR
    rts
.endproc

.proc waitForKey
    ; kill extra keypress
    bit         KBDSTRB

    lda         #8          ; about 10 seconds
    sta         wait
    ldy         #0
    ldx         #0
loop:
    lda         KBD
    bmi         done

    inc         seed
    bne         :+
    inc         seed+1
    bne         :+
    inc         seed        ; can't be zero
:

    dex
    bne         loop
    dey
    bne         loop
    dec         wait
    bne         loop
    ; timeout (value == 0)
done:
    bit         KBDSTRB
    rts

wait:           .byte   0
.endproc


;-----------------------------------------------------------------------------
; Randomize Cut Scene
;-----------------------------------------------------------------------------
.proc randomizeCutScenes
    lda         #0
    sta         index

loop:
    jsr         galois16o
    and         #$1f            ; 32 cut-scenes
    asl
    asl                         ; * 4
    tax

    ; copy random entry to temp storage
    lda         cutSceneList+0,x
    sta         copyEntry+0
    lda         cutSceneList+1,x
    sta         copyEntry+1
    lda         cutSceneList+2,x
    sta         copyEntry+2
    lda         cutSceneList+3,x
    sta         copyEntry+3

    ; copy index to random entry
    ldy         index
    lda         cutSceneList+0,y
    sta         cutSceneList+0,x
    lda         cutSceneList+1,y
    sta         cutSceneList+1,x
    lda         cutSceneList+2,y
    sta         cutSceneList+2,x
    lda         cutSceneList+3,y
    sta         cutSceneList+3,x

    ; copy temp to index
    lda         copyEntry+0
    sta         cutSceneList+0,y
    lda         copyEntry+1
    sta         cutSceneList+1,y
    lda         copyEntry+2
    sta         cutSceneList+2,y
    lda         copyEntry+3
    sta         cutSceneList+3,y

    lda         index
    clc
    adc         #4
    sta         index
    cmp         #NUMBER_CUTSCENES*4
    bne         loop

    rts

index:          .byte   0
copyEntry:      .res    4

.endproc

;-----------------------------------------------------------------------------
; Load Cut Scene
;-----------------------------------------------------------------------------
.proc loadCutScene
    lda         cutSceneIndex
    clc
    adc         #4
    sta         cutSceneIndex
    cmp         #NUMBER_CUTSCENES*4
    bne         :+
    lda         #0
    sta         cutSceneIndex
:
    ldx         cutSceneIndex
    lda         cutSceneList,x
    beq         image
    rts
image:
    lda         cutSceneList+2,x
    sta         sceneFileNameEnd-1
    ldx         #FILE_SCENE
    jsr         loadData
    lda         fileError
    beq         :+
    jsr         monitor
:
    rts
.endproc

;-----------------------------------------------------------------------------
; Animate Columns
;-----------------------------------------------------------------------------
.proc animateColumns

    lda         columnTimingEven            ; timing=0, do nothing
    beq         checkOdd
even:
    lda         columnTriggerEven
    cmp         time
    bne         checkOdd

    ; set next trigger
    lda         time
    clc
    adc         columnTimingEven
    sta         columnTriggerEven
    inc         columnStateEven
    lda         columnStateEven
    ldx         #0                          ; starting column
    ldy         #0*16
    jsr         animate

checkOdd:
    lda         columnTimingOdd             ; timing=0, do nothing
    beq         done
    lda         columnTriggerOdd
    cmp         time
    bne         done

    ; set next trigger
    lda         time
    clc
    adc         columnTimingOdd
    sta         columnTriggerOdd
    inc         columnStateOdd
    lda         columnStateOdd
    ldx         #1*2                        ; starting column
    ldy         #1*16
    jsr         animate
done:
    rts

animate:
    ; A = state, x = column, y = column*16
    ; if checking all columns is too slow, could mark columns to check
    sta         state
    sty         index
    stx         tileX                   ; tileX = buffer pair

    and         #$7
    ora         columnStateOffset

    tay
    lda         actionTable,y
    bne         :+
    rts
:
    cmp         #ACTION_MORPH
    bne         checkReplace
    lda         newTypeTableA,y
    sta         typeA
    lda         newTileTableA,y
    sta         tileA
    lda         newTypeTableB,y
    sta         typeB
    lda         newTileTableB,y
    sta         tileB

morphColumnLoop:
    lda         #0
    sta         tileY

morphRowLoop:
    ldy         index
    lda         tileDynamicType,y
    and         #TILE_TYPE_ANIMATE_A
    beq         :+
    lda         typeA
    sta         tileDynamicType,y
    lda         tileA
    jsr         copyTileToBuffers
    jmp         cont
:
    lda         tileDynamicType,y
    and         #TILE_TYPE_ANIMATE_B
    beq         :+
    lda         typeB
    sta         tileDynamicType,y
    lda         tileB
    jsr         copyTileToBuffers
:
cont:
    lda         tileY
    clc
    adc         #8
    sta         tileY
    inc         index
    lda         index
    and         #$f
    bne         morphRowLoop

    lda         tileX
    clc
    adc         #4
    sta         tileX
    lda         index
    clc
    adc         #$10        ; skip a column
    sta         index

    cmp         #$80
    bcc         morphColumnLoop
    rts

checkReplace:
    sta         action
    ; really should make this programmable, but just forcing in the train

replaceColumnLoop:
    lda         #0
    sta         tileY

replaceRowLoop:
    ldy         index
    lda         tileDynamicType,y
    and         #TILE_TYPE_ANIMATE_A
    beq         :+

    sta         SPEAKER                 ; train noise

    lda         index
    and         #$3                     ; 0..3
    ora         action                  ; 4, 8 or 12
    tax
    lda         replaceTypeTable,x
    sta         tileDynamicType,y
    lda         replaceTileTable,x
    jsr         copyTileToBuffers

:
    lda         tileY
    clc
    adc         #8
    sta         tileY
    inc         index
    lda         index
    and         #$f
    bne         replaceRowLoop

    lda         tileX
    clc
    adc         #4
    sta         tileX
    lda         index
    clc
    adc         #$10        ; skip a column
    sta         index

    cmp         #$80
    bcc         replaceColumnLoop

    rts

index:      .byte   0
typeA:      .byte   0
tileA:      .byte   0
typeB:      .byte   0
tileB:      .byte   0
state:      .byte   0
action:     .byte   0
base:       .byte   0

ACTION_MORPH                = 1
ACTION_REPLACE_WARNING      = 4
ACTION_REPLACE_TRAIN        = 8
ACTION_REPLACE_TRACKS       = 12

actionTable:
    .byte   0, 0, 0, 0, ACTION_MORPH,          ACTION_MORPH,          ACTION_MORPH,          ACTION_MORPH       ; 0: turtles
    .byte   0, 0, ACTION_REPLACE_WARNING, 0, ACTION_REPLACE_TRAIN, 0, 0, ACTION_REPLACE_TRACKS                  ; 8: train

; Morph substitutions
newTypeTableA:
    .byte   0, 0, 0, 0, TILE_TYPE_MOVEMENT_AA, TILE_TYPE_DEATH_AA, TILE_TYPE_MOVEMENT_AA, TILE_TYPE_MOVEMENT_AA
newTileTableA:
    .byte   0, 0, 0, 0, TILE_TURTLE_SINK_A,    TILE_TURTLE_SUNK_A, TILE_TURTLE_SINK_A,    TILE_TURTLE_A

newTypeTableB:
    .byte   0, 0, 0, 0, TILE_TYPE_MOVEMENT_AB, TILE_TYPE_DEATH_AB, TILE_TYPE_MOVEMENT_AB, TILE_TYPE_MOVEMENT_AB
newTileTableB:
    .byte   0, 0, 0, 0, TILE_TURTLE_SINK_B,    TILE_TURTLE_SUNK_B, TILE_TURTLE_SINK_B,    TILE_TURTLE_B

replaceTypeTable:
    .byte   0,                  0,                  0,                  0                       ; unused
    .byte   TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A     ; warning
    .byte   TILE_TYPE_DEATH_AA, TILE_TYPE_DEATH_AA, TILE_TYPE_DEATH_AA, TILE_TYPE_DEATH_AA      ; train
    .byte   TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A,TILE_TYPE_ANIMATE_A     ; tracks

replaceTileTable:
    .byte   0,0,0,0                                                                                                 ; unused
    .byte   TILE_TRAIN_TRACKS_WARNING,TILE_TRAIN_TRACKS_WARNING,TILE_TRAIN_TRACKS_WARNING,TILE_TRAIN_TRACKS_WARNING ; warning
    .byte   TILE_TRAIN_A,             TILE_TRAIN_B,             TILE_TRAIN_B,             TILE_TRAIN_C              ; train
    .byte   TILE_TRAIN_TRACKS        ,TILE_TRAIN_TRACKS        ,TILE_TRAIN_TRACKS        ,TILE_TRAIN_TRACKS         ; tracks

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
    lsr                         ; divide by 2 for tile offset
    tay
    lda         worldColumnType,y
    bpl         :+
    and         #$07
    tax
    lda         worldOffset1,x
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
    cmp         #(MAP_TOP+TILE_HEIGHT)*8
    bcs         :+
    lda         #STATE_DEAD
    jmp         updateState
:

    ; Below the bottom?
    cmp         #(MAP_BOTTOM-1*TILE_HEIGHT)*8-7
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
    lda         worldOffset1,x
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

; Valid index 0..13
mult18Table:    .byte   18*0, 18*1, 18*2, 18*3,  18*4,  18*5,  18*6
                .byte   18*7, 18*8, 18*9, 18*10, 18*11, 18*12, 18*13

.endproc

;-----------------------------------------------------------------------------
; Erase Tile
;-----------------------------------------------------------------------------
; Read tile cache and erase
.proc eraseTile

    lda         tileY
    cmp         #MAP_TOP
    beq         skip
    cmp         #MAP_BOTTOM-TILE_HEIGHT
    beq         skip

    jsr         tile2array
    tax
    lda         tileCacheArray,x
    jmp         drawTile            ; chain returns
skip:
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
    lda         worldOffset0,x
    adc         worldSpeed0,x
    sta         worldOffset0,x
    lda         worldOffset1,x
    adc         worldSpeed1,x
    sta         worldOffset1,x
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
    lda         worldOffset1,x
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

    lda         #<worldMap
    sta         mapPtr0
    lda         #>worldMap
    sta         mapPtr1
    lda         #MAP_TOP
    sta         tileY

mapLoop:
    lda         #0
    sta         index
    lda         #MAP_LEFT
    sta         tileX

rowLoop:
    ldy         index
    lda         (mapPtr0),y
    jsr         drawTile
    inc         index
    lda         tileX
    clc
    adc         #TILE_WIDTH
    sta         tileX
    cmp         #MAP_RIGHT
    bne         rowLoop

    lda         mapPtr0
    clc
    adc         #20
    sta         mapPtr0
    lda         mapPtr1
    adc         #0
    sta         mapPtr1

    inc         tileY
    lda         tileY
    cmp         #MAP_BOTTOM
    bne         mapLoop

    rts

index:          .byte   0

.endproc

;-----------------------------------------------------------------------------
; Draw text - add info to the screen
;-----------------------------------------------------------------------------
stringBoxTop:       TileText "#==================\"
stringLevel:        TileText "_    LEVEL:        _"
stringPause:        TileText "_   GAME  PAUSED   _"
stringBoxBlank:     TileText "_                  _"
stringBoxBottom:    TileText "[==================]"
stringBoxQuote:     TileText "[=========*========]"
stringBlank:        TileText "                    "
stringThought:      QuoteText " o",1,0
                    TileText "&"
; stringArrow:        TileText ">"
stringFroggo:       TileText "_ @    FROGGO    @ _"
stringGameOver:     TileText "_ @  GAME  OVER  @ _"
stringPressKey:     TileText "_   PRESS ANY KEY  _"
stringLevelComplete:TileText "_  LEVEL COMPLETE! _"
;stringHint:         TileText "_MOVE KEYS: A,Z,<,>_"

LEVEL_X = 12*TILE_WIDTH
LEVEL_Y = 1*TILE_HEIGHT

.proc drawText
    DrawStringCord  0, 0,  stringBoxTop
    DrawStringCord  0, 1,  stringLevel
    DrawStringCord  0, 2,  stringBoxBottom
;    DrawStringCord  38,3,  stringArrow
;    DrawStringCord  38,20, stringArrow
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
; Draw Cut Scene - image or quote (right/left styles)
;-----------------------------------------------------------------------------

.proc drawCutScene
    ldx         cutSceneIndex
    lda         cutSceneList,x
    bne         notImage
    ; Display image
    DrawImageParam  MAP_LEFT,MAP_TOP*8,(MAP_RIGHT-MAP_LEFT),(MAP_BOTTOM-MAP_TOP)*8,cutScene
    rts

notImage:
    lda         #$7f
    sta         invertTile

    DrawStringCord  0, MAP_TOP+0,  stringBoxTop
    DrawStringCord  0, MAP_TOP+1,  stringBoxBlank
    DrawStringCord  0, MAP_TOP+2,  stringBoxBlank
    DrawStringCord  0, MAP_TOP+3,  stringBoxBlank
    DrawStringCord  0, MAP_TOP+4,  stringBoxBlank
    DrawStringCord  0, MAP_TOP+5,  stringBoxBlank
    DrawStringCord  0, MAP_TOP+6,  stringBoxBlank
    ;
    DrawStringCord  0, MAP_TOP+8,   stringBlank
    DrawStringCord  0, MAP_TOP+9,   stringBlank
    DrawStringCord  0, MAP_TOP+10,  stringBlank
    DrawStringCord  0, MAP_TOP+11,  stringBlank
    DrawStringCord  0, MAP_TOP+12,  stringBlank
    DrawStringCord  0, MAP_TOP+13,  stringBlank
    DrawStringCord  0, MAP_TOP+14,  stringBlank
    DrawStringCord  0, MAP_TOP+15,  stringBlank

    ldx         cutSceneIndex
    lda         cutSceneList,x
    cmp         #CUT_SCENE_QUOTE_LEFT
    beq         doLeft
    cmp         #CUT_SCENE_QUOTE_RIGHT
    beq         :+
    brk                                     ; unknown cut scene type
:
    DrawImageParam  20,96,20,64,QUOTE_IMAGE_RIGHT,aux
    DrawStringCord  0, MAP_TOP+7,   stringBoxQuote

cont:
    ldx         cutSceneIndex
    lda         #QUOTE_X
    sta         tileX
    lda         #QUOTE_Y
    sta         tileY
    lda         cutSceneList+2,x
    sta         stringPtr0
    lda         cutSceneList+3,x
    sta         stringPtr1
    jsr         drawString
    lda         #$00
    sta         invertTile
    rts

doLeft:
    DrawImageParam  0,96,20,64,QUOTE_IMAGE_LEFT,aux
    DrawStringCord  0, MAP_TOP+7,   stringBoxBottom
    DrawStringCord  18, MAP_TOP+8,  stringThought
    jmp         cont

.endproc



;-----------------------------------------------------------------------------
; Draw Menu
;
;   Pass in menu type
;-----------------------------------------------------------------------------
menuBoxTop:     TileText "#============\"
menuBoxSides:   TileText "_            _"
menuBoxBottom:  TileText "[============]"

.proc drawMenu

    DrawStringCord  0, 1,  stringPause

    DrawImageParam  MAP_RIGHT-12,MAP_TOP*8,12,(MAP_BOTTOM-MAP_TOP)*8,MENU_IMAGE_RIGHT,aux
    DrawImageParam  MAP_LEFT,(MAP_BOTTOM*8)-48,MAP_RIGHT-12,48,MENU_IMAGE_BOTTOM,aux

    DrawStringCord  0, MAP_TOP+0,  menuBoxTop
    DrawStringCord  0, MAP_TOP+1,  menuBoxSides
    DrawStringCord  0, MAP_TOP+2,  menuBoxSides
    DrawStringCord  0, MAP_TOP+3,  menuBoxSides
    DrawStringCord  0, MAP_TOP+4,  menuBoxSides
    DrawStringCord  0, MAP_TOP+5,  menuBoxSides
    DrawStringCord  0, MAP_TOP+6,  menuBoxSides
    DrawStringCord  0, MAP_TOP+7,  menuBoxSides
    DrawStringCord  0, MAP_TOP+8,  menuBoxSides
    DrawStringCord  0, MAP_TOP+9,  menuBoxBottom

    rts
.endproc


;-----------------------------------------------------------------------------
; Show Quit
;-----------------------------------------------------------------------------

; 01234567890123
; /------------\ 0
; |            | 1
; | QUIT  GAME | 2
; |            | 3
; |  ARE YOU   | 4
; |   SURE?    | 5
; |            | 6
; |   Y/N:     | 7
; |            | 8
; \--------v---/ 9

stringQuit:     QuoteText "",           1*2,1
                QuoteText "quit Game",  3*2,2
                QuoteText "areYou",     4*2,1
                QuoteText "sure?",      2*2,2
                QuoteText "yOrN:",      15,15

.proc showQuit

    jsr         drawMenu
    DrawStringCord  2, MAP_TOP+1,  stringQuit

    ; display menu
    bit         HISCR

    lda         #MAP_LEFT+10*TILE_WIDTH
    sta         tileX
    lda         #MAP_TOP+7
    sta         tileY
    lda         #TILE_BLANK
    jsr         waitForInput

    ; restore display
    bit         LOWSCR

    cmp         #KEY_Y
    rts
.endproc

;-----------------------------------------------------------------------------
; Show Load Tiles
;-----------------------------------------------------------------------------

; 01234567890123
; /------------\ 0
; |            | 1
; |LOAD TILES: | 2
; | GAME WILL  | 3
; | RESTART    | 4
; | AFTER LOAD | 5
; | CONTINUE?  | 6
; | Y/N:       | 7
; |            | 8
; \--------v---/ 9

stringLoadTiles:    QuoteText "loadTiles:", 1*2,2
                    QuoteText "gameWill",   1*2,1
                    QuoteText "restart",    1*2,1
                    QuoteText "afterLoad",  1*2,1
                    QuoteText "continue?",  1*2,2
                    QuoteText "yOrN:",      15,15

.proc showLoadTiles

    jsr         drawMenu
    DrawStringCord  2, MAP_TOP+1,  stringLoadTiles

    ; display menu
    bit         HISCR

    lda         #MAP_LEFT+10*TILE_WIDTH
    sta         tileX
    lda         #MAP_TOP+8
    sta         tileY
    lda         #TILE_BLANK
    jsr         waitForInput

    ; restore display
    bit         LOWSCR

    cmp         #KEY_Y
    beq         :+
    rts
:
    ldx         #FILE_TILE
    jsr         loadData
    lda         fileError
    beq         :+
    jsr         monitor
:
    rts
.endproc

;-----------------------------------------------------------------------------
; Show Pause
;-----------------------------------------------------------------------------


.proc showPause

    jsr         drawMenu
    DrawImageParam  MAP_LEFT+TILE_WIDTH,(MAP_TOP+1)*8,18,64,PAUSE_IMAGE,aux

    ; display menu
    bit         HISCR

    lda         #MAP_LEFT+12*TILE_WIDTH
    sta         tileX
    lda         #MAP_TOP+8
    sta         tileY
    lda         #TILE_BLANK
    jsr         waitForInput

    ; restore display
    bit         LOWSCR
    rts

.endproc

;-----------------------------------------------------------------------------
; Show Credits
;-----------------------------------------------------------------------------


.proc showCredits

    jsr         playCredits

    ; restore display
    bit         LOWSCR
    rts

.endproc

;-----------------------------------------------------------------------------
; Show Set Keys Menu
;-----------------------------------------------------------------------------

; 01234567890123
; /------------\ 0
; |SET KEYS -  | 1
; | UP    : @  | 2
; | DOWN  :    | 3
; | LEFT  :    | 4
; | RIGHT :    | 5
; |            | 6
; |^K  - RESET | 7
; |ESC - CANCEL| 8
; \--------v---/ 9

stringMenuKeys:     QuoteText "setKeys",        3*2,1
                    QuoteText "up    :",        3*2,1
                    QuoteText "down  :",        3*2,1
                    QuoteText "left  :",        3*2,1
                    QuoteText "right :",        0,2
                    QuoteText "^c  -Reset",     0,1
                    QuoteText "esc -Cancel",    15,15

.proc showSetKeysMenu

    jsr         drawMenu

    DrawStringCord  2, MAP_TOP+1,  stringMenuKeys

reset:
    ; tile X common
    lda         #MAP_LEFT+11*TILE_WIDTH
    sta         tileX

    ; draw current bindings
    lda         #MAP_TOP+2
    sta         tileY
    lda         inputUp
    jsr         drawKey
    inc         tileY
    lda         inputDown
    jsr         drawKey
    inc         tileY
    lda         inputLeft
    jsr         drawKey
    inc         tileY
    lda         inputRight
    jsr         drawKey

    ; display menu
    bit         HISCR

    ; get input for up
    lda         #MAP_TOP+2
    sta         tileY
    lda         inputUp
    jsr         getNewKey
    cmp         #KEY_CTRL_C
    beq         reset
    cmp         #KEY_ESC
    beq         cancel
    sta         newUp
    jsr         drawKey

    ; get input for down
    inc         tileY
    lda         inputDown
    jsr         getNewKey
    cmp         #KEY_CTRL_C
    beq         reset
    cmp         #KEY_ESC
    beq         cancel
    sta         newDown
    jsr         drawKey

    ; get input for left
    inc         tileY
    lda         inputLeft
    jsr         getNewKey
    cmp         #KEY_CTRL_C
    beq         reset
    cmp         #KEY_ESC
    beq         cancel
    sta         newLeft
    jsr         drawKey

    ; get input for right
    inc         tileY
    lda         inputLeft
    jsr         getNewKey
    cmp         #KEY_CTRL_C
    beq         reset
    cmp         #KEY_ESC
    beq         cancel
    sta         newRight
    jsr         drawKey

finsh:
    lda         newUp
    sta         inputUp
    lda         newDown
    sta         inputDown
    lda         newLeft
    sta         inputLeft
    lda         newRight
    sta         inputRight

cancel:
    ; restore display
    bit         LOWSCR
    rts

getNewKey:
    jsr         keyToTile
    jsr         waitForInput
    rts

drawKey:
    jsr         keyToTile
    jmp         drawTile        ; link returns

keyToTile:
    cmp         #KEY_UP
    bne         :+
    lda         #$3E
    rts
:
    cmp         #KEY_DOWN
    bne         :+
    lda         #$1B
    rts
:
    cmp         #KEY_LEFT
    bne         :+
    lda         #$1C
    rts
:
    cmp         #KEY_RIGHT
    bne         :+
    lda         #$1E
    rts
:
    sec
    sbc         #$A0

    cmp         #$40
    bcc         :+
    sec
    sbc         #$20
:
    rts

newUp:      .byte       0
newDown:    .byte       0
newLeft:    .byte       0
newRight:   .byte       0

.endproc

;-----------------------------------------------------------------------------
; Wait For Input
;-----------------------------------------------------------------------------

.proc waitForInput

    sta         previous

blinkLoop:
    lda         #TILE_PROMPT
    jsr         drawTile
    jsr         wait
    lda         previous
    jsr         drawTile
    jsr         wait
    lda         KBD
    bpl         blinkLoop
    bit         KBDSTRB
    rts

wait:
    ldy         #0
    ldx         #0
loop:
    lda         KBD
    bmi         done
    dex
    bne         loop
    dey
    bne         loop
done:
    rts

previous:       .byte   0

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
    eor         invertTile
    sta         (screenPtr0),y
    iny
    lda         (tilePtr0),y
    eor         invertTile
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
    ora         PLAYER_SHAPES,x
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    ora         PLAYER_SHAPES+1,x
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
    and         PLAYER_SHAPES,x
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         PLAYER_SHAPES+1,x
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
; 00cc_cccc - draw tile C and increment tileX
; 01cc_cccc - increment tileX, draw tile C and increment tileX (new word)
; 1yyy_xxx0 - reset to initial tileX and increment tileY by yyy and tileX by xxx0 (even)
; 1111_1111 - end of string

.proc drawString
    ldy         #0
    lda         tileX
    sta         initialX

    ; Print characters until end character
drawLoop:
    lda         (stringPtr0),y
    bpl         noBit7
    cmp         #END_OF_STRING
    bne         :+
    rts                     ; done
:
    sty         index
    and         #%00001110
    clc
    adc         initialX
    sta         tileX
    lda         (stringPtr0),y
    lsr
    lsr
    lsr
    lsr
    and         #%00000111
    clc
    adc         tileY
    sta         tileY
    jmp         next

noBit7:
    and         #NEW_WORD
    beq         :+
    inc         tileX
    inc         tileX
:
    sty         index
    lda         (stringPtr0),y
    and         #%00111111
    jsr         drawTile

    inc         tileX
    inc         tileX
next:
    ldy         index
    iny
    jmp         drawLoop

index:          .byte   0
initialX:       .byte   0

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

    ldx         #7              ; first 7 rows
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

    ; unroll last row for special case of not writing last 2 bytes

    ldy         #0
    lda         (tilePtr0),y
    sta         (bufferPtr0),y
    inc         tilePtr0
    ldy         #0
    lda         (tilePtr0),y
    sta         (bufferPtr1),y

    lda         tileY
    cmp         #$80-8
    bcs         :+                  ; skip if were to overwrite last 2 bytes of buffer

    dec         tilePtr0
    ldy         #0
    lda         (tilePtr0),y
    ldy         #$80
    sta         (bufferPtr0),y
    inc         tilePtr0
    ldy         #0
    lda         (tilePtr0),y
    ldy         #$80
    sta         (bufferPtr1),y
:
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
    lda         #INITIAL_LEVEL
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
    lda         playerStartingTileY
    sta         eraseTileY0_0
    sta         eraseTileY1_0
    sta         eraseTileY0_1
    sta         eraseTileY1_1
    sta         playerTileY
    asl
    asl
    asl                                     ; *8
    sta         playerY
    lda         #PLAYER_INIT_STATE
    jsr         updateState
    lda         #0
    sta         count
    sta         count+1
    sta         time
    sta         time+1

    lda         columnTimingEven
    sta         columnTriggerEven
    lda         columnTimingOdd
    sta         columnTriggerOdd
    lda         #0
    sta         columnStateEven
    sta         columnStateOdd
    rts
.endproc

;-----------------------------------------------------------------------------
; initDisplay - Initialize display
;-----------------------------------------------------------------------------

.proc initDisplay

    lda         #0
    sta         invertTile

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
    jsr         initDisplay

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
    lda         worldBufferX,x
    sta         (bufferPtr0),y
    inc         bufferPtr0+1
    inc         bufferPtr0+1
    inx
    cpx         #MAX_COLUMN_PAIRS
    bne         writeXLoop
    sta         RAMWRTOFF       ; write to MAIN
    rts

.endproc

;-----------------------------------------------------------------------------
; Load Level from AUX memory
;-----------------------------------------------------------------------------
.proc loadLevel

    ; Reset buffer X data
    ;-------------------------------------------
    ldx         #0
    lda         #$FF            ; default to unused
resetBufferXLoop:
    sta         worldBufferX,x
    inx
    cpx         #MAX_COLUMN_PAIRS
    bne         resetBufferXLoop

    ; copy level data from AUX memory
    ;-------------------------------------------
    lda         currentLevel
    asl
    asl
    asl
    asl
    asl         ; *32
    clc
    adc         #<AUX_LEVEL_DATA
    sta         levelPtr
    lda         currentLevel
    lsr
    lsr
    lsr         ; /8
    clc
    adc         #>AUX_LEVEL_DATA
    sta         levelPtr+1
    jsr         COPY_LEVEL_CODE

    ; look for dynamic columns
    ;-------------------------------------------
    lda         #0
    sta         activeColumns
    sta         dynamicIndex
    sta         worldColumn
    sta         tileX

dynamicLoop:
    lda         #0
    sta         tileY

    ; tileX = dynamic column number (inc by 2), tileY = row w/in column (inc by 8)
    ldx         worldColumn
    lda         worldColumnType,x
    and         #COLUMN_TYPE_DYNAMIC
    bne         :+
    jmp         nextDynamic
:
    ldy         activeColumns
    txa
    asl                             ; *2
    sta         worldBufferX,y
    tya                             ; buffer#
    ora         worldColumnType,x   ; fill in buffer #
    sta         worldColumnType,x
    sta         dynamicTileIndex

.repeat 16,index
    lda         worldMap+20*index,x
    jsr         dynamicUpdate
    sta         worldMap+20*index,x     ; overwrite with dynamic column #
.endrep
    ; point to next dynamic column
    inc         activeColumns
    inc         tileX
    inc         tileX               ; tileX = activeColumns*2 since buffers in pairs

    ; some error checking ... (can be removed when done testing all the levels)
    lda         activeColumns
    cmp         #9
    bne         :+
    brk                             ; too many active columns
:

nextDynamic:
    inc         worldColumn
    lda         worldColumn
    cmp         #20
    beq         :+
    jmp         dynamicLoop
:

    ; init buffers
    ;-------------------------------------------
    jsr         setActiveBuffers

    ; convert world map to static collision map
    ;-------------------------------------------
    ldx         #0
staticLoop:
.repeat 14,index
    ldy         worldMap+1+20*(index+1),x
    lda         tileTypeTable,y
    sta         tileTypeArray+18*index,x
.endrep
    inx
    cpx         #18
    beq         :+
    jmp         staticLoop
:

    ; copy worldMap to erase cache
    ;-------------------------------------------
    lda         #<worldMap
    clc
    adc         #20+1               ; start 1 row and 1 col over
    sta         mapPtr0
    lda         #>worldMap
    adc         #0
    sta         mapPtr1
    ldx         #0                  ; x = indexing into tile cache
cacheLoop:
    ldy         #0                  ; y = world map row offset
cacheRowLoop:
    lda         (mapPtr0),y
    sta         tileCacheArray,x
    iny
    inx
    cpy         #18                 ; only 18 tiles per row
    bne         cacheRowLoop

    lda         mapPtr0
    clc
    adc         #20
    sta         mapPtr0
    lda         mapPtr1
    adc         #0
    sta         mapPtr1
    cpx         #18*14
    bne         cacheLoop

    rts

    ; copy tiles to buffer
    ;-------------------------------------------
dynamicUpdate:
    sta         tileIndex
    jsr         copyTileToBuffers
    ldy         tileIndex
    lda         tileTypeTable,y
    ldy         dynamicIndex
    sta         tileDynamicType,y
    inc         dynamicIndex
    lda         tileY
    clc
    adc         #8
    sta         tileY
    ldx         worldColumn
    lda         dynamicTileIndex

    rts


tileIndex:          .byte       $0
dynamicIndex:       .byte       $0
worldColumn:        .byte       $0
dynamicTileIndex:   .byte       $0

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


.proc fullPageScroll2to1
;   >$2000, >$2400, >$2800, >$2C00, >$3000, >$3400, >$3800, >$3C00  ; *
;   >$2080, >$2480, >$2880, >$2C80, >$3080, >$3480, >$3880, >$3C80  ; *
;   >$2100, >$2500, >$2900, >$2D00, >$3100, >$3500, >$3900, >$3D00
;   >$2180, >$2580, >$2980, >$2D80, >$3180, >$3580, >$3980, >$3D80
;   >$2200, >$2600, >$2A00, >$2E00, >$3200, >$3600, >$3A00, >$3E00
;   >$2280, >$2680, >$2A80, >$2E80, >$3280, >$3680, >$3A80, >$3E80
;   >$2300, >$2700, >$2B00, >$2F00, >$3300, >$3700, >$3B00, >$3F00
;   >$2380, >$2780, >$2B80, >$2F80, >$3380, >$3780, >$3B80, >$3F80
;   >$2028, >$2428, >$2828, >$2C28, >$3028, >$3428, >$3828, >$3C28  ; *
;   >$20A8, >$24A8, >$28A8, >$2CA8, >$30A8, >$34A8, >$38A8, >$3CA8  ; *
;   >$2128, >$2528, >$2928, >$2D28, >$3128, >$3528, >$3928, >$3D28
;   >$21A8, >$25A8, >$29A8, >$2DA8, >$31A8, >$35A8, >$39A8, >$3DA8
;   >$2228, >$2628, >$2A28, >$2E28, >$3228, >$3628, >$3A28, >$3E28
;   >$22A8, >$26A8, >$2AA8, >$2EA8, >$32A8, >$36A8, >$3AA8, >$3EA8
;   >$2328, >$2728, >$2B28, >$2F28, >$3328, >$3728, >$3B28, >$3F28
;   >$23A8, >$27A8, >$2BA8, >$2FA8, >$33A8, >$37A8, >$3BA8, >$3FA8
;   >$2050, >$2450, >$2850, >$2C50, >$3050, >$3450, >$3850, >$3C50  ; *
;   >$20D0, >$24D0, >$28D0, >$2CD0, >$30D0, >$34D0, >$38D0, >$3CD0  ; *
;   >$2150, >$2550, >$2950, >$2D50, >$3150, >$3550, >$3950, >$3D50
;   >$21D0, >$25D0, >$29D0, >$2DD0, >$31D0, >$35D0, >$39D0, >$3DD0
;   >$2250, >$2650, >$2A50, >$2E50, >$3250, >$3650, >$3A50, >$3E50
;   >$22D0, >$26D0, >$2AD0, >$2ED0, >$32D0, >$36D0, >$3AD0, >$3ED0
;   >$2350, >$2750, >$2B50, >$2F50, >$3350, >$3750, >$3B50, >$3F50
;   >$23D0, >$27D0, >$2BD0, >$2FD0, >$33D0, >$37D0, >$3BD0, >$3FD0


    lda         $4400,x
    sta         $2000,x
    lda         $4800,x
    sta         $2400,x
    lda         $4C00,x
    sta         $2800,x
    lda         $5000,x
    sta         $2C00,x
    lda         $5400,x
    sta         $3000,x
    lda         $5800,x
    sta         $3400,x
    lda         $5C00,x
    sta         $3800,x
    lda         $4080,x
    sta         $3C00,x


.endproc


;-----------------------------------------------------------------------------
; Utilities
;-----------------------------------------------------------------------------
.include        "inline_print.asm"
seed:           .word       $1234
.include        "galois16o.asm"
.include        "electricDuet.asm"
.include        "credits.asm"

;-----------------------------------------------------------------------------
; Global ProDos parameters
;-----------------------------------------------------------------------------

FILE_TILE           = 0*8
FILE_SCENE          = 1*8

tileFileName:       StringLen "/FROGGO/DATA/TILE.0"
sceneFileName:      StringLen "/FROGGO/DATA/SCENE.0"
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
time:               .word       0           ; Global time
count:              .word       0           ; Player state counter
playerX:            .byte       0
playerY:            .byte       0
playerTileY:        .byte       0
playerStartingTileY:.byte       0
playerState:        .byte       STATE_IDLE
activeColumns:      .byte       0
initialOffset:      .byte       0
displayLevel:       .byte       0
currentLevel:       .byte       0
columnTimingEven:   .byte       0
columnTimingOdd:    .byte       0
columnTriggerEven:  .byte       0
columnTriggerOdd:   .byte       0
columnStateEven:    .byte       0
columnStateOdd:     .byte       0
columnStateOffset:  .byte       0

; settings
inputUp:            .byte       KEY_A
inputDown:          .byte       KEY_Z
inputLeft:          .byte       KEY_LEFT
inputRight:         .byte       KEY_RIGHT

; player drawing
drawTileX0:         .byte       0
drawTileY0:         .byte       0
drawTileX1:         .byte       0
drawTileY1:         .byte       0
eraseTileX0_0:      .byte       0
eraseTileY0_0:      .byte       0
eraseTileX1_0:      .byte       0
eraseTileY1_0:      .byte       0
eraseTileX0_1:      .byte       0
eraseTileY0_1:      .byte       0
eraseTileX1_1:      .byte       0
eraseTileY1_1:      .byte       0

imageX:             .byte       0
imageY:             .byte       0
imageWidth:         .byte       0
imageHeight:        .byte       0

cutSceneIndex:      .byte       (NUMBER_CUTSCENES-1)*4     ; start on last, so wrap around to first


; Current level data
worldMap:           .res    16*20       ; Tile map - Read from AUX memory
worldColumnType:    .res    20          ; Column types - Read from AUX memory
worldBufferX:       .res    8           ; Dynamic column location - Calc for AUX memory column types
worldSpeed0:        .res    8           ; Change in offset - Read from AUX memory
worldSpeed1:        .res    8           ; Change in offset - Read from AUX memory
worldOffset0:       .res    8           ; Display offset - Init when setting speed
worldOffset1:       .res    8           ; Display offset - Init when setting speed

; 2tone Songs
songGameStart:
    .byte   NOTE_16TH,  NOTE_C2,    NOTE_C4
    .byte   NOTE_16TH,  NOTE_D2,    NOTE_D4
    .byte   NOTE_16TH,  NOTE_E2,    NOTE_E4
    .byte   NOTE_16TH,  NOTE_C2,    NOTE_C4
    .byte   NOTE_16TH,  NOTE_D2,    NOTE_D4
    .byte   NOTE_16TH,  NOTE_E2,    NOTE_E4
    .byte   NOTE_DONE,  NOTE_REST,  NOTE_REST

songLevelComplete:
    .byte   NOTE_16TH,  NOTE_C2,    NOTE_C3
    .byte   NOTE_16TH,  NOTE_C3,    NOTE_C4
    .byte   NOTE_16TH,  NOTE_C4,    NOTE_C5
    .byte   NOTE_DONE,  NOTE_REST,  NOTE_REST

songDead:
    .byte   NOTE_16TH,      NOTE_E3,    NOTE_REST
    .byte   NOTE_32ND,      NOTE_REST,  NOTE_REST
    .byte   NOTE_16TH,      NOTE_D3,    NOTE_REST
    .byte   NOTE_32ND,      NOTE_REST,  NOTE_REST
    .byte   NOTE_16TH,      NOTE_C3,    NOTE_C2
    .byte   NOTE_DONE,      NOTE_REST,  NOTE_REST

songOuch:
    .byte   NOTE_32ND,      NOTE_C2,    NOTE_B2
    .byte   NOTE_DONE,      NOTE_REST,  NOTE_REST

.align 256

tileTypeArray:      .res        256         ; collision detection (18x14 array)
tileCacheArray:     .res        256         ; track tile index for BG
tileDynamicType:    .res        MAX_COLUMN_PAIRS*COLUMN_ROWS/8  ; collision detection (dynamic columns)

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
    .byte       TILE_TYPE_FREE              ;56     - Crosswalk
    .byte       TILE_TYPE_FREE              ;57     - Road
    .byte       TILE_TYPE_FREE              ;58     - Rock
    .byte       TILE_TYPE_BLOCKED           ;59     - Cone
    .byte       TILE_TYPE_BLOCKED           ;5A     - Bush (grass->water)
    .byte       TILE_TYPE_BLOCKED           ;5B     - Bush (grass->road)
    .byte       TILE_TYPE_BLOCKED           ;5C     - Tree A*
    .byte       TILE_TYPE_FREE              ;5D     - Divider (road->road)
    .byte       TILE_TYPE_FREE              ;5E     - Carpet (left)
    .byte       TILE_TYPE_FREE              ;5F     - Carpet
    .byte       TILE_TYPE_ANIMATE_A         ;60     - Train Tracks
    .byte       TILE_TYPE_DEATH_AA          ;61     - Train A
    .byte       TILE_TYPE_DEATH_AA          ;62     - Train B
    .byte       TILE_TYPE_DEATH_AA          ;63     - Train C
    .byte       TILE_TYPE_BLOCKED           ;64     - Brick
    .byte       TILE_TYPE_FREE              ;65     - Unused
    .byte       TILE_TYPE_FREE              ;66     - Unused
    .byte       TILE_TYPE_FREE              ;67     - Unused
    .byte       TILE_TYPE_FREE              ;68     - Unused
    .byte       TILE_TYPE_FREE              ;69     - Unused
    .byte       TILE_TYPE_FREE              ;6A     - Unused
    .byte       TILE_TYPE_FREE              ;6B     - Unused
    .byte       TILE_TYPE_FREE              ;6C     - Unused
    .byte       TILE_TYPE_FREE              ;6D     - Unused
    .byte       TILE_TYPE_FREE              ;6E     - Unused
    .byte       TILE_TYPE_FREE              ;6F     - Unused
    .byte       TILE_TYPE_FREE              ;70     - Coin
    .byte       TILE_TYPE_MOVEMENT          ;71     - Conveyor
    .byte       TILE_TYPE_FREE              ;72     - Flower
    .byte       TILE_TYPE_BLOCKED           ;73     - Bush
    .byte       TILE_TYPE_MOVEMENT_AA       ;74     - Turtle
    .byte       TILE_TYPE_MOVEMENT_AA       ;75     - Turtle (sinking)
    .byte       TILE_TYPE_DEATH_AA          ;76     - Turtle (sunk)
    .byte       TILE_TYPE_ANIMATE_A         ;60     - Train Tracks (warning)
    .byte       TILE_TYPE_FREE              ;78     - Unused
    .byte       TILE_TYPE_FREE              ;79     - Unused
    .byte       TILE_TYPE_FREE              ;7A     - Unused
    .byte       TILE_TYPE_FREE              ;7B     - Unused
    .byte       TILE_TYPE_MOVEMENT_AB       ;7C     - Turtle
    .byte       TILE_TYPE_MOVEMENT_AB       ;7D     - Turtle (sinking)
    .byte       TILE_TYPE_DEATH_AB          ;76     - Turtle (sunk)
    .byte       TILE_TYPE_FREE              ;7F     - Unused
    .byte       TILE_TYPE_BUFFER0           ;80     - Active column
    .byte       TILE_TYPE_BUFFER1           ;81     - Active column
    .byte       TILE_TYPE_BUFFER2           ;82     - Active column
    .byte       TILE_TYPE_BUFFER3           ;83     - Active column
    .byte       TILE_TYPE_BUFFER4           ;84     - Active column
    .byte       TILE_TYPE_BUFFER5           ;85     - Active column
    .byte       TILE_TYPE_BUFFER6           ;86     - Active column
    .byte       TILE_TYPE_BUFFER7           ;87     - Active column
    .res        8,TILE_TYPE_BLOCKED         ;88..8F - Reserved for future columns
    .byte       TILE_TYPE_BUFFER0           ;90     - Active column + Animate
    .byte       TILE_TYPE_BUFFER1           ;91     - Active column + Animate
    .byte       TILE_TYPE_BUFFER2           ;92     - Active column + Animate
    .byte       TILE_TYPE_BUFFER3           ;93     - Active column + Animate
    .byte       TILE_TYPE_BUFFER4           ;94     - Active column + Animate
    .byte       TILE_TYPE_BUFFER5           ;95     - Active column + Animate
    .byte       TILE_TYPE_BUFFER6           ;96     - Active column + Animate
    .byte       TILE_TYPE_BUFFER7           ;97     - Active column + Animate


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

CUT_SCENE_IMAGE = 0
CUT_SCENE_QUOTE_RIGHT = 1
CUT_SCENE_QUOTE_LEFT = 2

cutSceneList:
    .byte           CUT_SCENE_IMAGE,0,"0",0
    .byte           CUT_SCENE_IMAGE,0,"1",0
    .byte           CUT_SCENE_IMAGE,0,"2",0
    .byte           CUT_SCENE_IMAGE,0,"3",0
    .byte           CUT_SCENE_IMAGE,0,"4",0
    .byte           CUT_SCENE_IMAGE,0,"5",0
    .byte           CUT_SCENE_IMAGE,0,"6",0
    .byte           CUT_SCENE_IMAGE,0,"7",0
    .byte           CUT_SCENE_IMAGE,0,"8",0
    .byte           CUT_SCENE_IMAGE,0,"9",0
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR0
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR1
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR2
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR3
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR4
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR5
    .word           CUT_SCENE_QUOTE_RIGHT,stringQuoteR6
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL0
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL1
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL2
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL3
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL4
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL5
    .word           CUT_SCENE_QUOTE_LEFT,stringQuoteL6
    ; repeat until a power of 2
    .byte           CUT_SCENE_IMAGE,0,"2",0
    .byte           CUT_SCENE_IMAGE,0,"3",0
    .byte           CUT_SCENE_IMAGE,0,"4",0
    .byte           CUT_SCENE_IMAGE,0,"5",0
    .byte           CUT_SCENE_IMAGE,0,"6",0
    .byte           CUT_SCENE_IMAGE,0,"7",0
    .byte           CUT_SCENE_IMAGE,0,"8",0
    .byte           CUT_SCENE_IMAGE,0,"9",0

;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------

.include        "quotes.asm"

; Last 16 tiles are player shapes
PLAYER_SHAPES = tileSheet + (16 * $80)

.align 256
tileSheet:
.include        "font.asm"

; put images moving into AUX memory here, to be overwritten by cutscenes later

.align 256
cutScene:
auxImagesStart:

.align 256
quoteImageLeft:
.incbin         "..\build\thinking.bin"

.align 256
quoteImageRight:
.incbin         "..\build\aha.bin"

.align 256
pauseImage:
.incbin         "..\build\qrcode_hgr.bin"

auxImagesEnd:








