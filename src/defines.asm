;-----------------------------------------------------------------------------
; Paul Wasson - 2024
;-----------------------------------------------------------------------------
; Predefined memory/ROM locations
;
; Mostly added as needed
; Tried to use standard names if known
;-----------------------------------------------------------------------------

; Grab ca65 defines to start with and then add missing ones
.include "apple2.inc"


; Zero Page
;---------------------------------------------------------
; Safe zero page locations from Inside the Apple IIe (table 2-5):
;
;                         $06 $07 
; $08 $09
;     $19 $1A $1B $1C $1D $1E
;                         $CE $CF
;                             $D7
;             $E3
;             $EB $EC $ED $EE $EF
;         $FA $FB $FC $FD $FE $FF

; ROM defined
;-------------
A1              :=  $3c
A2              :=  $3e
A4              :=  $42

; User defined
;--------------
; Pointers
tilePtr0        :=  $06     ; Tile pointer
tilePtr1        :=  $07
maskPtr0        :=  $19     ; mask pointer
maskPtr1        :=  $1a
screenPtr0      :=  $1b     ; Screen pointer
screenPtr1      :=  $1c
scriptPtr0 		:=  $fa
scriptPtr1 		:=  $fb
stringPtr0      :=  $fe
stringPtr1      :=  $ff
mapPtr0 		:=  $ec
mapPtr1 		:=  $ed

; Indexes
tileIdx         :=  $08
tileX           :=  $e3
tileY           :=  $eb

; Controls
drawPage        :=  $d7
curX		    :=  $1d
curY 		    :=  $1e

; Temp
tempZP 			:=  $09

; Color
colorEven 		:=  $ce
colorOdd 		:=  $cf
invertTile 		:= 	$ee

; following are available to use
;               :=  $ef
;               :=  $fc
;               :=  $fd



; Memory map
;---------------------------------------------------------
FILEBUFFER      := $800     ; User PRODOS filebuffer, 512 bytes
HGRPAGE1        := $2000
HGRPAGE2        := $4000

; Soft switches
;---------------------------------------------------------
RAMRDOFF        := $C002    ; read main memory  $200 - $BFFF
RAMRDON         := $C003    ; read aux memory   $200 - $BFFF
RAMWRTOFF       := $C004    ; write main memory $200 - $BFFF
RAMWRTON        := $C005    ; write aux memory  $200 - $BFFF
CLR80VID        := $C00C
SET80VID        := $C00D
SPEAKER         := $C030
TEXTMODE        := $C01A    ; Bit 7 is 1 if text mode
MIXED   		:= $C01B 	; Bit 7 is 1 if mixed mode
PAGE2           := $C01C    ; Bit 7 set if displaying page 2
HIRESMODE   	:= $C01D    ; Bit 7 is 1 if HiRes
ALTCHARSETOFF   := $C00E    ; Write to turn off alternate characters
ALTCHARSETON    := $C00F    ; Write to turn on alternate characters
BUTTON0         := $C061    ; Bit 7 set if paddle button 0 is pressed
BUTTON1         := $C062    ; Bit 7 set if paddle button 1 is pressed
BUTTON2         := $C063    ; Bit 7 set if paddle button 2 is pressed

; 2GS
NEWVIDEO        := $C029 	; New Video: 129=SHR, 1=None, Bit 6=Linearize, Bit 5=BW
CLOCKCTL        := $C034    ; b0-3=borderColor b5=stopBit b6=read b7=start

; ROM routines
;---------------------------------------------------------
AUXMOVE         := $C311    ; Aux memory copy
GR              := $F390    ; Low-res mixed graphics mode
TEXT            := $F399    ; Text-mode
HGR             := $F3E2    ; Turn on hi-res mode, page 1 mixed mode, clear    
HGR2            := $F3D8    ; Turn on hi-res mode, page 2, clear
PRBYTE          := $FDDA    ; Print A as a 2-digit hex
PRINTXY         := $F940    ; Print X(low) Y(high) as 4-digit hex
VTAB            := $FC22    ; Move the cursor to line CV
HOME            := $FC58    ; Clear text screen
CR              := $FC62    ; Output carriage return
RDKEY           := $FD0C    ; Read 1 char
GETLN           := $FD6A    ; Read a line of characters
COUT            := $FDED    ; Output a character
MON             := $FF65    ; Enter monitor (BRK)
MONZ            := $FF69    ; Enter monitor
WAIT            := $FCA8    ; Wait 0.5*(26 + 27*A + 5*A*A) microseconds
PREAD           := $FB1E    ; Read paddle X (0=hor,1=vert on joystick), result in Y

; PRODOS
;---------------------------------------------------------
MLI             := $BF00    ; PRODOS MLI call
CMD_QUIT        = $65
CMD_CREATE      = $C0
CMD_OPEN        = $C8
CMD_READ        = $CA
CMD_WRITE       = $CB
CMD_CLOSE       = $CC

; Keyboard
;---------------------------------------------------------
KEY_CTRL_A      = $81
KEY_CTRL_B      = $82
KEY_CTRL_C      = $83
KEY_CTRL_D      = $84
KEY_CTRL_E      = $85
KEY_CTRL_F      = $86
KEY_LEFT        = $88       ; CTRL_H
KEY_TAB         = $89       ; CTRL_I
KEY_DOWN        = $8A       ; CTRL_J
KEY_UP          = $8B       ; CTRL_K
KEY_CTRL_L      = $8C
KEY_RETURN      = $8D       ; CTRL_M
KEY_CTRL_O      = $8F
KEY_CTRL_P      = $90
KEY_CTRL_Q      = $91
KEY_CTRL_R      = $92
KEY_CTRL_S      = $93
KEY_CTRL_T      = $94
KEY_RIGHT       = $95       ; CTRL_U
KEY_CTRL_V      = $96
KEY_CTRL_W      = $97
KEY_CTRL_X      = $98
KEY_CTRL_Y      = $99
KEY_CTRL_Z      = $9A
KEY_ESC         = $9B
KEY_SPACE       = $A0
KEY_ASTERISK    = $AA
KEY_0           = $B0
KEY_1           = $B1
KEY_2           = $B2
KEY_3           = $B3
KEY_4           = $B4
KEY_5           = $B5
KEY_6           = $B6
KEY_7           = $B7
KEY_8           = $B8
KEY_9           = $B9
KEY_QUESTION 	= $BF
KEY_A           = $C1
KEY_B           = $C2
KEY_C           = $C3
KEY_D           = $C4
KEY_E           = $C5
KEY_F           = $C6
KEY_G           = $C7
KEY_H           = $C8
KEY_I           = $C9
KEY_J           = $CA
KEY_K           = $CB
KEY_L           = $CC
KEY_M           = $CD
KEY_N           = $CE
KEY_O           = $CF
KEY_P           = $D0
KEY_Q           = $D1
KEY_R           = $D2
KEY_S           = $D3
KEY_T           = $D4
KEY_U           = $D5
KEY_V           = $D6
KEY_W           = $D7
KEY_X           = $D8
KEY_Y           = $D9
KEY_Z           = $DA
KEY_DEL         = $FF

; DHGR Engine
;---------------------------------------------------------

DHGR_LOADER                 := $C00
DHGR_ENGINE_INIT            := $C03
DHGR_DRAW_7X8               := $C06
DHGR_DRAW_28X8              := $C09
DHGR_DRAW_MASK_28X8         := $C0C
DHGR_DRAW_BG_28X8           := $C0F
DHGR_DRAW_PIXEL_4X4         := $C12
DHGR_SCROLL_LINE            := $C15
DHGR_GET_PIXEL_MASK_28X8    := $C18
DHGR_SET_PIXEL_28X8         := $C1B
DHGR_SET_MASK_28X8          := $C1E
DHGR_DUMP_INIT              := $C21
DHGR_DUMP_BYTE              := $C24
DHGR_SET_BYTE               := $C27
DHGR_CLEAR_SCREEN           := $C2A
DHGR_READ_SCRIPT_BYTE       := $C2D
DHGR_READ_STRING_BYTE       := $C30
DHGR_DRAW_IMAGE             := $C33
DHGR_DRAW_IMAGE_AUX         := $C36
DHGR_DRAW_STRING            := $C39
DHGR_DRAW_STRING_INLINE     := $C3C
DHGR_LOADER_MENU            := $C3F
DHGR_LOAD_ASSET             := $C42
DHGR_STORE_ASSET            := $C45

DHGR_TILE_7X8               := $C60
DHGR_TILE_28X8              := $C62
DHGR_IMAGE_WIDTH            := $C64
DHGR_IMAGE_HEIGHT           := $C65
DHGR_IMAGE_X                := $C66
DHGR_IMAGE_Y                := $C67
DHGR_IMAGE_TABLE            := $C68

DHGR_LINE_OFFSET 			:= $C80
DHGR_LINE_PAGE 				:= $C98

