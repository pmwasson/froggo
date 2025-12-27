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

;-----------------------------------------------------------------------------

.proc readme
    jsr         TEXT
    jsr         HOME
    jsr         inline_print
    .byte       " _____________________________________",13
    .byte       "|                                     |",13
    .byte       "| Hello!                              |",13
    .byte       "| Thanks for playing FROGGO.          |",13
    .byte       "| Also included on this disk:         |",13
    .byte       "| -parallax : a scrolling demo        |",13
    .byte       "| -fedit    : a font/tile editor      |",13
    .byte       "|                                     |",13
    .byte       "| FROGGO controls:                    |",13
    .byte       "|  AZ <- -> : Movement                |",13
    .byte       "|  ESC      : Menu                    |",13
    .byte       "|  *        : Break into monitor      |",13
    .byte       "|                                     |",13
    .byte       "| Game modes:                         |",13
    .byte       "|  Challenge - how far can you get?   |",13
    .byte       "|  Casual    - retry levels as many   |",13
    .byte       "|              times as you want!     |",13
    .byte       "|                                     |",13
    .byte       "| Enjoy!                              |",13
    .byte       "|             - Paul Wasson, 12/2025  |",13
    .byte       "|_____________________________________|",0
wait:
    lda         KBD
    bpl         wait
    sta         KBDSTRB
    jmp         quit
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

quit_params:
    .byte       4               ; 4 parameters
    .byte       0               ; 0 is the only quit type
    .word       0               ; Reserved pointer for future use (what future?)
    .byte       0               ; Reserved byte for future use (what future?)
    .word       0               ; Reserved pointer for future use (what future?)

.endproc

.include    "inline_print.asm"