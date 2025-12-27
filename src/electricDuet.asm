; Electric Duet
; (c) 1981 Paul Lutus

; Include the following text:
;
;   The two voice music in this product
;   was created using the Electric Duet
;   Music Synthesizer by Paul Lutus.
;   https://arachnoid.com/electric_duet/index.html


; Pitch Numbers :
;
; Octave 1   2   3   4   5
;
; A      255 128 064 032 016
; A#     240 120 060 030 015
; B      228 114 057 028 014
; C      216 108 054 027 013
; C#     204 102 051 025 012
; D      192 096 048 024 012
; D#     180 090 045 022 011
; E      172 086 043 021 010
; F      160 080 040 020 010
; F#     152 076 038 019 009
; G      144 072 036 018 009
; G#     136 068 034 017 008

NOTE_REST           = 000

NOTE_A1             = 255
NOTE_As1            = 240
NOTE_B1             = 228
NOTE_C1             = 216
NOTE_Cs1            = 204
NOTE_D1             = 192
NOTE_Ds1            = 180
NOTE_E1             = 172
NOTE_F1             = 160
NOTE_Fs1            = 152
NOTE_G1             = 144
NOTE_Gs1            = 136

NOTE_A2             = 128
NOTE_As2            = 120
NOTE_B2             = 114
NOTE_C2             = 108
NOTE_Cs2            = 102
NOTE_D2             = 096
NOTE_Ds2            = 090
NOTE_E2             = 086
NOTE_F2             = 080
NOTE_Fs2            = 076
NOTE_G2             = 072
NOTE_Gs2            = 068

NOTE_A3             = 064
NOTE_As3            = 060
NOTE_B3             = 057
NOTE_C3             = 054
NOTE_Cs3            = 051
NOTE_D3             = 048
NOTE_Ds3            = 045
NOTE_E3             = 043
NOTE_F3             = 040
NOTE_Fs3            = 038
NOTE_G3             = 036
NOTE_Gs3            = 034

NOTE_A4             = 032
NOTE_As4            = 030
NOTE_B4             = 028
NOTE_C4             = 027
NOTE_Cs4            = 025
NOTE_D4             = 024
NOTE_Ds4            = 022
NOTE_E4             = 021
NOTE_F4             = 020
NOTE_Fs4            = 019
NOTE_G4             = 018
NOTE_Gs4            = 017

NOTE_A5             = 016
NOTE_As5            = 015
NOTE_B5             = 014
NOTE_C5             = 013
NOTE_Cs5            = 012
NOTE_D5             = 012
NOTE_Ds5            = 011
NOTE_E5             = 010
NOTE_F5             = 010
NOTE_Fs5            = 009
NOTE_G5             = 009
NOTE_Gs5            = 008

; Duration Numbers :
;
; 1   255
; 2 . 192
; 2   128
; 4 . 096
; 4   064
; 8 . 048
; 8   032
; 16. 024
; 16  016
; 32. 012
; 32  008
; 64. 006
; 64  004
; 99. 003
; 99  002

NOTE_DONE           = 0
NOTE_VOICE          = 1
NOTE_WHOLE          = 255
NOTE_HALF_DOT       = 192
NOTE_HALF           = 128
NOTE_QUARTER_DOT    = 96
NOTE_QUARTER        = 64
NOTE_8TH_DOT        = 48
NOTE_8TH            = 32
NOTE_16TH_DOT       = 24
NOTE_16TH           = 16
NOTE_32ND_DOT       = 12
NOTE_32ND           = 8
NOTE_64TH_DOT       = 6
NOTE_64TH           = 4
NOTE_128ND_DOT      = 3
NOTE_128ND          = 2

NOTE_112            = 112       ; $70 - not standard
NOTE_56             = 56        ; $38 - not standard
NOTE_51             = 56        ; $33 - not standard
NOTE_20             = 20        ; $14 - not standard
NOTE_9              = 9         ; $09 - not standard

SONG_UNINTERRUPTIBLE = $4E
SONG_INTERRUPTIBLE   = $2C

.align 256

.proc electricDuetPlayer

ZP_06           :=  $06         ; $06 - tilePtr0
ZP_07           :=  $07         ; $07 - tilePtr1
ZP_08           :=  $08         ; $08 - tileIdx
ZP_09           :=  $09         ; $09 - tempZP
ZP_0F           :=  $0F         ; $0F - ???
ZP_1D           :=  $1D         ; $1D - curX
ZP_4E           :=  $4E         ; $4E - ??
ZP_4F           :=  $4F         ; $4F - ??

PTR             :=  $1E         ; $1E - curY
;                   $1F         ; $1F - ??

INST_EOR        =   $49
INST_CMP        =   $C9

ENTRY_SIZE      =   3
CHANGE_VOICE    =   1

                ;-- modified preamble ---
                STA     KBDSTRB         ; Strobe keyboard to cancel any late keystroke
                STA     INTERRUPT       ; BIT=2C interruptable, LSR=4E uninterruptable
                ;-- end of preamble -----

                LDA     #$01            ; 2 *!*
                STA     ZP_09           ; 3
                STA     ZP_1D           ; 3
                PHA                     ; 3
                PHA                     ; 3
                PHA                     ; 3
                BNE     BRANCH_20       ; 4 *!*
BRANCH_0B:      INY                     ; 2
                LDA     (PTR),Y         ; 5 *!*
                STA     ZP_09           ; 3
                INY                     ; 2
                LDA     (PTR),Y         ; 5 *!*
                STA     ZP_1D           ; 3
BRANCH_15:      LDA     PTR             ; 3 *!*
                CLC                     ; 2
                ADC     #ENTRY_SIZE     ; 2 *!*
                STA     PTR             ; 3
                BCC     BRANCH_20       ; 4 *!*
                INC     PTR+1           ; 5
BRANCH_20:      LDY     #$00            ; 2 *!*
                LDA     (PTR),Y         ; 5 *!*
                CMP     #CHANGE_VOICE   ; 2
                BEQ     BRANCH_0B       ; 4 *!*
                BCS     BRANCH_37       ; 4 *!*
                PLA                     ; 4
                PLA                     ; 4
                PLA                     ; 4
BRANCH_2D:      LDX     #INST_EOR       ; 2 *!*
                INY                     ; 2
                LDA     (PTR),Y         ; 5 *!*
                BNE     BRANCH_36       ; 4 *!*
                LDX     #INST_CMP       ; 2 *!*
BRANCH_36:      RTS                     ; 6
BRANCH_37:      STA     $08             ; 3
                JSR     BRANCH_2D       ; 6
                STX     BRANCH_83       ; 4
                STA     ZP_06           ; 3
                LDX     ZP_09           ; 3 *!*
BRANCH_43:      LSR                     ; 2
                DEX                     ; 2
                BNE     BRANCH_43       ; 4 *!*
                STA     BRANCH_7B+1     ; 4
                JSR     BRANCH_2D       ; 6
                STX     BRANCH_BB       ; 4
                STA     ZP_07           ; 3
                LDX     ZP_1D           ; 3 *!*
BRANCH_54:      LSR                     ; 2
                DEX                     ; 2
                BNE     BRANCH_54       ; 4 *!*
                STA     BRANCH_B3+1     ; 4
                PLA                     ; 4
                TAY                     ; 2
                PLA                     ; 4
                TAX                     ; 2
                PLA                     ; 4
                BNE     BRANCH_65       ; 4 *!*
BRANCH_62:      BIT     SPEAKER         ; 4
BRANCH_65:      CMP     #$00            ; 2
                BMI     BRANCH_6C       ; 4 *!*
                NOP                     ; 2
                BPL     BRANCH_6F       ; 4 *!*
BRANCH_6C:      BIT     SPEAKER         ; 4
BRANCH_6F:      STA     ZP_4E           ; 3
INTERRUPT:      BIT     KBD             ; 4
                BMI     BRANCH_36       ; 4 *!*
                DEY                     ; 2
                BNE     BRANCH_7B       ; 4 *!*
                BEQ     BRANCH_81       ; 4 *!*
BRANCH_7B:      CPY     #$00            ; 2
                BEQ     BRANCH_83       ; 4 *!*
                BNE     BRANCH_85       ; 4 *!*
BRANCH_81:      LDY     ZP_06           ; 3 *!*
BRANCH_83:      EOR     #$40            ; 2 *!*
BRANCH_85:      BIT     ZP_4E           ; 3
                BVC     BRANCH_90       ; 4 *!*
                BVS     BRANCH_8B       ; 4 *!*
BRANCH_8B:      BPL     BRANCH_96       ; 4 *!*
                NOP                     ; 2
                BMI     BRANCH_99       ; 4 *!*
BRANCH_90:      NOP                     ; 2
                BMI     BRANCH_96       ; 4 *!*
                NOP                     ; 2
                BPL     BRANCH_99       ; 4 *!*
BRANCH_96:      CMP     SPEAKER         ; 4
BRANCH_99:      DEC     ZP_4F           ; 5
                BNE     BRANCH_AE       ; 4 *!*
                DEC     ZP_08           ; 5
                BNE     BRANCH_AE       ; 4 *!*
                BVC     BRANCH_A6       ; 4 *!*
                BIT     SPEAKER         ; 4
BRANCH_A6:      PHA                     ; 3
                TXA                     ; 2
                PHA                     ; 3
                TYA                     ; 2
                PHA                     ; 3
                JMP     BRANCH_15       ; 3
BRANCH_AE:      DEX                     ; 2
                BNE     BRANCH_B3       ; 4 *!*
                BEQ     BRANCH_B9       ; 4 *!*
BRANCH_B3:      CPX     #$00            ; 2
                BEQ     BRANCH_BB       ; 4 *!*
                BNE     BRANCH_BD       ; 4 *!*
BRANCH_B9:      LDX     ZP_07           ; 3 *!*
BRANCH_BB:      EOR     #$80            ; 2 *!*
BRANCH_BD:      BVS     BRANCH_62       ; 4 *!*
                NOP                     ; 2
                BVC     BRANCH_65       ; 4 *!*
.endproc

.align 256

peasantSong:
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_8TH, $24, $48
    .byte       NOTE_9, $26, $4C
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $26, $4C
    .byte       NOTE_16TH_DOT, $18, $30
    .byte       NOTE_8TH, $19, $33
    .byte       NOTE_9, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, $1C, NOTE_REST
    .byte       NOTE_16TH_DOT, $2B, $39
    .byte       NOTE_16TH_DOT, $26, $40
    .byte       NOTE_16TH_DOT, $24, $48
    .byte       NOTE_16TH_DOT, $1C, $4C
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_32ND_DOT, NOTE_A4, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $60
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $C0
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_20, $26, $C0
    .byte       NOTE_128ND, NOTE_REST, $C0
    .byte       NOTE_16TH_DOT, $26, NOTE_REST
    .byte       NOTE_16TH_DOT, $18, $72
    .byte       NOTE_16TH_DOT, $19, $66
    .byte       NOTE_16TH_DOT, $1C, $60
    .byte       NOTE_32ND_DOT, $1C, $72
    .byte       NOTE_9, NOTE_A4, $72
    .byte       NOTE_128ND, NOTE_REST, $72
    .byte       NOTE_8TH, NOTE_A4, $33
    .byte       NOTE_9, $22, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $22, $39
    .byte       NOTE_16TH_DOT, $2B, $30
    .byte       NOTE_16TH_DOT, $19, $33
    .byte       NOTE_16TH_DOT, $1C, $30
    .byte       NOTE_16TH_DOT, NOTE_A4, $33
    .byte       NOTE_32ND_DOT, NOTE_A4, $39
    .byte       NOTE_9, $22, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_8TH, $22, $39
    .byte       NOTE_9, $26, $39
    .byte       NOTE_128ND, NOTE_REST, $39
    .byte       NOTE_16TH_DOT, $26, $40
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $60
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_8TH_DOT, $2B, $80
    .byte       NOTE_16TH_DOT, $2B, NOTE_A1
    .byte       NOTE_16TH_DOT, $24, NOTE_A1
    .byte       NOTE_56, $26, $C0
    .byte       NOTE_32ND_DOT, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_8TH, $24, $48
    .byte       NOTE_9, $26, $4C
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $26, $4C
    .byte       NOTE_16TH_DOT, $18, $30
    .byte       NOTE_8TH, $19, $33
    .byte       NOTE_9, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, $1C, NOTE_REST
    .byte       NOTE_16TH_DOT, $2B, $39
    .byte       NOTE_16TH_DOT, $26, $40
    .byte       NOTE_16TH_DOT, $24, $48
    .byte       NOTE_16TH_DOT, $1C, $4C
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_32ND_DOT, NOTE_A4, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $60
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $C0
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_20, $26, $C0
    .byte       NOTE_128ND, NOTE_REST, $C0
    .byte       NOTE_16TH_DOT, $26, NOTE_REST
    .byte       NOTE_16TH_DOT, $18, $72
    .byte       NOTE_16TH_DOT, $19, $66
    .byte       NOTE_16TH_DOT, $1C, $60
    .byte       NOTE_32ND_DOT, $1C, $72
    .byte       NOTE_9, NOTE_A4, $72
    .byte       NOTE_128ND, NOTE_REST, $72
    .byte       NOTE_8TH, NOTE_A4, $33
    .byte       NOTE_9, $22, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $22, $39
    .byte       NOTE_16TH_DOT, $2B, $30
    .byte       NOTE_16TH_DOT, $19, $33
    .byte       NOTE_16TH_DOT, $1C, $30
    .byte       NOTE_16TH_DOT, NOTE_A4, $33
    .byte       NOTE_32ND_DOT, NOTE_A4, $39
    .byte       NOTE_9, $22, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_8TH, $22, $39
    .byte       NOTE_9, $26, $39
    .byte       NOTE_128ND, NOTE_REST, $39
    .byte       NOTE_16TH_DOT, $26, $40
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $60
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_8TH_DOT, $2B, $80
    .byte       NOTE_16TH_DOT, $2B, NOTE_A1
    .byte       NOTE_16TH_DOT, $24, NOTE_A1
    .byte       NOTE_56, $26, $C0
    .byte       NOTE_32ND_DOT, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_8TH, $24, $48
    .byte       NOTE_9, $26, $4C
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $26, $4C
    .byte       NOTE_16TH_DOT, $18, $30
    .byte       NOTE_8TH, $19, $33
    .byte       NOTE_9, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, $1C, $39
    .byte       NOTE_128ND, $1C, NOTE_REST
    .byte       NOTE_16TH_DOT, $2B, $39
    .byte       NOTE_16TH_DOT, $26, $40
    .byte       NOTE_16TH_DOT, $24, $48
    .byte       NOTE_16TH_DOT, $1C, $4C
    .byte       NOTE_16TH_DOT, NOTE_A4, $40
    .byte       NOTE_32ND_DOT, NOTE_A4, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_20, $26, $60
    .byte       NOTE_128ND, NOTE_REST, $60
    .byte       NOTE_16TH_DOT, $26, $3C
    .byte       NOTE_16TH_DOT, $18, $72
    .byte       NOTE_16TH_DOT, $19, $66
    .byte       NOTE_16TH_DOT, $1C, $60
    .byte       NOTE_32ND_DOT, $1C, $72
    .byte       NOTE_9, NOTE_A4, $72
    .byte       NOTE_128ND, NOTE_REST, $72
    .byte       NOTE_8TH, NOTE_A4, $33
    .byte       NOTE_9, $22, $39
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_16TH_DOT, $22, $39
    .byte       NOTE_16TH_DOT, $1C, $44
    .byte       NOTE_20, $15, $40
    .byte       NOTE_128ND, $15, NOTE_REST
    .byte       NOTE_20, $18, $40
    .byte       NOTE_128ND, $18, NOTE_REST
    .byte       NOTE_16TH_DOT, $19, $40
    .byte       NOTE_32ND_DOT, $19, $30
    .byte       NOTE_9, $1C, $30
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_8TH, $1C, $30
    .byte       NOTE_9, NOTE_A4, $33
    .byte       NOTE_128ND, NOTE_REST, NOTE_REST
    .byte       NOTE_20, NOTE_A4, $33
    .byte       NOTE_128ND, NOTE_REST, $33
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $C0
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_16TH_DOT, $2B, $90
    .byte       NOTE_32ND_DOT, $2B, $80
    .byte       NOTE_32ND_DOT, $24, $80
    .byte       NOTE_16TH_DOT, $26, $C0
    .byte       NOTE_16TH_DOT, NOTE_A4, $98
    .byte       NOTE_56, $2B, $80
    .byte       NOTE_8TH, $2B, NOTE_A1
    .byte       NOTE_51, $24, NOTE_A1
    .byte       NOTE_112, $26, $C0
    .byte       NOTE_DONE, NOTE_A1, NOTE_A1
