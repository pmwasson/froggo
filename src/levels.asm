;-----------------------------------------------------------------------------
; Paul Wasson - 2025
;-----------------------------------------------------------------------------
; Level Data
;-----------------------------------------------------------------------------

COLUMN_TYPE_STATIC          = 0
COLUMN_TYPE_DYNAMIC         = 1
COLUMN_TYPE_DOWN            = 2

COLUMN_GRASS_0              = (levelColumnDataG0  - levelColumnData)/16
COLUMN_GRASS_1              = (levelColumnDataG1  - levelColumnData)/16
COLUMN_GRASS_2              = (levelColumnDataG2  - levelColumnData)/16
COLUMN_GRASS_3              = (levelColumnDataG3  - levelColumnData)/16
COLUMN_GRASS_4              = (levelColumnDataG4  - levelColumnData)/16
COLUMN_GRASS_ROAD_0         = (levelColumnDataGR0 - levelColumnData)/16
COLUMN_ROAD_GRASS_0         = (levelColumnDataRG0 - levelColumnData)/16
COLUMN_GRASS_WATER_0        = (levelColumnDataGW0 - levelColumnData)/16
COLUMN_WATER_GRASS_0        = (levelColumnDataWG0 - levelColumnData)/16
COLUMN_ROAD_S_0             = (levelColumnDataRS0 - levelColumnData)/16
COLUMN_ROAD_D_0             = (levelColumnDataRD0 - levelColumnData)/16
COLUMN_ROAD_D_1             = (levelColumnDataRD1 - levelColumnData)/16
COLUMN_ROAD_D_2             = (levelColumnDataRD2 - levelColumnData)/16
COLUMN_ROAD_D_3             = (levelColumnDataRD3 - levelColumnData)/16
COLUMN_TRAIN_D_0            = (levelColumnDataTD0 - levelColumnData)/16
COLUMN_WATER_S_0            = (levelColumnDataWS0 - levelColumnData)/16
COLUMN_WATER_D_0            = (levelColumnDataWD0 - levelColumnData)/16
COLUMN_WATER_D_1            = (levelColumnDataWD1 - levelColumnData)/16
COLUMN_WATER_D_2            = (levelColumnDataWD2 - levelColumnData)/16
COLUMN_WATER_D_3            = (levelColumnDataWD3 - levelColumnData)/16

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

level0:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0                                            ; 4
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_0,COLUMN_ROAD_D_3,COLUMN_ROAD_GRASS_0         ; 6
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_WATER_0                                                                         ; 2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0,COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_0                                                                               ; 2
    ; dynamic speeds
    ;           $0180   $FF10   $00B0   $0150   $0040   $FF30   $0020   $0090
    ;             ^^      ^^      ^^      ^^      ^^      ^^      ^^      ^^
    .byte       $81,    $1F,    $B0,    $51,    $40,    $3F,    $20,    $90
    ; padding
    .res        4

level1:         ; grass--water--grass--water--grass
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_3,COLUMN_GRASS_4,COLUMN_GRASS_WATER_0                                           ; 4
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0,COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_WATER_0                                                                         ; 2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0,COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0   ; 6
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_0                                                                               ; 2

    ;           $0080   $FF10   $00A0   $0130   $FF40   $FF30   $0020   $FF90
    ;             ^^      ^^      ^^      ^^      ^^      ^^      ^^      ^^
    .byte       $80,    $1F,    $A0,    $31,    $4F,    $3F,    $20,    $9F

    ; padding
    .res        4

    .byte       $FF     ; end of levels

levelColumnInfo:
; grass
    .byte       COLUMN_TYPE_STATIC                              ; grass - empty
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 2 trees near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - 3 trees near top

; grass2road
    .byte       COLUMN_TYPE_STATIC                              ; 1 bush near bottom

; road2grass
    .byte       COLUMN_TYPE_STATIC                              ; empty

; grass2water
    .byte       COLUMN_TYPE_STATIC                              ; several bushes

; water2grass
    .byte       COLUMN_TYPE_STATIC                              ; 2 trees on top

; road (static)
    .byte       COLUMN_TYPE_STATIC                              ; cones

; road (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small cars (blue, purple, blue)
    .byte       COLUMN_TYPE_DYNAMIC + COLUMN_TYPE_DOWN          ; 2 medium cars and a truck (down)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small cars (red, red, blue)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 trucks

; train (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; train cars

; water (static)
    .byte       COLUMN_TYPE_STATIC                              ; rocks in middle

; water (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 medium log (11 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small log (8 water)


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

; grass2road
levelColumnDataGR0:
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD

; road2grass
levelColumnDataRG0:
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS

; grass2water
levelColumnDataGW0:
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER

; water2grass
levelColumnDataWG0:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_B,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS
    .byte   TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS

; road (static)
levelColumnDataRS0:
    .byte   TILE_CONE,TILE_CONE,TILE_CONE,TILE_ROAD,TILE_ROAD,TILE_CONE,TILE_CONE,TILE_ROAD
    .byte   TILE_ROAD,TILE_CONE,TILE_CONE,TILE_ROAD,TILE_ROAD,TILE_CONE,TILE_CONE,TILE_CONE

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

; train (dynamic)
levelColumnDataTD0:
    .byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C
    .byte   TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C,TILE_TRAIN_A,TILE_TRAIN_B,TILE_TRAIN_B,TILE_TRAIN_C

; water (static)
levelColumnDataWS0:
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_WATER,TILE_ROCK,TILE_WATER
    .byte   TILE_ROCK,TILE_ROCK,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

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