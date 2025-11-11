;-----------------------------------------------------------------------------
; Paul Wasson - 2025
;-----------------------------------------------------------------------------
; Player shapes in 256 bytes (index absolute addressing mode)
;-----------------------------------------------------------------------------

.align 256
playerShapes:

.byte $00,$00,$03,$60,$33,$66,$73,$67,$7C,$1F,$7C,$1F,$70,$07,$70,$07   ;00 - Frog black up1
.byte $0F,$78,$30,$06,$30,$1E,$0C,$18,$0F,$78,$4F,$79,$7C,$1F,$70,$07   ;10 - Frog black down1
.byte $2A,$55,$2B,$75,$3B,$77,$7B,$77,$7E,$5F,$7E,$5F,$7A,$57,$7A,$57   ;20 - Frog green up1
.byte $2F,$7D,$3A,$57,$3A,$5F,$2E,$5D,$2F,$7D,$6F,$7D,$7E,$5F,$7A,$57   ;30 - Frog green down1
.byte $AA,$D5,$AB,$F5,$BB,$F7,$FB,$F7,$FE,$DF,$FE,$DF,$FA,$D7,$FA,$D7   ;40 - Frog orange up1
.byte $AF,$FD,$BA,$D7,$BA,$DF,$AE,$DD,$AF,$FD,$EF,$FD,$FE,$DF,$FA,$D7   ;50 - Frog orange down1
.byte $30,$06,$4C,$19,$7C,$1F,$03,$60,$7F,$7F,$7F,$7F,$7C,$1F,$0F,$78   ;60 - Frog black idle
.byte $0F,$78,$3F,$7E,$7C,$1F,$70,$07,$70,$07,$7C,$1F,$3F,$7E,$0F,$78   ;70 - Frog black dead

.byte $70,$07,$7C,$1F,$4F,$79,$0F,$78,$0C,$18,$30,$1E,$30,$06,$0F,$78   ;80 - Frog black up2
.byte $70,$07,$70,$07,$7C,$1F,$7C,$1F,$73,$67,$33,$66,$03,$60,$00,$00   ;90 - Frog black down2
.byte $7A,$57,$7E,$5F,$6F,$7D,$2F,$7D,$2E,$5D,$3A,$5F,$3A,$57,$2F,$7D   ;A0 - Frog green up2
.byte $7A,$57,$7A,$57,$7E,$5F,$7E,$5F,$7B,$77,$3B,$77,$2B,$75,$2A,$55   ;B0 - Frog green down2
.byte $FA,$D7,$FE,$DF,$EF,$FD,$AF,$FD,$AE,$DD,$BA,$DF,$BA,$D7,$AF,$FD   ;C0 - Frog orange up2
.byte $FA,$D7,$FA,$D7,$FE,$DF,$FE,$DF,$FB,$F7,$BB,$F7,$AB,$F5,$AA,$D5   ;D0 - Frog orange down2
.byte $3A,$57,$4E,$59,$7E,$5F,$03,$60,$7F,$7F,$7F,$7F,$7E,$5F,$2F,$7D   ;E0 - Frog green idle
.byte $2F,$7D,$3F,$7F,$7E,$5F,$7A,$57,$7A,$57,$7E,$5F,$3F,$7F,$2F,$7D   ;F0 - Frog green dead