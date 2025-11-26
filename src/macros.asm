;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Macros
;-----------------------------------------------------------------------------

; Add 0 to the end of a string
.macro  String s
    .byte   s
    .byte   0
.endmacro

; Prepend the string length
.macro  StringLen s
    .byte   .strlen(s)
    .byte   s
.endmacro

; Add CR + 0 to the end of a string
.macro  StringCR s
    .byte   s
    .byte   13,0
.endmacro

; Add CR to the end of a string
.macro  StringCont s
    .byte   s
    .byte   13
.endmacro

.macro  MapText s
    .repeat .strlen(s), I
    .byte   .strat(s, I) - $20
    .endrep
.endmacro

.macro  TileText s
    MapText s
    .byte   $FF
.endmacro

.macro QuoteText s,numY,numX
    MapText s
    .byte   $80|numY*16|numX
.endmacro

.macro  byteRep b,num
    .repeat num
    .byte   b
    .endrep
.endmacro


.macro PlaySongPtr song
    lda     #<song
    sta     stringPtr0
    lda     #>song
    sta     stringPtr1
    jsr     playSong
.endmacro

.macro ConvertSpeed     word
    .byte   ($F0 & word) | ($0F & (word >> 8))
.endmacro

.macro ConvertSpeeds    s0,s1,s2,s3,s4,s5,s6,s7
    ConvertSpeed    s0
    ConvertSpeed    s1
    ConvertSpeed    s2
    ConvertSpeed    s3
    ConvertSpeed    s4
    ConvertSpeed    s5
    ConvertSpeed    s6
    ConvertSpeed    s7
.endmacro

