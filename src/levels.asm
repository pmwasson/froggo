;-----------------------------------------------------------------------------
; Paul Wasson - 2025
;-----------------------------------------------------------------------------
; Level Data
;-----------------------------------------------------------------------------

; Each level is 32 bytes in AUX memory consisting of
;   size(bytes)     description
;   -----------     --------------------------
;   20              column indexes
;   8               dynamic column speeds
;   4               padding
;
; This gets expanded with some redundancy to main memory as
;   20*16           tiles for display
;   18*14           tiles for static collisions
;   8*16            tiles for dynamic collisions
;   20              column types
;   16              column speeds -- expanded by original 2 nibbles to 2 bytes
;   16              column offsets -- always reset to zero
; 
; Each level is 20 columns, with 16 tiles in each column 16 (20*16 = 320 tile total)
; There is a maximum of 8 dynamic columns, each of which has a type (1 byte), speed (2 bytes)

.align 32
level0:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0                                            ; 4
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_0,COLUMN_ROAD_D_3,COLUMN_ROAD_GRASS_0         ; 6
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_WATER_0                                                                         ; 2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0,COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_0                                                                               ; 2
    ; dynamic speeds
    ConvertSpeeds   $0180, $FF10, $00B0, $0150, $0040, $FF30, $0020, $0090
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*2

.align 32
level1:         ; grass--water--grass--water--grass
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_4,COLUMN_GRASS_WATER_0,COLUMN_WATER_S_2                                         ; 4
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0,COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_WATER_0                                                                         ; 2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_1,COLUMN_WATER_D_4,COLUMN_WATER_S_2       ; 6
    .byte       COLUMN_WATER_GRASS_0,COLUMN_GRASS_0                                                                         ; 2
    ; dynamic speeds
    ConvertSpeeds   $0080, $FF10, $00A0, $0130, $FF50, $FF30, $0040, $FF40
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8

.align 32
level2:         ; grass--road--grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_5,COLUMN_GRASS_6,COLUMN_GRASS_ROAD_1                                                           ; 3
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_S_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_1,COLUMN_ROAD_D_0,COLUMN_ROAD_S_1             ; 6
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_GRASS_1,COLUMN_GRASS_6                                                          ; 3
    .byte       COLUMN_GRASS_ROAD_1,COLUMN_ROAD_D_0,COLUMN_ROAD_S_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_1,COLUMN_ROAD_D_3         ; 6
    .byte       COLUMN_ROAD_GRASS_1,COLUMN_GRASS_6                                                                          ; 2
    ; dynamic speeds
    ConvertSpeeds   $0280, $FD40, $01C0, $FD00, $01F0, $0190, $01F0, $0000
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8

.align 32
level3:         ; building
    ; columns
    .byte       COLUMN_HOUSE_0,COLUMN_HOUSE_0,COLUMN_HOUSE_3                                                                ; 3
    .byte       COLUMN_HOUSE_1,COLUMN_HOUSE_2,COLUMN_HOUSE_4,COLUMN_HOUSE_D_0,COLUMN_HOUSE_4,COLUMN_HOUSE_4,COLUMN_HOUSE_D_0  ; 7
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_5,COLUMN_HOUSE_5,COLUMN_HOUSE_D_0,COLUMN_HOUSE_5,COLUMN_HOUSE_6,COLUMN_HOUSE_2  ; 7
    .byte       COLUMN_HOUSE_3,COLUMN_HOUSE_0,COLUMN_HOUSE_0                                                                ; 3
    ; dynamic speeds
    ConvertSpeeds   $00C0, $0080, $FF80, $FF40, $0010, $0010, $0010, $0010
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8

.align 32
level4:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_WATER_1                                           ; 4
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_D_2,COLUMN_WATER_S_2,COLUMN_WATER_D_1,COLUMN_WATER_D_0,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0                                                                          ; 2
    .byte       COLUMN_ROAD_D_5,COLUMN_ROAD_D_4,COLUMN_ROAD_D_4,COLUMN_ROAD_D_4,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_3          ; 6
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_0                                                                               ; 2
    ; dynamic speeds
    ConvertSpeeds   $0060, $FF50, $00A0, $0090, $FEB0, $FF20, $FF60, $FF30
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*4

.align 32
level5:         ; bricks--road--bricks
    ; columns
    .byte       COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1             ; 4
    .byte       COLUMN_BRICK_0,COLUMN_GRASS_ROAD_2                                      ; 2
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_5,COLUMN_ROAD_D_2,COLUMN_ROAD_D_0         ; 4
    .byte       COLUMN_ROAD_D_5,COLUMN_ROAD_D_1,COLUMN_ROAD_D_5,COLUMN_ROAD_D_2         ; 4
    .byte       COLUMN_ROAD_GRASS_2,COLUMN_BRICK_0                                      ; 2
    .byte       COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0             ; 4
    ; dynamic speeds
    ConvertSpeeds   $0060, $FF50, $00A0, $0090, $FF30, $FF20, $FF60, $00D0
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*4

.align 32
level6:         ; grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_4,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0                    ; 4
    .byte       COLUMN_ROAD_D_6,COLUMN_ROAD_S_4,COLUMN_ROAD_D_1,COLUMN_ROAD_D_2                     ; 4
    .byte       COLUMN_ROAD_S_4,COLUMN_ROAD_D_2,COLUMN_ROAD_S_3                                     ; 3
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_S_4,COLUMN_ROAD_D_7,COLUMN_ROAD_S_4                     ; 4
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_D_6                                                     ; 2
    .byte       COLUMN_ROAD_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_4                                   ; 3
    ; dynamic speeds
    ConvertSpeeds   $FEC0, $FEB0, $FEF0, $FF00, $0140, $0100, $0120, $0110
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8


COLUMN_TYPE_STATIC          = $00
COLUMN_TYPE_DYNAMIC         = $80           ; $80..$87

COLUMN_GRASS_0              = (levelColumnDataG0  - levelColumnData)/16
COLUMN_GRASS_1              = (levelColumnDataG1  - levelColumnData)/16
COLUMN_GRASS_2              = (levelColumnDataG2  - levelColumnData)/16
COLUMN_GRASS_3              = (levelColumnDataG3  - levelColumnData)/16
COLUMN_GRASS_4              = (levelColumnDataG4  - levelColumnData)/16
COLUMN_GRASS_5              = (levelColumnDataG5  - levelColumnData)/16
COLUMN_GRASS_6              = (levelColumnDataG6  - levelColumnData)/16
COLUMN_GRASS_ROAD_0         = (levelColumnDataGR0 - levelColumnData)/16
COLUMN_GRASS_ROAD_1         = (levelColumnDataGR1 - levelColumnData)/16
COLUMN_GRASS_ROAD_2         = (levelColumnDataGR2 - levelColumnData)/16
COLUMN_ROAD_GRASS_0         = (levelColumnDataRG0 - levelColumnData)/16
COLUMN_ROAD_GRASS_1         = (levelColumnDataRG1 - levelColumnData)/16
COLUMN_ROAD_GRASS_2         = (levelColumnDataRG2 - levelColumnData)/16
COLUMN_GRASS_WATER_0        = (levelColumnDataGW0 - levelColumnData)/16
COLUMN_GRASS_WATER_1        = (levelColumnDataGW1 - levelColumnData)/16
COLUMN_WATER_GRASS_0        = (levelColumnDataWG0 - levelColumnData)/16
COLUMN_ROAD_S_0             = (levelColumnDataRS0 - levelColumnData)/16
COLUMN_ROAD_S_1             = (levelColumnDataRS1 - levelColumnData)/16
COLUMN_ROAD_S_2             = (levelColumnDataRS2 - levelColumnData)/16
COLUMN_ROAD_S_3             = (levelColumnDataRS3 - levelColumnData)/16
COLUMN_ROAD_S_4             = (levelColumnDataRS4 - levelColumnData)/16
COLUMN_ROAD_D_0             = (levelColumnDataRD0 - levelColumnData)/16
COLUMN_ROAD_D_1             = (levelColumnDataRD1 - levelColumnData)/16
COLUMN_ROAD_D_2             = (levelColumnDataRD2 - levelColumnData)/16
COLUMN_ROAD_D_3             = (levelColumnDataRD3 - levelColumnData)/16
COLUMN_ROAD_D_4             = (levelColumnDataRD4 - levelColumnData)/16
COLUMN_ROAD_D_5             = (levelColumnDataRD5 - levelColumnData)/16
COLUMN_ROAD_D_6             = (levelColumnDataRD6 - levelColumnData)/16
COLUMN_ROAD_D_7             = (levelColumnDataRD7 - levelColumnData)/16
COLUMN_TRAIN_D_0            = (levelColumnDataTD0 - levelColumnData)/16
COLUMN_WATER_S_0            = (levelColumnDataWS0 - levelColumnData)/16
COLUMN_WATER_S_1            = (levelColumnDataWS1 - levelColumnData)/16
COLUMN_WATER_S_2            = (levelColumnDataWS2 - levelColumnData)/16
COLUMN_WATER_D_0            = (levelColumnDataWD0 - levelColumnData)/16
COLUMN_WATER_D_1            = (levelColumnDataWD1 - levelColumnData)/16
COLUMN_WATER_D_2            = (levelColumnDataWD2 - levelColumnData)/16
COLUMN_WATER_D_3            = (levelColumnDataWD3 - levelColumnData)/16
COLUMN_WATER_D_4            = (levelColumnDataWD4 - levelColumnData)/16
COLUMN_HOUSE_0              = (levelColumnDataH0  - levelColumnData)/16
COLUMN_HOUSE_1              = (levelColumnDataH1  - levelColumnData)/16
COLUMN_HOUSE_2              = (levelColumnDataH2  - levelColumnData)/16
COLUMN_HOUSE_3              = (levelColumnDataH3  - levelColumnData)/16
COLUMN_HOUSE_4              = (levelColumnDataH4  - levelColumnData)/16
COLUMN_HOUSE_5              = (levelColumnDataH5  - levelColumnData)/16
COLUMN_HOUSE_6              = (levelColumnDataH6  - levelColumnData)/16
COLUMN_HOUSE_D_0            = (levelColumnDataHD0 - levelColumnData)/16
COLUMN_BRICK_0              = (levelColumnDataB0  - levelColumnData)/16
COLUMN_BRICK_1              = (levelColumnDataB1  - levelColumnData)/16

levelColumnInfo:
; grass
    .byte       COLUMN_TYPE_STATIC                              ; grass - empty
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 2 trees near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - 3 trees near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - crosswalk in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - sidewalk in middle

; grass2road
    .byte       COLUMN_TYPE_STATIC                              ; 1 bush near bottom
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk (bottom)

; road2grass
    .byte       COLUMN_TYPE_STATIC                              ; empty
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk (bottom)

; grass2water
    .byte       COLUMN_TYPE_STATIC                              ; several bushes
    .byte       COLUMN_TYPE_STATIC                              ; all clear

; water2grass
    .byte       COLUMN_TYPE_STATIC                              ; 2 trees on top

; road (static)
    .byte       COLUMN_TYPE_STATIC                              ; road - cones
    .byte       COLUMN_TYPE_STATIC                              ; road - crosswalk in middle
    .byte       COLUMN_TYPE_STATIC                              ; road - blank
    .byte       COLUMN_TYPE_STATIC                              ; road - solid line
    .byte       COLUMN_TYPE_STATIC                              ; road - striped line

; road (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small cars (blue, purple, blue)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 medium cars and a truck (down)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small cars (red, red, blue)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 trucks (up together)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 trucks (down, spread out)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 truck (down)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 small car (red)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 small car (purple)

; train (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; train cars

; water (static)
    .byte       COLUMN_TYPE_STATIC                              ; rocks in middle
    .byte       COLUMN_TYPE_STATIC                              ; rocks spread out
    .byte       COLUMN_TYPE_STATIC                              ; rocks matching shore (pair with r2g0)

; water (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 medium log (11 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small log (8 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 small log

; house
    .byte       COLUMN_TYPE_STATIC                              ; entry
    .byte       COLUMN_TYPE_STATIC                              ; left side
    .byte       COLUMN_TYPE_STATIC                              ; middle
    .byte       COLUMN_TYPE_STATIC                              ; exit
    .byte       COLUMN_TYPE_STATIC                              ; open at top
    .byte       COLUMN_TYPE_STATIC                              ; open at bottom
    .byte       COLUMN_TYPE_STATIC                              ; middle (adjust carpet)

; house (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; conveyor belt

; brick
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk (crosswalk)
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk (blank)

.align 256
levelColumnData:
; grass
levelColumnDataG0:
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG1:
    .byte   TILE_GRASS,TILE_TREE_A,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG2:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG3:
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
    .byte   TILE_TREE_A,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG4:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG5:
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS_S,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_GRASS_N,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataG6:
    .byte   TILE_GRASS,TILE_FLOWER,TILE_GRASS,TILE_GRASS,TILE_GRASS_S,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_GRASS_N,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS

; grass2road
levelColumnDataGR0:
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD
levelColumnDataGR1:
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_SE,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_GRASS_NE,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD
levelColumnDataGR2:
    .byte   TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_BUSH_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD
    .byte   TILE_BUSH_ROAD,TILE_GRASS_SE,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_GRASS_NE

; road2grass
levelColumnDataRG0:
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS
levelColumnDataRG1:
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_GRASS_SW,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_GRASS_NW,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS
levelColumnDataRG2:
    .byte   TILE_ROAD_GRASS,TILE_ROAD_BUSH,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_BUSH,TILE_ROAD_BUSH,TILE_ROAD_GRASS,TILE_ROAD_GRASS
    .byte   TILE_ROAD_BUSH,TILE_GRASS_SW,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_GRASS_NW

; grass2water
levelColumnDataGW0:
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER

levelColumnDataGW1:
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER

; water2grass
levelColumnDataWG0:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_B,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS
    .byte   TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS

; road (static)
levelColumnDataRS0:
    .byte   TILE_CONE,TILE_CONE,TILE_CONE,TILE_ROAD,TILE_ROAD,TILE_CONE,TILE_CONE,TILE_ROAD
    .byte   TILE_ROAD,TILE_CONE,TILE_CONE,TILE_ROAD,TILE_ROAD,TILE_CONE,TILE_CONE,TILE_CONE
levelColumnDataRS1:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRS2:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRS3:
    .byte   TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE
    .byte   TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE,TILE_DOUBLE_LINE
levelColumnDataRS4:
    .byte   TILE_ROAD,TILE_SINGLE_LINE,TILE_ROAD,TILE_ROAD,TILE_SINGLE_LINE,TILE_ROAD,TILE_ROAD,TILE_SINGLE_LINE
    .byte   TILE_ROAD,TILE_ROAD,TILE_SINGLE_LINE,TILE_ROAD,TILE_ROAD,TILE_SINGLE_LINE,TILE_ROAD,TILE_ROAD

; road (dynamic)
levelColumnDataRD0:
    .byte   TILE_CAR1_BLUE,TILE_ROAD,TILE_CAR1_PURPLE,TILE_ROAD,TILE_CAR1_BLUE,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD1:
    .byte   TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_TRUCKD_A,TILE_TRUCKD_B
    .byte   TILE_TRUCKD_C,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD2:
    .byte   TILE_CAR1_RED,TILE_ROAD,TILE_CAR1_RED,TILE_ROAD,TILE_CAR1_BLUE,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD3:
    .byte   TILE_TRUCKU_A,TILE_TRUCKU_B,TILE_TRUCKU_C,TILE_ROAD,TILE_TRUCKU_A,TILE_TRUCKU_B,TILE_TRUCKU_C,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD4:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_TRUCKD_A,TILE_TRUCKD_B,TILE_TRUCKD_C,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_TRUCKD_A,TILE_TRUCKD_B,TILE_TRUCKD_C,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD5:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_TRUCKD_A,TILE_TRUCKD_B,TILE_TRUCKD_C,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD6:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_CAR1_RED,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD7:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_CAR1_PURPLE
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

; train (dynamic)
levelColumnDataTD0:
    .byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C
    .byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C

; water (static)
levelColumnDataWS0:
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_WATER,TILE_ROCK,TILE_WATER
    .byte   TILE_ROCK,TILE_ROCK,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWS1:
    .byte   TILE_WATER,TILE_WATER,TILE_ROCK,TILE_WATER,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_WATER
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWS2:
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_ROCK,TILE_WATER,TILE_ROCK
    .byte   TILE_ROCK,TILE_ROCK,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_ROCK,TILE_WATER,TILE_WATER

; water (dynamic)
levelColumnDataWD0:
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD1:
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD2:
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD3:
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD4:
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

; house
levelColumnDataH0:
    .byte   TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_BRICK,TILE_CARPET
    .byte   TILE_CARPET,TILE_BRICK,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS,TILE_GRASS
levelColumnDataH1:
    .byte   TILE_BRICK,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET
    .byte   TILE_CARPET,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_BRICK
levelColumnDataH2:
    .byte   TILE_BRICK,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET
    .byte   TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_BRICK
levelColumnDataH3:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_CARPET
    .byte   TILE_CARPET,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
levelColumnDataH4:
    .byte   TILE_BRICK,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_BRICK,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
levelColumnDataH5:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_BRICK
levelColumnDataH6:
    .byte   TILE_BRICK,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT
    .byte   TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_BRICK

; house (dynamic)
levelColumnDataHD0:
    .byte   TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR
    .byte   TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR,TILE_CONVEYOR

; brick
levelColumnDataB0:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_GRASS_S,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_GRASS_N

levelColumnDataB1:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_GRASS_S,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_GRASS_N
