;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; inline_print - display following string to COUT
;-----------------------------------------------------------------------------
; Uses stack pointer to find string
;   clobbers A,X,Y
;
; Example:
;   jsr     inline_print
;   .byte   "HELLO WORLD!",0
;   <next instruction>

.proc inline_print
    ; Pop return address to find string
    pla
    sta     stringPtr0
    pla
    sta     stringPtr1
    ldy     #0

    ; Print characters until 0 (end-of-string)
printLoop:
    iny
    bne     :+              ; Allow strings > 255
    inc     stringPtr1
:
    tya
    pha
    lda     (stringPtr0),y
    beq     printExit
    ora     #$80               ; not inverse/flashing
    jsr     COUT
    pla
    tay
    sta     SPEAKER             ; Noisy print
    jmp     printLoop

printExit:
    sta     CLR80COL    ; COUT sets 80COL

    
    pla                 ; clean up stack
    ; calculate return address after print string
    clc
    tya
    adc     stringPtr0  ; add low-byte first
    tax                 ; save in X
    lda     stringPtr1  ; carry to high-byte
    adc     #0          
    pha                 ; push return high-byte
    txa
    pha                 ; push return low-byte
    rts                 ; return

.endproc ; print

;-----------------------------------------------------------------------------
; print - print string ending with 0
;
;   Set string pointer before calling
;-----------------------------------------------------------------------------

.proc print

    ldy     #0

    ; Print characters until 0 (end-of-string)
printLoop:
    tya
    pha
    lda     (stringPtr0),y
    beq     printExit
    ora     #$80                ; not inverse/flashing
    jsr     COUT
    pla
    tay
    iny
    bne     printLoop           ; Allow strings > 255
    inc     stringPtr1
    bne     printLoop

printExit:
    pla
    sta     CLR80COL    ; COUT sets 80COL

    rts

.endproc



;-----------------------------------------------------------------------------
; print_length - print string with length in byte 0
;
;   Set string pointer before calling
;-----------------------------------------------------------------------------

.proc print_length

    ldy     #0

    lda     (stringPtr0),y
    bne     :+              ; check for length 0 strings
    rts
:
    sta     length

:
    iny
    tya
    pha
    lda     (stringPtr0),y
    ora     #$80
    jsr     COUT
    pla
    tay
    dec     length
    bne     :-

    sta     CLR80COL    ; COUT sets 80COL

    rts

length:     .byte 0

.endproc
