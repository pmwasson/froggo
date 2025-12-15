; Credits
;--------------------------------------------------------------------------------

creditsString:
    QuoteText   "",8,0
    QuoteText   "@ Froggo  @",5,2
    .byte       CREDIT_DIVIDE
    QuoteText   "inspiredByThe",0,0
    QuoteText   "classicFroggerGame",1,0
    QuoteText   "andTheMoreRecent",9,0
    QuoteText   "crossyRoad",5,2
    .byte       CREDIT_DIVIDE
    QuoteText   "musicAndSound",8,0
    QuoteText   "effectsWere",1,0
    QuoteText   "generatedUsingThe",2,0
    QuoteText   "electricDuetSong",2,0
    QuoteText   "player,CreatedBy",1,0
    QuoteText   "paulLutus (c) 1981",7,1
    QuoteText   "arachnoid.com",2,2
    .byte       CREDIT_DIVIDE
    QuoteText   "allOtherCodeWas",10,0
    QuoteText   "writtenBy",9,0
    QuoteText   "paulWasson",2,1
    QuoteText   "lasermego.com/a2sw",3,2
    .byte       CREDIT_DIVIDE
    QuoteText   "musicComposedBy",10,0
    QuoteText   "benWasson",0,2
    .byte       CREDIT_DIVIDE
    QuoteText   "thanksToThePeople",0,0
    QuoteText   "behindTheFollowing",5,0
    QuoteText   "toolsThatMade",5,0
    QuoteText   "froggoPossible",4,0
    QuoteText   "&Applewin",4,0
    QuoteText   "&Ca65 (cc65)",4,0
    QuoteText   "&AppleCommander",4,0
    QuoteText   "&Aseprite",0,2
    .byte       CREDIT_DIVIDE
    QuoteText   "",10,7
    QuoteText   "thanksFor",12,0
    QuoteText   "playing!",14,2
    QuoteText   "",10,7
    QuoteText   "@  @  @  @",0,0
    .byte       $FF             ; done


;                    ;
;                    ;
;                    ;
;@ Froggo @          ;
;--------------------;
;Inspired by the     ;
;classic Frogger game;
;and the more recent ;
;Crossy Road.        ;
;--------------------;
;Music and sound     ;
;effects were        ;
;generated using the ;
;Electric Duet song  ;
;player, created by  ;
;Paul Lutus (c) 1981.;
;arachnoid.com       ;
;--------------------;
;All other code was  ;
;written by          ;
;Paul Wasson.        ;
;lasermego.com/a2sw  ;
;--------------------;
;Music composed by   ;
;Ben Wasson.         ;
;--------------------;
;Thanks to the people;
;behing the following;
;tools that made     ;
;Froggo possible     ;
;* AppleWin          ;
;* ca65 (cc65)       ;
;* Apple Commander   ;
;* Aseprite          ;
;--------------------;
;Thanks for playing! ;
;                    ;
;        @           ;
;                    ;
;                    ;
;                    ;
;                    ;
;                    ;
;                    ;
;                    ;
;--------------------------------------------------------------------------------

;-----------------------------------------------------------------------------

CREDIT_DIVIDE   =   $3F
tileOffset      := curX
screenOffset    := curY
creditBuffer    =  cutScene     ; reuse buffer (will need to reload next scene)

;-----------------------------------------------------------------------------
; Play Credits
;-----------------------------------------------------------------------------

.proc playCredits

    jsr         initDisplay

    lda         #<creditsString
    sta         stringPtr0
    lda         #>creditsString
    sta         stringPtr0+1
    jsr         scrollScreen
:
    lda         KBD
    bpl         :-
    sta         KBDSTRB
    rts

.endproc


;-----------------------------------------------------------------------------
; Scroll Screen
;-----------------------------------------------------------------------------
.proc scrollScreen

creditLoop:
    lda         #0
    sta         tileOffset

lineLoop:
    jsr         scroll1to2
    jsr         drawTextLine
    sta         stringDelta
    bit         HISCR

    jsr         scroll2to1
    jsr         drawBlankLine
;    jsr         drawTextLine
;    sta         stringDelta
    bit         LOWSCR

    lda         KBD
    bmi         done

    lda         tileOffset
    cmp         #16
    bne         lineLoop

    ; advance to the next line
    lda         stringPtr0
    clc
    adc         stringDelta
    sta         stringPtr0
    lda         stringPtr0+1
    adc         #0
    sta         stringPtr0+1

    ldy         #0
    lda         (stringPtr0),y
    cmp         #$FF
    bne         creditLoop

done:
    rts

scroll2to1:
    ; Copy screen 2 to screen 1

    ; Lines %8 == 0..6
    ; Offset by $400

    lda         #<$2000
    sta         screenPtr0
    lda         #>$2000
    sta         screenPtr0+1
    lda         #<$4400
    sta         bufferPtr0
    lda         #>$4400
    sta         bufferPtr0+1
    lda         #$3C            ; page to stop writing
    ldx         #0
    jsr         copyMemBig

    ; wrap around source + 80
    ; Line %8 == 7
    ; Offset by $480
    lda         #<$4080
    sta         bufferPtr0
    lda         #>$4080
    sta         bufferPtr0+1
    lda         #$3F
    ldx         #$80
    jsr         copyMemBig

    lda         #<$3F80
    sta         screenPtr0
    lda         #<$4028
    sta         bufferPtr0
    lda         #>$4028
    sta         bufferPtr0+1
    ldx         #80             ; 2 lines
    jsr         copyMemSmall
    rts

scroll1to2:
    ; Copy screen 1 to screen 2, 1 line up
    lda         #<$4000
    sta         screenPtr0
    lda         #>$4000
    sta         screenPtr0+1
    lda         #<$2400
    sta         bufferPtr0
    lda         #>$2400
    sta         bufferPtr0+1
    lda         #$5C            ; page to stop writing
    ldx         #0
    jsr         copyMemBig

    lda         #<$2080
    sta         bufferPtr0
    lda         #>$2080
    sta         bufferPtr0+1
    lda         #$5F
    ldx         #$80
    jsr         copyMemBig

    lda         #<$5F80
    sta         screenPtr0
    lda         #<$2028
    sta         bufferPtr0
    lda         #>$2028
    sta         bufferPtr0+1
    ldx         #80             ; 2 lines
    jsr         copyMemSmall
    rts

copyMemBig:
    sta         stopPage
    ldy         #0
copyLoop:
    lda         (bufferPtr0),y
    sta         (screenPtr0),y
    iny
    bne         copyLoop
    inc         bufferPtr0+1
    inc         screenPtr0+1
    lda         screenPtr0+1
    cmp         stopPage
    bne         copyLoop
    txa
    bne         copyLoopSmall
    rts
    ; copy "extra"
copyMemSmall:
    ldy         #0
copyLoopSmall:
    lda         (bufferPtr0),y
    sta         (screenPtr0),y
    iny
    dex
    bne         copyLoopSmall
    rts

stringDelta:    .byte   0
scrollCount:    .byte   0
stopPage:       .byte   0

.endproc


;-----------------------------------------------------------------------------
; Draw Blank Line
;-----------------------------------------------------------------------------

.proc drawBlankLine
    lda         #$D0
    sta         screenPtr0
    ldy         #40-1
    lda         #0
loop:
    sta         (screenPtr0),y
    dey
    bpl         loop
    rts
.endproc

;-----------------------------------------------------------------------------
; Draw 1 pixel line of text
;-----------------------------------------------------------------------------
; 00cc_cccc - draw tile C and increment tileX
; 01cc_cccc - increment tileX, draw tile C and increment tileX (new word)
; 1yyy_xxx0 - reset to initial tileX and increment tileY by yyy and tileX by xxx0 (even)
; 1111_1111 - end of string
.proc drawTextLine
    lda         #$D0
    sta         screenPtr0
    lda         skipCount
    beq         noSkip
    ; continue skipping!
    ldx         #40
    lda         #0
    ldy         #0
    jmp         indentLoop

noSkip:
    ; check if new line
    lda         tileOffset
    bne         :+
    lda         nextIndent
    sta         indent
    lda         nextSkipCount
    sta         skipCount
    beq         :+
    ; do skip!
    ldx         #40
    lda         #0
    ldy         #0
    jmp         indentLoop

:
    ldy         #0
    sty         screenOffset
    sty         index

    ; check for indent
    ldx         indent
    beq         stringLoop
    lda         #0
indentLoop:
    sta         (screenPtr0),y
    iny
    dex
    bne         indentLoop
    sty         screenOffset
    lda         skipCount
    beq         doneIndent
    dec         skipCount
    dec         nextSkipCount
    lda         #0
    rts

doneIndent:

stringLoop:
    ldy         index
    lda         (stringPtr0),y
    bmi         doneWithLine
    and         #NEW_WORD
    beq         noSpace

    ; draw a space
    lda         #0
    ldy         screenOffset
    sta         (screenPtr0),y
    iny
    sta         (screenPtr0),y
    iny
    sty         screenOffset

noSpace:
    ldy         index
    lda         (stringPtr0),y
    cmp         #CREDIT_DIVIDE
    beq         doDivide
    and         #$3f
    jsr         drawTileOffset
    inc         index
    jmp         stringLoop

doDivide:
    ldy         #0
divideLoop:
    lda         #$33
    sta         (screenPtr0),y
    iny
    lda         #$66
    sta         (screenPtr0),y
    iny
    lda         #$4C
    sta         (screenPtr0),y
    iny
    lda         #$19
    sta         (screenPtr0),y
    iny
    cpy         #40
    bne         divideLoop

    lda         #8
    sta         nextSkipCount
    lda         #16
    sta         tileOffset      ; skip to the end

    lda         #1
    rts

doneWithLine:
    lda         #0
    ldy         screenOffset
restOfLineLoop:
    cpy         #40
    beq         :+
    sta         (screenPtr0),y
    iny
    jmp         restOfLineLoop
:

    ldy         index
    lda         (stringPtr0),y
    and         #$0F
    sta         nextIndent
    lda         (stringPtr0),y
    and         #$70
    lsr
    lsr
    sta         nextSkipCount

    inc         tileOffset
    inc         tileOffset
    inc         index
    lda         index
    rts

skipCount:      .byte   0
indent:         .byte   0

nextSkipCount:  .byte   0
nextIndent:     .byte   0

index:          .byte   0

.endproc

;-----------------------------------------------------------------------------
; Draw Tile Offset
;   Draw 1 line of tile to screen
;   tileOffset = offset into tile for line (restored on return)
;   screenOffset = x offset of screen (+tile width on return)
;-----------------------------------------------------------------------------
.proc drawTileOffset

    ; set up tile pointer
    jsr         initTile

    ; y = offset into tile
    ; x = offset into buffer

    ldy         tileOffset
    lda         (tilePtr0),y
    ldy         screenOffset
    sta         (screenPtr0),y

    inc         tileOffset
    inc         screenOffset

    ldy         tileOffset
    lda         (tilePtr0),y
    ldy         screenOffset
    sta         (screenPtr0),y

    dec         tileOffset
    inc         screenOffset

    rts
.endproc

