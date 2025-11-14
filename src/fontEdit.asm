;-----------------------------------------------------------------------------
; Paul Wasson - 2024
;-----------------------------------------------------------------------------
; Font Editor
;-----------------------------------------------------------------------------
; Edit 14x8 font tile set (or 7x8 using 2-bit pixels)
;-----------------------------------------------------------------------------

.include        "defines.asm"
.include        "macros.asm"

.segment        "CODE"
.org            $6000

;-----------------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------------

TILE_COUNT = 128

MAP_WIDTH = 20
MAP_HEIGHT = 24

;-----------------------------------------------------------------------------
; Main program
;-----------------------------------------------------------------------------

.proc main

    ; init

    jsr         HOME            ; clear screen
    lda         #23             ; put cursor on last line
    sta         CV
    jsr         VTAB

    lda         #0
    sta         curX
    lda         #0
    sta         curY
    sta         currentColor

    jsr         inline_print
    StringCR    "Font Editor (? for help)"

reset_loop:
    sta         LOWSCR
    sta         TXTCLR
    sta         HIRES
    sta         MIXSET
    lda         #0
    sta         drawPage        ; page1

    lda         #0              ; black
    jsr         clearScreen

canvas_loop:
    jsr         drawCanvas

preview_loop:
    jsr         drawPreview

command_loop:
    jsr         inline_print
    String      "Command:"

skip_prompt:
    jsr         getInput            ; wait for keypress

    ; Parse command

    ;------------------
    ; Tab = Toggle Text
    ;------------------
    cmp         #KEY_TAB
    bne         :+
    ; dont display anything
    lda         TEXTMODE
    bmi         toggle_text_off
    bit         TXTSET
    jmp         skip_prompt
toggle_text_off:
    bit         TXTCLR
    jmp         skip_prompt
:

    ;------------------
    ; Esc = Toggle Page
    ;------------------
    cmp         #KEY_ESC
    bne         :+
    ; dont display anything
    lda         PAGE2
    bmi         toggle_page
    bit         HISCR
    bit         MIXCLR
    jmp         skip_prompt
toggle_page:
    bit         LOWSCR
    bit         MIXSET
    jmp         skip_prompt
:

    ;------------------
    ; RIGHT (arrow)
    ;------------------
    cmp         #KEY_RIGHT
    bne         :+
    jsr         inline_print
    .byte       "Right ",0
    inc         curX
    lda         shapeWidth
    cmp         curX
    bne         right_good
    lda         #0
    sta         curX
right_good:
    jmp         finish_move
:

    ;------------------
    ; LEFT (arrow)
    ;------------------
    cmp         #KEY_LEFT
    bne         :+
    jsr         inline_print
    .byte       "Left  ",0
    dec         curX
    lda         curX
    bpl         left_good
    lda         shapeWidth
    sta         curX
    dec         curX
left_good:
    jmp         finish_move
:

    ;------------------
    ; UP (arrow)
    ;------------------
    cmp         #KEY_UP
    bne         :+
    jsr         inline_print
    .byte       "Up    ",0
    dec         curY
    lda         curY
    bpl         up_good
    lda         shapeHeight
    sta         curY
    dec         curY
up_good:
    jmp         finish_move
:
    ;------------------
    ; DOWN (arrow)
    ;------------------
    cmp         #KEY_DOWN
    bne         :+
    jsr         inline_print
    .byte       "Down  ",0
    inc         curY
    lda         shapeHeight
    cmp         curY
    bne         down_good
    lda         #0
    sta         curY
down_good:
    jmp         finish_move
:

    ;------------------
    ; Return - status
    ;------------------
    cmp         #KEY_RETURN
    bne         :+
    jsr         inline_print
    .byte       "Location  ",0
    jmp         finish_move
:

    ;------------------
    ; = = Next
    ;------------------
    cmp         #$80 | '='
    bne         :+
    inc         shapeIndex
    lda         shapeIndex
    and         #TILE_COUNT-1       ; assume power of 2
    sta         shapeIndex
    jsr         inline_print
    String      "Next shape: "
    jmp         finish_shape
:

    ;------------------
    ; + = Next+
    ;------------------
    cmp         #$80 | '+'
    bne         :+
    lda         shapeIndex
    clc
    adc         #8
    and         #TILE_COUNT-1       ; assume power of 2
    sta         shapeIndex
    jsr         inline_print
    String      "Next shape: "
    jmp         finish_shape
:

    ;------------------
    ; - = Previous
    ;------------------
    cmp         #$80 | '-'
    bne         :+
    dec         shapeIndex
    lda         shapeIndex
    and         #TILE_COUNT-1       ; assume power of 2
    sta         shapeIndex
    jsr         inline_print
    String      "Previous shape: "
    jmp         finish_shape
:

    ;------------------
    ; _ = Previous+
    ;------------------
    cmp         #$80 | '_'
    bne         :+
    lda         shapeIndex
    sec
    sbc         #8
    and         #TILE_COUNT-1       ; assume power of 2
    sta         shapeIndex
    jsr         inline_print
    String      "Previous shape: "
    jmp         finish_shape
:

    ;------------------
    ; 0 = Black
    ;------------------
    cmp         #$80 | '0'
    bne         :+
    lda         #0
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Black(0)"
    jmp         command_loop
:

    ;------------------
    ; 1 = Purple
    ;------------------
    cmp         #$80 | '1'
    bne         :+
    lda         #1
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Purple"
    jmp         command_loop
:

    ;------------------
    ; 2 = Green
    ;------------------
    cmp         #$80 | '2'
    bne         :+
    lda         #2
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Green"
    jmp         command_loop
:

    ;------------------
    ; 3 = White
    ;------------------
    cmp         #$80 | '3'
    bne         :+
    lda         #3
    sta         currentColor
    jsr         inline_print
    StringCR    "Set White(0)"
    jmp         command_loop
:

    ;------------------
    ; 4 = Black
    ;------------------
    cmp         #$80 | '4'
    bne         :+
    lda         #4
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Black(1)"
    jmp         command_loop
:

    ;------------------
    ; 5 = Blue
    ;------------------
    cmp         #$80 | '5'
    bne         :+
    lda         #5
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Blue"
    jmp         command_loop
:

    ;------------------
    ; 6 = Orange
    ;------------------
    cmp         #$80 | '6'
    bne         :+
    lda         #6
    sta         currentColor
    jsr         inline_print
    StringCR    "Set Orange"
    jmp         command_loop
:

    ;------------------
    ; 7 = White
    ;------------------
    cmp         #$80 | '7'
    bne         :+
    lda         #7
    sta         currentColor
    jsr         inline_print
    StringCR    "Set White(1)"
    jmp         command_loop
:

    ;------------------
    ; SP = Draw Pixel
    ;------------------
    cmp         #KEY_SPACE
    bne         :+
    jsr         inline_print
    StringCR    "Draw Pixel"
    jsr         setTileXY
    lda         currentColor
    jsr         setColor
    jsr         drawPixel
    jsr         setPixel
    jmp         preview_loop
:

    ;------------------
    ; Ctrl-F = Fill
    ;------------------
    cmp         #KEY_CTRL_F
    bne         :+
    jsr         inline_print
    StringCR    "Fill Color"
    jsr         fillColor
    jmp         canvas_loop
:

    ;------------------
    ; Ctrl-C = Copy
    ;------------------
    cmp         #KEY_CTRL_C
    bne         :+
    jsr         inline_print
    StringCR    "Copy to buffer"
    jsr         copyToBuffer
    jmp         command_loop
:

    ;------------------
    ; Ctrl-V = Paste
    ;------------------
    cmp         #KEY_CTRL_V
    bne         :+
    jsr         inline_print
    StringCR    "Paste from buffer"
    jsr         pasteFromBuffer
    jmp         canvas_loop
:

    ;-------------------------
    ; Ctrl-X = Inverse Colors
    ;-------------------------
    cmp         #KEY_CTRL_X
    bne         :+
    jsr         inline_print
    StringCR    "Inverse Colors"
    jsr         inverseColors
    jmp         canvas_loop
:

    ;------------------
    ; Ctrl-Q = QUIT
    ;------------------
    cmp         #KEY_CTRL_Q
    bne         :+
    jsr         inline_print
    .byte       "Quit",13,0
    bit         TXTSET
    jmp         quit
:

    ;------------------
    ; \ = Monitor
    ;------------------
    cmp         #$80 | '\'
    bne         :+
    jsr         inline_print
    .byte       "Monitor",13,"(enter CTRL-Y to return)",13,0
    jmp         monitor
:

    ;------------------
    ; ! = Dump
    ;------------------
    cmp         #$80 + '!'
    bne         :+
    jsr         inline_print
    .byte       "Dump shape",13,0
    jsr         dumpShape
    jmp         command_loop
:

    ;------------------
    ; @ = Dump all
    ;------------------
    cmp         #$80 + '@'
    bne         :+
    jsr         inline_print
    .byte       "Dump all",13,0
    jsr         dumpAll
    jmp         command_loop
:

    ;------------------
    ; ? = HELP
    ;------------------
    cmp         #$80 + '?'
    bne         :+
    jsr         inline_print
    .byte       "Help (TAB when done)",13,0
    jsr         printHelp
    jmp         command_loop
:

    ;------------------
    ; Unknown
    ;------------------
    jsr         inline_print
    .byte       "Unknown command (? for help)",13,0
    jmp         command_loop

; jump to after changing index
finish_shape:
    lda         shapeIndex
    jsr         PRBYTE
    lda         #$80+13
    jsr         COUT
    jmp         canvas_loop

; jump to after changing coordinates to display
finish_move:
    jsr         inline_print
    .byte       "X/Y:",0
    lda         curX
    jsr         PRBYTE
    lda         #$80 + ','
    jsr         COUT
    lda         curY
    jsr         PRBYTE
    jsr         inline_print
    .byte       "  Color:",0
    jsr         getPixel
    jsr         PRBYTE
    lda         #$80+13
    jsr         COUT
    jmp         command_loop

.endproc

;-----------------------------------------------------------------------------
; printHelp
;-----------------------------------------------------------------------------
.proc printHelp
    bit         TXTSET
    jsr         inline_print
    StringCont  "  -,=:        Previous/Next tile"
    StringCont  "  _,+:        Previous-8/Next-8 tile"
    StringCont  "  Arrows:     Move cursor"
    StringCont  "  01234567:   Change color"
    StringCont  "  Ctrl+C:     Copy"
    StringCont  "  Ctrl+V:     Paste"
    StringCont  "  <SP>:       Draw pixel"
    StringCont  "  Ctrl+F:     Fill with current color"
    StringCont  "  Ctrl+X:     Invert colors"
    StringCont  "  !:          Dump tile"
    StringCont  "  @:          Dump all tiles"
    StringCont  "              (Capture with printer)"
    StringCont  "  ?:          This help screen"
    StringCont  "  \:          Monitor"
    StringCont  "  Ctrl+Q:     Quit"
    StringCont  "  Tab:        Toggle text/graphics"
    .byte   0

    rts
.endproc

;-----------------------------------------------------------------------------
; getInputNumber
;   Get input for a number 0..max+1, where A == max+1
;   Display number or cancel and return result in A (-1 for cancel)
;-----------------------------------------------------------------------------
.proc getInputNumber
    clc
    adc         #$80 + '0'  ; convert A to ascii number
    sta         max_digit
    jsr         getInput
    cmp         #$80 + '0'
    bmi         cancel
    cmp         max_digit
    bpl         cancel
    jsr         COUT
    sec
    sbc         #$80 + '0'
    rts
cancel:
    jsr         inline_print
    .byte       "Cancel",13,0
    lda         #$ff
    rts

; local variable
max_digit:  .byte   0

.endproc

;-----------------------------------------------------------------------------
; drawCanvas
;   Draw pixel canvas
;-----------------------------------------------------------------------------

.proc drawCanvas

    ; save current cursor position
    lda         curX
    sta         tempX
    lda         curY
    sta         tempY

    ; set coordinates for frame
    lda         #0
    sta         frameX0
    sta         frameY0
    clc
    lda         shapeWidth
    adc         #4
    sta         frameX1
    lda         shapeHeight
    adc         #4
    sta         frameY1

    ; set color to white
    lda         #3
    jsr         setColor
    jsr         drawFrame

    ; draw canvas pixels
    lda         #0
    sta         curY
loopY:
    lda         #0
    sta         curX
loopX:
    jsr         setTileXY
    jsr         getPixel
    jsr         setColor
    jsr         drawPixel

    inc         curX
    lda         curX
    cmp         shapeWidth
    bne         loopX

    inc         curY
    lda         curY
    cmp         shapeHeight
    bne         loopY

    ; restore cursor position
    lda         tempX
    sta         curX
    lda         tempY
    sta         curY

    rts

.endproc

;-----------------------------------------------------------------------------
; drawPreview
;-----------------------------------------------------------------------------

.proc drawPreview

    ; current shape

    lda     #4
    sta     tileX
    lda     #0
    sta     tileY

    lda     shapeIndex
    jsr     drawTile

    lda     #0
    sta     previewIndex

loopY:
    lda     #8
    sta     tileX

loopX:
    lda     previewIndex
    jsr     drawTile

    lda     previewIndex
    cmp     shapeIndex
    bne     :+
    jsr     invertTile
:

    inc     tileX
    inc     previewIndex
    lda     previewIndex
    and     #$07
    bne     loopX

    inc     tileY
    lda     previewIndex
    and     #TILE_COUNT-1
    bne     loopY

    rts

previewIndex:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; setTileXY
;   Convert cursor to tile
;-----------------------------------------------------------------------------

.proc setTileXY
    clc
    lda         curX
    adc         canvasOffsetX
    sta         tileX
    lda         curY
    adc         canvasOffsetY
    sta         tileY
    rts
.endproc

;-----------------------------------------------------------------------------
; getInput
;   Blink cursors and wait for keypress
;   Return key in A (upper bit set)
;-----------------------------------------------------------------------------
.proc getInput

cursor_loop:
    ; Display cursor
    lda         #$FF
    jsr         COUT

    jsr         setTileXY
    jsr         drawCursor

    ; Wait (on)
    jsr         wait

    ; Restore
    lda         #$88        ; backspace
    jsr         COUT
    lda         #$A0        ; space
    jsr         COUT
    lda         #$88        ; backspace
    jsr         COUT

    jsr         drawCursor

    ; check for keypress
    lda         KBD
    bmi         exit

    ; Wait (off)
    jsr         wait

    ; check for keypress
    lda         KBD
    bpl         cursor_loop

exit:
    bit         KBDSTRB     ; clean up

    rts

; Wait loop that can be interrupted by key-press
wait:
    ldx         #$80
wait_x:
    ldy         #0
wait_y:
    lda         KBD
    bmi         waitExit
    dey
    bne         wait_y
    dex
    bne         wait_x
waitExit:
    rts

.endproc


;-----------------------------------------------------------------------------
; Init4x2
;
;   Set up pointers for 4x2 pixel
;-----------------------------------------------------------------------------

.proc init4x2
    ; set screen ptr
    lda         tileY
    asl                             ; *2
    tax
    ldy         tileX
    clc
    lda         div4x7,y            ; x4 divide by 7
    adc         fullLineOffset,x    ; add line offset
    sta         screenPtr0
    lda         fullLinePage,x
    adc         drawPage
    sta         screenPtr1

    lda         div4x7offset,y  ; offset within byte
    tax
    lda         mask4Table0,x
    sta         mask0
    lda         mask4Table1,x
    sta         mask1

    rts

.endproc

;-----------------------------------------------------------------------------
; Draw Cursor
;
;   XOR a block at tileX (0..69), tileY(0..47)
;-----------------------------------------------------------------------------

.proc drawCursor

    jsr         init4x2
    ldx         #2

lineLoop:
    ldy         #0

    ; Draw line
    lda         (screenPtr0),y
    eor         mask0
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    eor         mask1
    sta         (screenPtr0),y

    lda         screenPtr1
    clc
    adc         #4
    sta         screenPtr1

    dex
    bne         lineLoop
    rts

.endproc

;-----------------------------------------------------------------------------
; Draw Pixel
;
;   Draw a 4x2 block at tileX, tileY using colorEven/Odd
;-----------------------------------------------------------------------------

.proc drawPixel

    jsr         init4x2

    ; set color bytes
    lda         colorEven
    sta         color0
    lda         colorOdd
    sta         color1
    lda         screenPtr0      ; Did we start on a odd byte?
    and         #1
    beq         :+
    lda         colorEven
    sta         color1
    lda         colorOdd
    sta         color0
:

    ; remember  palette
    lda         colorEven
    and         #$80
    sta         colorPalette

    ; mask colors
    lda         color0
    and         mask0
    sta         color0
    lda         color1
    and         mask1
    sta         color1

    ; invert mask
    lda         mask0
    eor         #$7f
    sta         mask0
    lda         mask1
    eor         #$7f
    sta         mask1

    ldy         #0

    lda         (screenPtr0),y
    and         mask0
    ora         color0
    ora         colorPalette
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         mask1
    ora         color1
    ora         colorPalette
    sta         (screenPtr0),y

    lda         screenPtr1
    clc
    adc         #4
    sta         screenPtr1

    ldy         #0

    lda         (screenPtr0),y
    and         mask0
    ora         color0
    ora         colorPalette
    sta         (screenPtr0),y
    iny
    lda         (screenPtr0),y
    and         mask1
    ora         color1
    ora         colorPalette
    sta         (screenPtr0),y

    rts

colorPalette:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; Draw Frame
;
;   frameX0, frameY0, frameX1, frameY1
;-----------------------------------------------------------------------------
.proc drawFrame

    lda         frameY0
    sta         tileY

    lda         frameX0
    sta         tileX

loopTop:
    jsr         drawPixel
    inc         tileX
    lda         tileX
    cmp         frameX1
    bne         loopTop

    dec         tileX
    inc         tileY

loopRight:
    jsr         drawPixel
    inc         tileY
    lda         tileY
    cmp         frameY1
    bne         loopRight

    dec         tileY
    dec         tileX

loopBottom:
    jsr         drawPixel
    dec         tileX
    lda         tileX
    cmp         frameX0
    bne         loopBottom

loopLeft:
    jsr         drawPixel
    dec         tileY
    lda         tileY
    cmp         frameY0
    bne         loopLeft

    rts

.endproc


;-----------------------------------------------------------------------------
; fillColor
;
;   Set pixel from sprite shapeIndex at curX,curY to color
;
;-----------------------------------------------------------------------------

.proc fillColor
    lda         currentColor
    jsr         setColor

    ; save cursor location
    lda         curX
    sta         tempX
    lda         curY
    sta         tempY

    lda         #0
    sta         curY

loopY:
    lda         #0
    sta         curX

loopX:
    jsr         setPixel
    inc         curX
    lda         curX
    cmp         shapeWidth
    bne         loopX

    inc         curY
    lda         curY
    cmp         shapeHeight
    bne         loopY

    ; restore
    lda         tempX
    sta         curX
    lda         tempY
    sta         curY

    rts

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
; initTileAccess
;
;-----------------------------------------------------------------------------
.proc initTileAccess

    jsr         initTile

    clc
    lda         curY
    asl                     ; 2 bytes per line
    adc         tilePtr0
    sta         tilePtr0

    rts

.endproc

;-----------------------------------------------------------------------------
; getPixel
;
;   Get 2-bit pixel from sprite shapeIndex at curX,curY
;
;-----------------------------------------------------------------------------

.proc getPixel

    lda         shapeIndex
    jsr         initTileAccess

    ldx         curX

    lda         #0
    sta         colorPalette

    ldy         #0
    lda         (tilePtr0),y
    bpl         :+
    lda         #4
    sta         colorPalette
:

    ldy         #1
    lda         (tilePtr0),y
    and         mask2Table1,x
    lsr                             ; put bit 0 in carry
    bne         lookup              ; if non-zero, get color

    lda         #0
    ror                             ; put carry in bit 7
    sta         temp

    ldy         #0
    lda         (tilePtr0),y
    and         #$7f                ; Remove color bit if set
    ora         temp                ; Put shifted bit in bit 7
    and         mask2Table0Bit8,x

lookup:
    tay         ; y = 2 set pixels
    clc
    lda         colorLookup,y
    adc         colorPalette
    rts

temp:           .byte   0
colorPalette:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; copyToBuffer
;
;   Copy tile
;
;-----------------------------------------------------------------------------

.proc copyToBuffer

    ; save current cursor position
    lda         curX
    sta         tempX
    lda         curY
    sta         tempY

    lda         #0
    sta         bufferIndex
    sta         curY

loopY:
    lda         #0
    sta         curX

loopX:
    jsr         getPixel
    ldx         bufferIndex
    sta         copyBuffer,x
    inc         curX
    inc         bufferIndex

    lda         curX
    cmp         shapeWidth
    bne         loopX

    inc         curY
    lda         curY
    cmp         shapeHeight
    bne         loopY

    ; restore cursor
    lda         tempX
    sta         curX
    lda         tempY
    sta         curY
    rts

.endproc

;-----------------------------------------------------------------------------
; Paste from buffer
;
;   Paste tile
;
;-----------------------------------------------------------------------------

.proc pasteFromBuffer

    ; save current cursor position
    lda         curX
    sta         tempX
    lda         curY
    sta         tempY

    lda         #0
    sta         bufferIndex
    sta         curY

loopY:
    lda         #0
    sta         curX

loopX:
    ldx         bufferIndex
    lda         copyBuffer,x
    jsr         setColor
    jsr         setPixel
    inc         curX
    inc         bufferIndex

    lda         curX
    cmp         shapeWidth
    bne         loopX
    inc         curY

    lda         curY
    cmp         shapeHeight
    bne         loopY

    ; restore cursor
    lda         tempX
    sta         curX
    lda         tempY
    sta         curY
    rts

.endproc

;-----------------------------------------------------------------------------
; Inverse Colors
;
;-----------------------------------------------------------------------------

.proc inverseColors

    ; save current cursor position
    lda         curX
    sta         tempX
    lda         curY
    sta         tempY

    lda         #0
    sta         curY

loopY:
    lda         #0
    sta         curX

loopX:
    jsr         getPixel
    eor         #%111
    jsr         setColor
    jsr         setPixel
    inc         curX

    lda         curX
    cmp         shapeWidth
    bne         loopX
    inc         curY

    lda         curY
    cmp         shapeHeight
    bne         loopY

    ; restore cursor
    lda         tempX
    sta         curX
    lda         tempY
    sta         curY
    rts

.endproc

;-----------------------------------------------------------------------------
; setColor - color passed in A
;-----------------------------------------------------------------------------

.proc setColor
    tax
    lda         colorTable,x
    sta         colorEven
    lda         colorTable+8,x
    sta         colorOdd
    rts
.endproc

;-----------------------------------------------------------------------------
; setPixel
;
;   Set pixel from sprite shapeIndex at curX,curY to colorEven/Odd
;
;-----------------------------------------------------------------------------

.proc setPixel
    lda         shapeIndex
    jsr         initTileAccess
    ldx         curX
    lda         colorEven
    and         mask2Table0,x
    sta         color0
    lda         colorOdd
    and         mask2Table1,x
    sta         color1

    lda         colorEven
    and         #$80
    sta         colorPalette

    ldy         #0
    lda         mask2Table0,x
    eor         #$ff
    and         #$7f            ; always set palette
    and         (tilePtr0),y
    ora         color0
    ora         colorPalette
    sta         (tilePtr0),y

    iny

    lda         mask2Table1,x
    eor         #$ff
    and         #$7f            ; always set palette
    and         (tilePtr0),y
    ora         color1
    ora         colorPalette
    sta         (tilePtr0),y

    rts

colorPalette:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; printDump
;-----------------------------------------------------------------------------

.proc dumpShape

    lda         shapeIndex
    jsr         initTile

    jsr         inline_print
    .byte       ".byte ",0

    lda         #0
    sta         dumpCount
    jmp         dump_loop
dump_comma:
    lda         #$80 + ','
    jsr         COUT
dump_loop:
    lda         #$80 + '$'
    jsr         COUT
    ldy         dumpCount
    lda         (tilePtr0),y
    jsr         PRBYTE
    inc         dumpCount
    lda         dumpCount
    cmp         shapeSize
    beq         dump_finish
    lda         dumpCount
    and         #$7
    bne         dump_comma
    jsr         inline_print
    .byte       13,".byte ",0
    jmp         dump_loop

dump_finish:

    lda         #$80 + 13
    jsr         COUT
    rts

dumpCount:      .byte       0

.endproc

.proc dumpAll

    lda         shapeIndex
    sta         tempX

    lda         #0
    sta         shapeIndex
:
    jsr         dumpShape

    lda         #$80 + ';'
    jsr         COUT
    lda         shapeIndex
    jsr         PRBYTE
    lda         #$80 + 13
    jsr         COUT

    inc         shapeIndex
    lda         shapeIndex
    cmp         #TILE_COUNT
    bne         :-

    lda         tempX
    sta         shapeIndex

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
; Clear Screen
;
;   Clear screen to color in X, preserving screen holes
;
;-----------------------------------------------------------------------------
.proc clearScreen
    jsr     setColor

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

    ; Set ctrl-y vector
    lda         #$4c        ; JMP
    sta         $3f8
    lda         #<main::command_loop
    sta         $3f9
    lda         #>main::command_loop
    sta         $3fa

    ;bit        TXTSET
    jmp         MONZ        ; enter monitor

.endproc

;-----------------------------------------------------------------------------
; Quit
;
;   Exit to ProDos
;-----------------------------------------------------------------------------
.proc quit

    jsr         MLI
    .byte       CMD_QUIT
    .word       quitParams

.endproc

;-----------------------------------------------------------------------------
; Utilities
;-----------------------------------------------------------------------------
.include        "inline_print.asm"

;-----------------------------------------------------------------------------
; Globals
;-----------------------------------------------------------------------------

; user control
currentColor:       .byte       0

; canvas variables
canvasOffsetX:      .byte       2
canvasOffsetY:      .byte       2
mask0:              .byte       0
mask1:              .byte       0
color0:             .byte       0
color1:             .byte       0
frameX0:            .byte       0
frameY0:            .byte       0
frameX1:            .byte       14+4
frameY1:            .byte       32+4

; size variables
shapeIndex:         .byte       0
shapeWidth:         .byte       7               ; width in 2-bit pixels
shapeBytes:         .byte       2               ; width*2/7
shapeHeight:        .byte       8
shapeSize:          .byte       16              ; bytes * height
shapeFrameWidth:    .byte       7               ; width/2 + 4
shapeFrameHeight:   .byte       8               ; height/2 + 4

shapeOffset:        .byte       0, 4, 1, 5, 2, 6, 3

; buffer variables
tempX:              .byte       0
tempY:              .byte       0
bufferIndex:        .byte       0

;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

quitParams:
    .byte       4               ; 4 parameters
    .byte       0               ; 0 is the only quit type
    .word       0               ; Reserved pointer for future use (what future?)
    .byte       0               ; Reserved byte for future use (what future?)
    .word       0               ; Reserved pointer for future use (what future?)


;               black   purple  green   white   black   blue    orange  white
colorTable:
    .byte       $00,    $55,    $2a,    $7f,    $80,    $d5,    $aa,    $ff     ; Even
    .byte       $00,    $2a,    $55,    $7f,    $80,    $aa,    $d5,    $ff     ; Odd

div2x14:
    .byte       00, 00, 00, 00, 00, 00, 00
    .byte       02, 02, 02, 02, 02, 02, 02

mask4Table0:    ; first byte of 4 pixel mask by offset
    .byte       $0f, $1e, $3c, $78, $70, $60, $40

mask4Table1:    ; second byte of 4 pixel mask by offset
    .byte       $00, $00, $00, $00, $01, $03, $07

div4x7:
    .byte       00, 00, 01, 01, 02, 02, 03      ; 0..6
    .byte       04, 04, 05, 05, 06, 06, 07      ; 7..13
    .byte       08, 08, 09, 09, 10, 10, 11      ; 14..20
    .byte       12, 12, 13, 13, 14, 14, 15      ; 21..27
    .byte       16, 16, 17, 17, 18, 18, 19      ; 28..34
    .byte       20, 20, 21, 21, 22, 22, 23      ; 35..41
    .byte       24, 24, 25, 25, 26, 26, 27      ; 42..48
    .byte       28, 28, 29, 29, 30, 30, 31      ; 49..55
    .byte       32, 32, 33, 33, 34, 34, 35      ; 56..62
    .byte       36, 36, 37, 37, 38, 38, 39      ; 63..69

div4x7offset:
    .byte       0,  4,  1,  5,  2,  6,  3       ; 0..6
    .byte       0,  4,  1,  5,  2,  6,  3       ; 7..13
    .byte       0,  4,  1,  5,  2,  6,  3       ; 14..20
    .byte       0,  4,  1,  5,  2,  6,  3       ; 21..27
    .byte       0,  4,  1,  5,  2,  6,  3       ; 28..34
    .byte       0,  4,  1,  5,  2,  6,  3       ; 35..41
    .byte       0,  4,  1,  5,  2,  6,  3       ; 42..48
    .byte       0,  4,  1,  5,  2,  6,  3       ; 49..55
    .byte       0,  4,  1,  5,  2,  6,  3       ; 56..62
    .byte       0,  4,  1,  5,  2,  6,  3       ; 63..69

mask2Table0:    ; first byte of 4 pixel mask by offset
    .byte       $03, $0c, $30, $40, $00, $00, $00   ; first 2 bytes
    .byte       $03, $0c, $30, $40, $00, $00, $00   ; repeat for second 2 bytes

mask2Table1:    ; second byte of 4 pixel mask by offset
    .byte       $00, $00, $00, $01, $06, $18, $60
    .byte       $00, $00, $00, $01, $06, $18, $60

mask2Table0Bit8:
    .byte       $03, $0c, $30, $C0, $00, $00, $00
    .byte       $03, $0c, $30, $C0, $00, $00, $00

div2x7:
    .byte       00, 00, 00, 00, 00, 00, 00     ; 0..6
    .byte       02, 02, 02, 02, 02, 02, 02     ; 7..13
    .byte       04, 04, 04, 04, 04, 04, 04     ; 14..20
    .byte       06, 06, 06, 06, 06, 06, 06     ; 21..27
    .byte       08, 08, 08, 08, 08, 08, 08     ; 28..34
    .byte       10, 10, 10, 10, 10, 10, 10     ; 35..41
    .byte       12, 12, 12, 12, 12, 12, 12     ; 42..48
    .byte       14, 14, 14, 14, 14, 14, 14     ; 49..55
    .byte       16, 16, 16, 16, 16, 16, 16     ; 56..62
    .byte       18, 18, 18, 18, 18, 18, 18     ; 63..69
    .byte       20, 20, 20, 20, 20, 20, 20     ; 70..76
    .byte       22, 22, 22, 22, 22, 22, 22     ; 77..83
    .byte       24, 24, 24, 24, 24, 24, 24     ; 84..90
    .byte       26, 26, 26, 26, 26, 26, 26     ; 91..97
    .byte       28, 28, 28, 28, 28, 28, 28     ; 98..104
    .byte       30, 30, 30, 30, 30, 30, 30     ; 105..111
    .byte       32, 32, 32, 32, 32, 32, 32     ; 112..118
    .byte       34, 34, 34, 34, 34, 34, 34     ; 119..125
    .byte       36, 36, 36, 36, 36, 36, 36     ; 126..132
    .byte       38, 38, 38, 38, 38, 38, 38     ; 133..139

div2x7offset:
    .byte       0,  2,  4,  6,  1,  3,  5      ; 0..6
    .byte       0,  2,  4,  6,  1,  3,  5      ; 7..13
    .byte       0,  2,  4,  6,  1,  3,  5      ; 14..20
    .byte       0,  2,  4,  6,  1,  3,  5      ; 21..27
    .byte       0,  2,  4,  6,  1,  3,  5      ; 28..34
    .byte       0,  2,  4,  6,  1,  3,  5      ; 35..41
    .byte       0,  2,  4,  6,  1,  3,  5      ; 42..48
    .byte       0,  2,  4,  6,  1,  3,  5      ; 49..55
    .byte       0,  2,  4,  6,  1,  3,  5      ; 56..62
    .byte       0,  2,  4,  6,  1,  3,  5      ; 63..69
    .byte       0,  2,  4,  6,  1,  3,  5      ; 70..76
    .byte       0,  2,  4,  6,  1,  3,  5      ; 77..83
    .byte       0,  2,  4,  6,  1,  3,  5      ; 84..90
    .byte       0,  2,  4,  6,  1,  3,  5      ; 91..97
    .byte       0,  2,  4,  6,  1,  3,  5      ; 98..104
    .byte       0,  2,  4,  6,  1,  3,  5      ; 105..111
    .byte       0,  2,  4,  6,  1,  3,  5      ; 112..118
    .byte       0,  2,  4,  6,  1,  3,  5      ; 119..125
    .byte       0,  2,  4,  6,  1,  3,  5      ; 126..132
    .byte       0,  2,  4,  6,  1,  3,  5      ; 133..139

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

colorLookup:
    ; issolate 2 bits in aligned positions
    .byte       0,  1,  2,  3
    .byte       1,  $ff,$ff,$ff
    .byte       2,  $ff,$ff,$ff
    .byte       3,  $ff,$ff,$ff
    .byte       1,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       2,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       3,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       1,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       2,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       3,  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

; max size is (14-6)x32 = 8*32 = 256
copyBuffer:
    .res        256

;-----------------------------------------------------------------------------
; Assets
;-----------------------------------------------------------------------------
.align 256
tileSheet:
.include        "font.asm"


