;-----------------------------------------------------------------------------
; Paul Wasson - 2024
;-----------------------------------------------------------------------------
; Music routines
;-----------------------------------------------------------------------------

; Re-use zero page addresses

tone1   :=      curX
tone2   :=      curY
songPtr :=      stringPtr0

;-----------------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------------

; durations

NOTE_DONE           = 0
NOTE_WHOLE          = 80
NOTE_HALF           = NOTE_WHOLE/2
NOTE_QUARTER        = NOTE_WHOLE/4

;rest

NOTE_REST           = 0

;notes
NOTE_C7             = $10

NOTE_B6             = $11
NOTE_As6            = $12
NOTE_Bb6            = $12
NOTE_A6             = $13
NOTE_Gs6            = $15
NOTE_Ab6            = $15
NOTE_G6             = $16
NOTE_Fs6            = $17
NOTE_Gb6            = $17
NOTE_F6             = $18
NOTE_E6             = $1A
NOTE_Ds6            = $1B
NOTE_Eb6            = $1B
NOTE_D6             = $1D
NOTE_Cs6            = $1F
NOTE_Db6            = $1F
NOTE_C6             = $21

NOTE_B5             = $23
NOTE_As5            = $25
NOTE_Bb5            = $25
NOTE_A5             = $27
NOTE_Gs5            = $29
NOTE_Ab5            = $29
NOTE_G5             = $2C
NOTE_Fs5            = $2E
NOTE_Gb5            = $2E
NOTE_F5             = $31
NOTE_E5             = $34
NOTE_Ds5            = $37
NOTE_Eb5            = $37
NOTE_D5             = $3A
NOTE_Cs5            = $3E
NOTE_Db5            = $3E
NOTE_C5             = $41

NOTE_B4             = $45
NOTE_As4            = $49
NOTE_Bb4            = $49
NOTE_A4             = $4E
NOTE_Gs4            = $52
NOTE_Ab4            = $52
NOTE_G4             = $57
NOTE_Fs4            = $5C
NOTE_Gb4            = $5C
NOTE_F4             = $62
NOTE_E4             = $68
NOTE_Ds4            = $6E
NOTE_Eb4            = $6E
NOTE_D4             = $74
NOTE_Cs4            = $7B
NOTE_Db4            = $7B
NOTE_C4             = $82

NOTE_B3             = $8A
NOTE_As3            = $92
NOTE_Bb3            = $92
NOTE_A3             = $9B
NOTE_Gs3            = $A4
NOTE_Ab3            = $A4
NOTE_G3             = $AE
NOTE_Fs3            = $B9
NOTE_Gb3            = $B9
NOTE_F3             = $C3
NOTE_E3             = $CF
NOTE_Ds3            = $DB
NOTE_Eb3            = $DB
NOTE_D3             = $E8
NOTE_Cs3            = $F6
NOTE_Db3            = $F6



;-----------------------------------------------------------------------------
; Play Song
;-----------------------------------------------------------------------------

.proc playSong
    ldy         #0
    sty         index
songLoop:
    ldy         index
    lda         (songPtr),y
    sta         tone1
    iny
    lda         (songPtr),y
    sta         tone2
    iny
    lda         (songPtr),y
    beq         done
    iny
    sty         index
    jsr         play2Tones
    jmp         songLoop
done:
    rts

TEST_SONG   = $300

test:                       ; type song in at $300 and call
    lda         #<TEST_SONG
    sta         songPtr
    lda         #>TEST_SONG
    sta         songPtr+1
    jsr         playSong
    rts

index:  .byte   0

.endproc

;-----------------------------------------------------------------------------
; Play 2 Tones
;
;   X = tone1, Y = tone2, A = duration
;-----------------------------------------------------------------------------

.proc play2Tones

tone1   :=      curX
tone2   :=      curY

    sta         duration2
    lda         #0
    sta         duration1

    ldx         tone1

    beq         playRest

    ldy         tone2
    beq         play1tone

t2_loop:                        ;   none    T1      T2      T1&T2
    dex                         ;   2       2       2       2
    bne         t2_noT1         ;   3       2       3       2
    sta         SPEAKER         ;   x       4       x       4
    ldx         tone1           ;   x       3       x       3
    dey                         ;   x       2       x       2
    bne         t2_yes1no2      ;   x       3       x       2
    sta         SPEAKER         ;   x       x       x       4       ; T1&T2 == same time
    ldy         tone2           ;   x       x       x       2
    dec         duration1       ;   x       x       x       6
    bne         t2_loop         ;   x       x       x       3
    dec         duration2       ;   x       x       x       -
    bne         t2_loop         ;   x       x       x       -
    rts                         ;   x       x       x       -
t2_noT1:
    nop                         ;   2       x       2       x
    nop                         ;   2       x       2       x
    nop                         ;   2       x       2       x
    dey                         ;   2       x       2       x
    bne         t2_no1no2       ;   3       x       2       x
    sta         SPEAKER         ;   x       x       4       x
    ldy         tone2           ;   x       x       2       x
    dec         duration1       ;   x       x       6       x
    bne         t2_loop         ;   x       x       3       x
    dec         duration2       ;   x       x       -       x
    bne         t2_loop         ;   x       x       -       x
    rts                         ;   x       x       -       x
t2_yes1no2:
t2_no1no2:
    jmp         :+              ;   3       3       x       x
:   nop                         ;   2       2       x       x
    dec         duration1       ;   6       6       x       x
    bne         t2_loop         ;   3       3       x       x
    dec         duration2       ;   -       -       x       x
    bne         t2_loop         ;   -       -       x       x
    rts                         ;   -       -       x       x
                                ;  30      30      30      30

playRest:
loop_rest:                      ;   none
    dec         dummy           ;   6
    dec         dummy           ;   6
    dec         dummy           ;   6
    jmp         :+              ;   3
:   dec         duration1       ;   6
    bne         loop_rest       ;   3
    dec         duration2       ;   -
    bne         loop_rest       ;   -
    rts                         ;   -
                                ;   30

play1tone:
t1_loop:                        ;   none    T1
    dex                         ;   2       2
    bne         t1_noT1         ;   3       2
    sta         SPEAKER         ;   x       4
    ldx         tone1           ;   x       3
t1_cont:
    dec         dummy           ;   6
    nop                         ;   2       2
    nop                         ;   2       2
    dec         duration1       ;   6       6
    bne         t1_loop         ;   3       3
    dec         duration2       ;   -       -
    bne         t1_loop         ;   -       -
    rts                         ;   -       -
t1_noT1:
    jmp         :+              ;   3       x
:   jmp         t1_cont         ;   3       x
                                ;  30      30

duration1:  .byte   0
duration2:  .byte   0
dummy:      .byte   0

.endproc

;-----------------------------------------------------------------------------
; Play PWM
;
;   X = tone1, Y = tone2, A = duration
;-----------------------------------------------------------------------------

; make sure branches are within the same page
.align 256

.proc playPWM

index0      :=      curX
index1      :=      curY
FREQ_INC    =       20

    lda         #0
    sta         index0
    sta         index1
loop:
    lda         index0
    clc
    adc         #FREQ_INC
    sta         index0
    lda         index1
    adc         #0
    sta         index1
    tax
    lda         sample64,x      ; 4
    sta         vbranchA+1      ; 4
    sta         SPEAKER         ; 4
vbranchA:                       ;       set jump 0..15 (always taken)
    bpl         :+              ; 3     [15 cycles]
:                               ; 2 * (63-n)
.repeat(63)
    nop
.endrep
    eor         #$0f            ; 2     flip
    sta         vbranchB+1      ; 4
    sta         SPEAKER         ; 4
vbranchB:
    bpl         :+              ; 3     [13 cycles]
:                               ; 2 * n
.repeat(63)
    nop
.endrep
    jmp         loop            ; 3     [3 cycle]

                                ; 31 + 63*2 = 157 cycles
.align 256
sample16:
    .byte   8,  8,  8,  8,  8,  9,  9,  9,  9,  9,  10, 10, 10, 10, 10, 11
    .byte   11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13
    .byte   13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15
    .byte   15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
    .byte   15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
    .byte   15, 15, 15, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 13, 13, 13
    .byte   13, 13, 13, 13, 12, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 11
    .byte   10, 10, 10, 10, 10, 9,  9,  9,  9,  9,  8,  8,  8,  8,  8,  8
    .byte   7,  7,  7,  7,  7,  6,  6,  6,  6,  6,  5,  5,  5,  5,  5,  4
    .byte   4,  4,  4,  4,  4,  3,  3,  3,  3,  3,  3,  2,  2,  2,  2,  2
    .byte   2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0
    .byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    .byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    .byte   0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2
    .byte   2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  4
    .byte   5,  5,  5,  5,  5,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  8

sample64:
    .byte  32, 33, 34, 35, 35, 36, 37, 38, 39, 39, 40, 41, 42, 42, 43, 44
    .byte  44, 45, 46, 47, 47, 48, 49, 49, 50, 51, 51, 52, 52, 53, 54, 54
    .byte  55, 55, 56, 56, 57, 57, 58, 58, 59, 59, 59, 60, 60, 60, 61, 61
    .byte  61, 62, 62, 62, 62, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63
    .byte  63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 62, 62, 62, 62, 61, 61
    .byte  61, 60, 60, 60, 59, 59, 59, 58, 58, 57, 57, 56, 56, 55, 55, 54
    .byte  54, 53, 52, 52, 51, 51, 50, 49, 49, 48, 47, 47, 46, 45, 44, 44
    .byte  43, 42, 42, 41, 40, 39, 39, 38, 37, 36, 35, 35, 34, 33, 32, 32
    .byte  31, 30, 29, 28, 28, 27, 26, 25, 24, 24, 23, 22, 21, 21, 20, 19
    .byte  19, 18, 17, 16, 16, 15, 14, 14, 13, 12, 12, 11, 11, 10,  9, 9
    .byte  8,  8,  7,  7,  6,  6,  5,  5,  4,  4,  4,  3,  3,  3,  2,  2
    .byte  2,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    .byte  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  2,  2
    .byte  2,  3,  3,  3,  4,  4,  4,  5,  5,  6,  6,  7,  7,  8,  8,  9
    .byte  9,  10, 11, 11, 12, 12, 13, 14, 14, 15, 16, 16, 17, 18, 19, 19
    .byte  20, 21, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 29, 30, 31, 32


length0:
    sta         SPEAKER     ; 3
    sta         SPEAKER     ; 3



.endproc

.proc playDutyCycle

    stx         tone1
    sty         tone2

play1:
    sta         SPEAKER
loop1:
    lda         KBD
    bmi         done
    dex
    bne         loop1
    ldy         tone2
    jmp         play2

play2:
    sta         SPEAKER
loop2:
    lda         KBD
    bmi         done
    dey
    bne         loop2
    ldx         tone1
    jmp         play1

done:
    sta         KBDSTRB
    rts

.endproc


