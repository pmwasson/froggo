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
    sta         SPEAKER         ;   x       x       x       4
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