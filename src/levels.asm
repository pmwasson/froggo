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
;   1               starting Y
;   2               even/odd animation timing
;   1               state offset
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

STATE_OFFSET_TURTLES    = 8*0
STATE_OFFSET_TRAINS     = 8*1

; Levels
;------------------------------------------------------------------------------

level_start:

; easy
level_e0:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_7,COLUMN_ROAD_D_1,COLUMN_ROAD_S_2,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_D_6,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_WATER_0
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_S_2,COLUMN_WATER_D_2
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_2
    ; dynamic speeds
    ConvertSpeeds   $00B0, $FF40, $0070, $FF60, $0080, $FF90, $0070, $FF90
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; easy
level_e1:         ; grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_4,COLUMN_GRASS_4
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0,COLUMN_ROAD_D_6,COLUMN_ROAD_D_1
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_D_2,COLUMN_ROAD_D_2,COLUMN_ROAD_D_6
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_7,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_4
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_1,COLUMN_GRASS_4,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $FF30, $FF80, $FF30, $FF40, $0090, $00E0, $0070, $00F0
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; easy
level_e2:         ; grass-water-grass-road-grass-water-grass-road-grass
    ; columns
    .byte       COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_WATER_1,COLUMN_WATER_D_2
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_GRASS_1,COLUMN_GRASS_ROAD_3,COLUMN_ROAD_D_0
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_1
    .byte       COLUMN_WATER_D_1,COLUMN_WATER_GRASS_1,COLUMN_GRASS_ROAD_0,COLUMN_ROAD_D_3
    .byte       COLUMN_ROAD_D_4,COLUMN_ROAD_GRASS_3,COLUMN_GRASS_3,COLUMN_GRASS_4
    ; dynamic speeds
    ConvertSpeeds   $0090, $FF60, $0070, $FF60, $0080, $FF90, $0080, $FFA0
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*5
    ; animation (not used)
    .byte       0,0,0

; easy
level_e3:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_WATER_1,COLUMN_WATER_D_0
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_S_2,COLUMN_WATER_D_1,COLUMN_WATER_D_2
    .byte       COLUMN_WATER_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_2,COLUMN_GRASS_1
    .byte       COLUMN_GRASS_ROAD_0,COLUMN_ROAD_D_8,COLUMN_ROAD_D_0,COLUMN_ROAD_S_2
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_D_6,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $00B0, $FF40, $0070, $FF60, $0080, $FF90, $0070, $FF90
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; easy
level_e4:         ; grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_4,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_6,COLUMN_ROAD_S_4,COLUMN_ROAD_D_1,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_S_4,COLUMN_ROAD_D_2,COLUMN_ROAD_S_3,COLUMN_ROAD_D_0
    .byte       COLUMN_ROAD_S_4,COLUMN_ROAD_D_7,COLUMN_ROAD_S_4,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_D_6,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_4
    ; dynamic speeds
    ConvertSpeeds   $FEC0, $FEB0, $FEF0, $FF00, $0140, $0100, $0120, $0110
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; easy (trains)
level_e5:         ; grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_2,COLUMN_GRASS_2,COLUMN_GRASS_1
    .byte       COLUMN_GRASS_ROAD_0,COLUMN_ROAD_D_6,COLUMN_ROAD_D_2,COLUMN_ROAD_GRASS_0
    .byte       COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0
    .byte       COLUMN_GRASS_ROAD_0,COLUMN_ROAD_D_7,COLUMN_ROAD_S_4,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_1,COLUMN_GRASS_4
    ; dynamic speeds
    ConvertSpeeds   $FEC0, $FEB0, $0700, $0780, $0600, $0680, $0110, $0100
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation
    .byte       $2F,$3F
    ; state offset ()
    .byte       STATE_OFFSET_TRAINS

; easy (ish)
level_e6:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_0,COLUMN_ROAD_D_5,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_3
    .byte       COLUMN_WATER_D_1,COLUMN_WATER_D_1,COLUMN_WATER_D_4,COLUMN_WATER_S_1
    .byte       COLUMN_WATER_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_3,COLUMN_GRASS_2
    ; dynamic speeds
    ConvertSpeeds   $00C0, $FF40, $FF10, $FF60, $0080, $FF90, $0080, $FFA0
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; easy (maybe medium so not first in game)
level_e7:         ; building
    ; columns
    .byte       COLUMN_HOUSE_0,COLUMN_HOUSE_0,COLUMN_HOUSE_3,COLUMN_HOUSE_1
    .byte       COLUMN_HOUSE_2,COLUMN_HOUSE_4,COLUMN_HOUSE_D_0,COLUMN_HOUSE_4
    .byte       COLUMN_HOUSE_4,COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0,COLUMN_HOUSE_5
    .byte       COLUMN_HOUSE_5,COLUMN_HOUSE_D_0,COLUMN_HOUSE_5,COLUMN_HOUSE_6
    .byte       COLUMN_HOUSE_2,COLUMN_HOUSE_3,COLUMN_HOUSE_0,COLUMN_HOUSE_0
    ; dynamic speeds
    ConvertSpeeds   $00C0, $0080, $FF80, $FF40, $0010, $0010, $0010, $0010
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; easy
level_e8:         ; grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_3,COLUMN_GRASS_WATER_0,COLUMN_WATER_S_3
    .byte       COLUMN_WATER_S_1,COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_S_2
    .byte       COLUMN_WATER_S_3,COLUMN_WATER_D_2,COLUMN_WATER_D_0,COLUMN_WATER_S_2
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_D_3,COLUMN_WATER_D_3,COLUMN_WATER_D_3
    .byte       COLUMN_WATER_S_3,COLUMN_WATER_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $00B0, $FF40, $0070, $FF60, $00A0, $FFB0, $0090, $FF90
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; medium (actually easy, but looks hard)
level_m0:         ; grass--road--grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_5,COLUMN_GRASS_6,COLUMN_GRASS_ROAD_1,COLUMN_ROAD_D_0
    .byte       COLUMN_ROAD_S_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_1,COLUMN_ROAD_D_0
    .byte       COLUMN_ROAD_S_1,COLUMN_ROAD_D_0,COLUMN_ROAD_GRASS_1,COLUMN_GRASS_6
    .byte       COLUMN_GRASS_ROAD_1,COLUMN_ROAD_D_0,COLUMN_ROAD_S_1,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_S_1,COLUMN_ROAD_D_3,COLUMN_ROAD_GRASS_1,COLUMN_GRASS_6
    ; dynamic speeds
    ConvertSpeeds   $0280, $FD40, $01C0, $FD00, $01F0, $0190, $01F0, $0000
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; medium
level_m1:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_0,COLUMN_ROAD_D_1,COLUMN_ROAD_D_2,COLUMN_ROAD_S_0
    .byte       COLUMN_ROAD_D_3,COLUMN_ROAD_GRASS_0,COLUMN_GRASS_3,COLUMN_GRASS_WATER_0
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $0180, $FF10, $00B0, $0150, $0040, $FF30, $0020, $0090
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*2
    ; animation (not used)
    .byte       0,0,0

; medium
level_m2:         ; grass-road-grass-water-grass-road-grass-water-grass
    ; columns
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_3,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_D_8,COLUMN_ROAD_GRASS_3,COLUMN_GRASS_WATER_1,COLUMN_WATER_D_3
    .byte       COLUMN_WATER_D_4,COLUMN_WATER_GRASS_1,COLUMN_GRASS_ROAD_3,COLUMN_ROAD_D_8
    .byte       COLUMN_ROAD_D_6,COLUMN_ROAD_GRASS_3,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_5
    .byte       COLUMN_WATER_D_6,COLUMN_WATER_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_4
    ; dynamic speeds
    ConvertSpeeds   $FF50, $00A0, $0070, $FF60, $0080, $FF90, $0070, $00D0
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*5
    ; animation (not used)
    .byte       0,0,0

; medium
level_m3:         ; grass--water--grass--water--grass
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_4,COLUMN_GRASS_WATER_0,COLUMN_WATER_S_2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_0
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_GRASS_0,COLUMN_GRASS_3,COLUMN_GRASS_WATER_0
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_1,COLUMN_WATER_D_2,COLUMN_WATER_S_1
    .byte       COLUMN_WATER_D_4,COLUMN_WATER_S_2,COLUMN_WATER_GRASS_0,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $0080, $FF10, $00A0, $0130, $FF50, $FF30, $0040, $FF40
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; medium
level_m4:         ; bricks--road--bricks
    ; columns
    .byte       COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1
    .byte       COLUMN_BRICK_0,COLUMN_GRASS_ROAD_2,COLUMN_ROAD_D_0,COLUMN_ROAD_D_5
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_D_0,COLUMN_ROAD_D_5,COLUMN_ROAD_D_1
    .byte       COLUMN_ROAD_D_5,COLUMN_ROAD_D_2,COLUMN_ROAD_GRASS_2,COLUMN_BRICK_0
    .byte       COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0
    ; dynamic speeds
    ConvertSpeeds   $0060, $FF50, $00A0, $0090, $FF30, $FF20, $FF60, $00D0
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*4
    ; animation (not used)
    .byte       0,0,0

; medium (tree maze)
level_m5:         ; grass--water--grass--water--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_7,COLUMN_GRASS_7,COLUMN_GRASS_WATER_2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_0,COLUMN_WATER_GRASS_2,COLUMN_GRASS_8
    .byte       COLUMN_GRASS_WATER_2,COLUMN_WATER_D_0,COLUMN_WATER_D_0,COLUMN_WATER_GRASS_2
    .byte       COLUMN_GRASS_7,COLUMN_GRASS_WATER_2,COLUMN_WATER_D_0,COLUMN_WATER_D_0
    .byte       COLUMN_WATER_GRASS_2,COLUMN_GRASS_8,COLUMN_GRASS_8,COLUMN_GRASS_3
    ; dynamic speeds
    ConvertSpeeds   $00A0, $FF50, $0070, $FF60, $0080, $FF90, $0070, $FF90
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; medium (turtles)
level_m6:         ; grass--water--grass (turtles)
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_4,COLUMN_GRASS_WATER_3,COLUMN_WATER_S_2
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_6,COLUMN_WATER_D_2,COLUMN_WATER_S_0
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_S_2,COLUMN_WATER_S_3,COLUMN_WATER_S_3
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_D_0,COLUMN_WATER_D_5,COLUMN_WATER_S_3
    .byte       COLUMN_WATER_D_4,COLUMN_WATER_S_2,COLUMN_WATER_GRASS_0,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $0060, $0090, $FF80, $FF40, $0060, $FF50, $0040, $FF40
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; even / odd column timing (turtles)
    .byte       $21,$30
    ; state offset ()
    .byte       STATE_OFFSET_TURTLES

; medium (run upstream)
level_m7:        ; building
    ; columns
    .byte       COLUMN_HOUSE_0,COLUMN_HOUSE_3,COLUMN_HOUSE_1,COLUMN_HOUSE_4
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0,COLUMN_HOUSE_5,COLUMN_HOUSE_D_0
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_4,COLUMN_HOUSE_4,COLUMN_HOUSE_D_0
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_5,COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0
    .byte       COLUMN_HOUSE_4,COLUMN_HOUSE_7,COLUMN_HOUSE_3,COLUMN_HOUSE_0
    ; dynamic speeds
    ConvertSpeeds   $00C0, $0080, $FF80, $FF40, $00F0, $0090, $FEF0, $FF80
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; medium (small logs in a row)
level_m8:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_2,COLUMN_ROAD_D_1,COLUMN_ROAD_D_3,COLUMN_ROAD_D_4
    .byte       COLUMN_ROAD_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_7
    .byte       COLUMN_GRASS_WATER_2,COLUMN_WATER_D_4,COLUMN_WATER_D_7,COLUMN_WATER_D_4
    .byte       COLUMN_WATER_D_7,COLUMN_WATER_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_2
    ; dynamic speeds
    ConvertSpeeds   $00B0, $FF40, $0070, $FF60, $FF70, $00A0, $FF10, $0090
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; medium (maybe hard?)
level_m9:         ; grass--road--train-road-train-grass
    ; columns
    .byte       COLUMN_GRASS_2,COLUMN_GRASS_2,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_3,COLUMN_ROAD_D_4,COLUMN_ROAD_S_3,COLUMN_TRAIN_D_0
    .byte       COLUMN_TRAIN_D_0,COLUMN_ROAD_S_3,COLUMN_ROAD_D_3,COLUMN_ROAD_D_2
    .byte       COLUMN_ROAD_S_3,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_ROAD_GRASS_0
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_1,COLUMN_GRASS_4,COLUMN_GRASS_1
    ; dynamic speeds
    ConvertSpeeds   $00C0, $FEB0, $0500, $0500, $00A0, $0100, $0500, $0500
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation
    .byte       $1F,$3F
    ; state offset ()
    .byte       STATE_OFFSET_TRAINS

; medium
level_m10:         ; crosswalk + conveyor belts
    ; columns
    .byte       COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1
    .byte       COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0
    .byte       COLUMN_HOUSE_D_0,COLUMN_HOUSE_D_0,COLUMN_BRICK_1,COLUMN_BRICK_0
    .byte       COLUMN_BRICK_1,COLUMN_BRICK_0,COLUMN_BRICK_1,COLUMN_BRICK_0
    ; dynamic speeds
    ConvertSpeeds   $FF60, $FF10, $FF30, $FF40, $FF20, $FF30, $FF40, $FF50
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; hard (trains)
level_h0:         ; grass--road--grass
    ; columns
    .byte       COLUMN_GRASS_3,COLUMN_GRASS_2,COLUMN_GRASS_1,COLUMN_GRASS_1
    .byte       COLUMN_GRASS_1,COLUMN_GRASS_ROAD_0,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0
    .byte       COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0
    .byte       COLUMN_TRAIN_D_0,COLUMN_TRAIN_D_0,COLUMN_ROAD_GRASS_3,COLUMN_GRASS_2
    .byte       COLUMN_GRASS_4,COLUMN_GRASS_1,COLUMN_GRASS_4,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $0740, $0750, $0760, $0770, $0780, $07A0, $07B0, $07C0
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation
    .byte       $2F,$1F
    ; state offset ()
    .byte       STATE_OFFSET_TRAINS

; hard (sync cars, maybe medium)
level_h1:         ; brick--road--brick--road--brick
    ; columns
    .byte       COLUMN_BRICK_2,COLUMN_BRICK_3,COLUMN_BRICK_2,COLUMN_BRICK_3
    .byte       COLUMN_BRICK_4,COLUMN_ROAD_D_6,COLUMN_ROAD_D_6,COLUMN_ROAD_D_7
    .byte       COLUMN_BRICK_5,COLUMN_BRICK_3,COLUMN_BRICK_4,COLUMN_ROAD_D_6
    .byte       COLUMN_ROAD_D_7,COLUMN_ROAD_D_6,COLUMN_ROAD_D_7,COLUMN_BRICK_5
    .byte       COLUMN_BRICK_3,COLUMN_BRICK_2,COLUMN_BRICK_3,COLUMN_BRICK_2
    ; dynamic speeds
    ConvertSpeeds   $0180, $01D0, $FE40, $FE10, $0190, $0140, $0190, $0000
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; animation (not used)
    .byte       0,0,0

; hard (trucks at end)
level_h2:         ; grass--road--grass--water--grass
    ; columns
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_1,COLUMN_GRASS_3,COLUMN_GRASS_WATER_1
    .byte       COLUMN_WATER_D_3,COLUMN_WATER_D_2,COLUMN_WATER_S_2,COLUMN_WATER_D_1
    .byte       COLUMN_WATER_D_0,COLUMN_WATER_GRASS_0,COLUMN_GRASS_2,COLUMN_GRASS_ROAD_0
    .byte       COLUMN_ROAD_D_5,COLUMN_ROAD_D_4,COLUMN_ROAD_D_4,COLUMN_ROAD_D_4
    .byte       COLUMN_ROAD_GRASS_0,COLUMN_GRASS_3,COLUMN_GRASS_4,COLUMN_GRASS_0
    ; dynamic speeds
    ConvertSpeeds   $0060, $FF50, $00A0, $0090, $FEB0, $FF20, $FF60, $FF30
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*4
    ; animation (not used)
    .byte       0,0,0

; hard
level_h3:         ; road + conveyor belts
    ; columns
    .byte       COLUMN_BRICK_6,COLUMN_BRICK_7,COLUMN_BRICK_7,COLUMN_BRICK_8
    .byte       COLUMN_HOUSE_D_0,COLUMN_ROAD_D_9,COLUMN_ROAD_D_9,COLUMN_HOUSE_D_0
    .byte       COLUMN_BRICK_6,COLUMN_BRICK_7,COLUMN_BRICK_7,COLUMN_BRICK_8
    .byte       COLUMN_HOUSE_D_0,COLUMN_ROAD_D_9,COLUMN_ROAD_D_9,COLUMN_HOUSE_D_0
    .byte       COLUMN_BRICK_6,COLUMN_BRICK_7,COLUMN_BRICK_7,COLUMN_BRICK_8
    ; dynamic speeds
    ConvertSpeeds   $0080, $01D0, $FE40, $FF60, $00C0, $0140, $FEC0, $FF00
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*3
    ; animation (not used)
    .byte       0,0,0

; hard (turtles)
level_h4:        ; grass--water--grass (turtles)
    .byte       COLUMN_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_WATER_2,COLUMN_WATER_D_5
    .byte       COLUMN_WATER_D_5,COLUMN_WATER_GRASS_0,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_5
    .byte       COLUMN_WATER_D_5,COLUMN_WATER_GRASS_0,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_5
    .byte       COLUMN_WATER_D_5,COLUMN_WATER_GRASS_0,COLUMN_GRASS_WATER_0,COLUMN_WATER_D_5
    .byte       COLUMN_WATER_D_5,COLUMN_WATER_GRASS_0,COLUMN_GRASS_4,COLUMN_GRASS_4
    ; dynamic speeds
    ConvertSpeeds   $0050, $0090, $0040, $00B0, $0060, $00D0, $00C0, $0030
    ; starting Y
    .byte       MAP_TOP+TILE_HEIGHT*8
    ; even / odd column timing (turtles)
    .byte       $21,$27
    ; state offset ()
    .byte       STATE_OFFSET_TURTLES

; hard (rockets)
level_h5:
    ; columns
    .byte       COLUMN_ROCKET_0,COLUMN_ROCKET_1,COLUMN_ROCKET_2,COLUMN_ROCKET_D_0
    .byte       COLUMN_ROCKET_0,COLUMN_ROCKET_2,COLUMN_ROCKET_D_0,COLUMN_ROCKET_0
    .byte       COLUMN_ROCKET_2,COLUMN_ROCKET_D_0,COLUMN_ROCKET_0,COLUMN_ROCKET_2
    .byte       COLUMN_ROCKET_D_0,COLUMN_ROCKET_0,COLUMN_ROCKET_2,COLUMN_ROCKET_D_1
    .byte       COLUMN_ROCKET_D_2,COLUMN_ROCKET_D_1,COLUMN_ROCKET_0,COLUMN_ROCKET_2
    ; dynamic speeds
    ConvertSpeeds   $0300, $0320, $0340, $0360, $0270, $0270, $0270, $0000
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*5
    ; animation (not used)
    .byte       0,0,0

level_xx:
    ; columns
    .byte       COLUMN_ROCKET_0,COLUMN_ROCKET_1,COLUMN_ROCKET_1,COLUMN_ROCKET_SPACE
    .byte       COLUMN_ROCKET_T,COLUMN_ROCKET_H,COLUMN_ROCKET_E,COLUMN_ROCKET_SPACE
    .byte       COLUMN_ROCKET_E,COLUMN_ROCKET_N,COLUMN_ROCKET_D,COLUMN_ROCKET_SPACE
    .byte       COLUMN_ROCKET_SPACE,COLUMN_ROCKET_1,COLUMN_ROCKET_1,COLUMN_ROCKET_2
    .byte       COLUMN_ROCKET_D_3,COLUMN_ROCKET_0,COLUMN_ROCKET_1,COLUMN_ROCKET_2
    ; dynamic speeds
    ConvertSpeeds   $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    ; starting Y
    .byte       MAP_BOTTOM-TILE_HEIGHT*5
    ; animation (not used)
    .byte       0,0,0

level_end:

; Column Indexes:
;------------------------------------------------------------------------------
COLUMN_GRASS_0              = (levelColumnDataG0   - levelColumnData)/16
COLUMN_GRASS_1              = (levelColumnDataG1   - levelColumnData)/16
COLUMN_GRASS_2              = (levelColumnDataG2   - levelColumnData)/16
COLUMN_GRASS_3              = (levelColumnDataG3   - levelColumnData)/16
COLUMN_GRASS_4              = (levelColumnDataG4   - levelColumnData)/16
COLUMN_GRASS_5              = (levelColumnDataG5   - levelColumnData)/16
COLUMN_GRASS_6              = (levelColumnDataG6   - levelColumnData)/16
COLUMN_GRASS_7              = (levelColumnDataG7   - levelColumnData)/16
COLUMN_GRASS_8              = (levelColumnDataG8   - levelColumnData)/16
COLUMN_GRASS_ROAD_0         = (levelColumnDataGR0  - levelColumnData)/16
COLUMN_GRASS_ROAD_1         = (levelColumnDataGR1  - levelColumnData)/16
COLUMN_GRASS_ROAD_2         = (levelColumnDataGR2  - levelColumnData)/16
COLUMN_GRASS_ROAD_3         = (levelColumnDataGR3  - levelColumnData)/16
COLUMN_ROAD_GRASS_0         = (levelColumnDataRG0  - levelColumnData)/16
COLUMN_ROAD_GRASS_1         = (levelColumnDataRG1  - levelColumnData)/16
COLUMN_ROAD_GRASS_2         = (levelColumnDataRG2  - levelColumnData)/16
COLUMN_ROAD_GRASS_3         = (levelColumnDataRG3  - levelColumnData)/16
COLUMN_GRASS_WATER_0        = (levelColumnDataGW0  - levelColumnData)/16
COLUMN_GRASS_WATER_1        = (levelColumnDataGW1  - levelColumnData)/16
COLUMN_GRASS_WATER_2        = (levelColumnDataGW2  - levelColumnData)/16
COLUMN_GRASS_WATER_3        = (levelColumnDataGW3  - levelColumnData)/16
COLUMN_WATER_GRASS_0        = (levelColumnDataWG0  - levelColumnData)/16
COLUMN_WATER_GRASS_1        = (levelColumnDataWG1  - levelColumnData)/16
COLUMN_WATER_GRASS_2        = (levelColumnDataWG2  - levelColumnData)/16
COLUMN_ROAD_S_0             = (levelColumnDataRS0  - levelColumnData)/16
COLUMN_ROAD_S_1             = (levelColumnDataRS1  - levelColumnData)/16
COLUMN_ROAD_S_2             = (levelColumnDataRS2  - levelColumnData)/16
COLUMN_ROAD_S_3             = (levelColumnDataRS3  - levelColumnData)/16
COLUMN_ROAD_S_4             = (levelColumnDataRS4  - levelColumnData)/16
COLUMN_ROAD_D_0             = (levelColumnDataRD0  - levelColumnData)/16
COLUMN_ROAD_D_1             = (levelColumnDataRD1  - levelColumnData)/16
COLUMN_ROAD_D_2             = (levelColumnDataRD2  - levelColumnData)/16
COLUMN_ROAD_D_3             = (levelColumnDataRD3  - levelColumnData)/16
COLUMN_ROAD_D_4             = (levelColumnDataRD4  - levelColumnData)/16
COLUMN_ROAD_D_5             = (levelColumnDataRD5  - levelColumnData)/16
COLUMN_ROAD_D_6             = (levelColumnDataRD6  - levelColumnData)/16
COLUMN_ROAD_D_7             = (levelColumnDataRD7  - levelColumnData)/16
COLUMN_ROAD_D_8             = (levelColumnDataRD8  - levelColumnData)/16
COLUMN_ROAD_D_9             = (levelColumnDataRD9  - levelColumnData)/16
COLUMN_TRAIN_D_0            = (levelColumnDataTD0  - levelColumnData)/16
COLUMN_WATER_S_0            = (levelColumnDataWS0  - levelColumnData)/16
COLUMN_WATER_S_1            = (levelColumnDataWS1  - levelColumnData)/16
COLUMN_WATER_S_2            = (levelColumnDataWS2  - levelColumnData)/16
COLUMN_WATER_S_3            = (levelColumnDataWS3  - levelColumnData)/16
COLUMN_WATER_D_0            = (levelColumnDataWD0  - levelColumnData)/16
COLUMN_WATER_D_1            = (levelColumnDataWD1  - levelColumnData)/16
COLUMN_WATER_D_2            = (levelColumnDataWD2  - levelColumnData)/16
COLUMN_WATER_D_3            = (levelColumnDataWD3  - levelColumnData)/16
COLUMN_WATER_D_4            = (levelColumnDataWD4  - levelColumnData)/16
COLUMN_WATER_D_5            = (levelColumnDataWD5  - levelColumnData)/16
COLUMN_WATER_D_6            = (levelColumnDataWD6  - levelColumnData)/16
COLUMN_WATER_D_7            = (levelColumnDataWD7  - levelColumnData)/16
COLUMN_HOUSE_0              = (levelColumnDataH0   - levelColumnData)/16
COLUMN_HOUSE_1              = (levelColumnDataH1   - levelColumnData)/16
COLUMN_HOUSE_2              = (levelColumnDataH2   - levelColumnData)/16
COLUMN_HOUSE_3              = (levelColumnDataH3   - levelColumnData)/16
COLUMN_HOUSE_4              = (levelColumnDataH4   - levelColumnData)/16
COLUMN_HOUSE_5              = (levelColumnDataH5   - levelColumnData)/16
COLUMN_HOUSE_6              = (levelColumnDataH6   - levelColumnData)/16
COLUMN_HOUSE_7              = (levelColumnDataH7   - levelColumnData)/16
COLUMN_HOUSE_D_0            = (levelColumnDataHD0  - levelColumnData)/16
COLUMN_BRICK_0              = (levelColumnDataB0   - levelColumnData)/16
COLUMN_BRICK_1              = (levelColumnDataB1   - levelColumnData)/16
COLUMN_BRICK_2              = (levelColumnDataB2   - levelColumnData)/16
COLUMN_BRICK_3              = (levelColumnDataB3   - levelColumnData)/16
COLUMN_BRICK_4              = (levelColumnDataB4   - levelColumnData)/16
COLUMN_BRICK_5              = (levelColumnDataB5   - levelColumnData)/16
COLUMN_BRICK_6              = (levelColumnDataB6   - levelColumnData)/16
COLUMN_BRICK_7              = (levelColumnDataB7   - levelColumnData)/16
COLUMN_BRICK_8              = (levelColumnDataB8   - levelColumnData)/16
COLUMN_ROCKET_0             = (levelColumnRocket0  - levelColumnData)/16
COLUMN_ROCKET_1             = (levelColumnRocket1  - levelColumnData)/16
COLUMN_ROCKET_2             = (levelColumnRocket2  - levelColumnData)/16
COLUMN_ROCKET_SPACE         = (levelColumnRocket_SPACE  - levelColumnData)/16
COLUMN_ROCKET_T             = (levelColumnRocket_T - levelColumnData)/16
COLUMN_ROCKET_H             = (levelColumnRocket_H - levelColumnData)/16
COLUMN_ROCKET_E             = (levelColumnRocket_E - levelColumnData)/16
COLUMN_ROCKET_N             = (levelColumnRocket_N - levelColumnData)/16
COLUMN_ROCKET_D             = (levelColumnRocket_D - levelColumnData)/16
COLUMN_ROCKET_D_0           = (levelColumnRocketD0 - levelColumnData)/16
COLUMN_ROCKET_D_1           = (levelColumnRocketD1 - levelColumnData)/16
COLUMN_ROCKET_D_2           = (levelColumnRocketD2 - levelColumnData)/16
COLUMN_ROCKET_D_3           = (levelColumnRocketD3 - levelColumnData)/16

COLUMN_TYPE_STATIC          = $00
COLUMN_TYPE_TURTLES         = $10
COLUMN_TYPE_DYNAMIC         = $80           ; $80..$87

levelColumnInfo:
; grass
    .byte       COLUMN_TYPE_STATIC                              ; grass - empty
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 2 trees near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - 1 tree in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - 3 trees near top
    .byte       COLUMN_TYPE_STATIC                              ; grass - crosswalk in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - sidewalk in middle
    .byte       COLUMN_TYPE_STATIC                              ; grass - trees with openning in top
    .byte       COLUMN_TYPE_STATIC                              ; grass - trees with openning in bottom

; grass2road
    .byte       COLUMN_TYPE_STATIC                              ; 1 bush near bottom
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk (bottom)
    .byte       COLUMN_TYPE_STATIC                              ; more bushes

; road2grass
    .byte       COLUMN_TYPE_STATIC                              ; empty
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk
    .byte       COLUMN_TYPE_STATIC                              ; crosswalk (bottom)
    .byte       COLUMN_TYPE_STATIC                              ; bushes

; grass2water
    .byte       COLUMN_TYPE_STATIC                              ; several bushes
    .byte       COLUMN_TYPE_STATIC                              ; all clear
    .byte       COLUMN_TYPE_STATIC                              ; small openning top/bottom
    .byte       COLUMN_TYPE_STATIC                              ; openning in middle

; water2grass
    .byte       COLUMN_TYPE_STATIC                              ; 2 trees on top
    .byte       COLUMN_TYPE_STATIC                              ; clear
    .byte       COLUMN_TYPE_STATIC                              ; small openning top/bottom

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
    .byte       COLUMN_TYPE_DYNAMIC                             ; 4 medium cars
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 robot

; train (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; train cars

; water (static)
    .byte       COLUMN_TYPE_STATIC                              ; rocks in middle
    .byte       COLUMN_TYPE_STATIC                              ; rocks spread out
    .byte       COLUMN_TYPE_STATIC                              ; rocks matching shore (pair with r2g0)
    .byte       COLUMN_TYPE_STATIC                              ; more rocks

; water (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 medium log (11 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 2 logs (7 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 3 small log (8 water)
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 big log
    .byte       COLUMN_TYPE_DYNAMIC+COLUMN_TYPE_TURTLES         ; 3 turtles
    .byte       COLUMN_TYPE_DYNAMIC+COLUMN_TYPE_TURTLES         ; turtles / logs
    .byte       COLUMN_TYPE_DYNAMIC                             ; 1 medium log

; house
    .byte       COLUMN_TYPE_STATIC                              ; entry
    .byte       COLUMN_TYPE_STATIC                              ; left side
    .byte       COLUMN_TYPE_STATIC                              ; middle
    .byte       COLUMN_TYPE_STATIC                              ; exit
    .byte       COLUMN_TYPE_STATIC                              ; open at top
    .byte       COLUMN_TYPE_STATIC                              ; open at bottom
    .byte       COLUMN_TYPE_STATIC                              ; middle (adjust carpet)
    .byte       COLUMN_TYPE_STATIC                              ; middle

; house (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; conveyor belt

; brick
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk bottom (crosswalk)
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk bottom (blank)
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk middle (crosswalk)
    .byte       COLUMN_TYPE_STATIC                              ; brick / crosswalk middle (blank)
    .byte       COLUMN_TYPE_STATIC                              ; brick-east / crosswalk middle (crosswalk)
    .byte       COLUMN_TYPE_STATIC                              ; brick-west / crosswalk middle (blank)
    .byte       COLUMN_TYPE_STATIC                              ; brick-west passage top
    .byte       COLUMN_TYPE_STATIC                              ; brick passage top
    .byte       COLUMN_TYPE_STATIC                              ; brick-east passage top

; Rocket
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - west
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - mid
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - east
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - space
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - t
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - h
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - e
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - n
    .byte       COLUMN_TYPE_STATIC                              ; Rocket - d
    .byte       COLUMN_TYPE_DYNAMIC                             ; Small Rocket (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; Medium Rocket (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; Big Rocket (dynamic)
    .byte       COLUMN_TYPE_DYNAMIC                             ; Final rocket

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
levelColumnDataG7:
    .byte   TILE_TREE_A,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B,TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B
levelColumnDataG8:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B,TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B,TILE_GRASS,TILE_GRASS,TILE_TREE_A,TILE_TREE_B

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
levelColumnDataGR3:
    .byte   TILE_BUSH_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD
    .byte   TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_GRASS_ROAD,TILE_BUSH_ROAD,TILE_BUSH_ROAD


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
levelColumnDataRG3:
    .byte   TILE_ROAD_BUSH,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_BUSH,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS
    .byte   TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_BUSH,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_GRASS,TILE_ROAD_BUSH,TILE_ROAD_BUSH

; grass2water
levelColumnDataGW0:
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER

levelColumnDataGW1:
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER

levelColumnDataGW2:
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER

levelColumnDataGW3:
    .byte   TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_GRASS_WATER,TILE_GRASS_WATER
    .byte   TILE_GRASS_WATER,TILE_GRASS_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER,TILE_BUSH_WATER

; water2grass
levelColumnDataWG0:
    .byte   TILE_TREE_A,TILE_TREE_MID,TILE_TREE_B,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS
    .byte   TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS

levelColumnDataWG1:
    .byte   TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS
    .byte   TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_WATER_GRASS

levelColumnDataWG2:
    .byte   TILE_TREE_A,TILE_TREE_B,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_TREE_A,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_MID
    .byte   TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_MID,TILE_TREE_B,TILE_WATER_GRASS,TILE_WATER_GRASS,TILE_TREE_A,TILE_TREE_B

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
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
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
levelColumnDataRD8:
    .byte   TILE_ROAD,TILE_ROAD,TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_ROAD,TILE_CAR2_A,TILE_CAR2_B
    .byte   TILE_ROAD,TILE_CAR2_A,TILE_CAR2_B,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
levelColumnDataRD9:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROBOT,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD

; train (dynamic)
levelColumnDataTD0:
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS
    .byte   TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS,TILE_TRAIN_TRACKS

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
levelColumnDataWS3:
    .byte   TILE_ROCK,TILE_WATER,TILE_WATER,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK
    .byte   TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_ROCK,TILE_WATER

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
    .byte   TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD5:
    .byte   TILE_TURTLE_A,TILE_TURTLE_B,TILE_WATER,TILE_TURTLE_A
    .byte   TILE_TURTLE_B,TILE_WATER,TILE_TURTLE_A,TILE_TURTLE_B
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
levelColumnDataWD6:
    .byte   TILE_TURTLE_A,TILE_TURTLE_B,TILE_WATER,TILE_WATER,TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER
    .byte   TILE_TURTLE_A,TILE_TURTLE_B,TILE_WATER,TILE_WATER,TILE_LOG_A,TILE_LOG_C,TILE_WATER,TILE_WATER
levelColumnDataWD7:
    .byte   TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER
    .byte   TILE_LOG_A,TILE_LOG_B,TILE_LOG_C,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER,TILE_WATER

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
levelColumnDataH7:
    .byte   TILE_BRICK,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT
    .byte   TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_CARPET_LEFT,TILE_BRICK

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

levelColumnDataB2:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK

levelColumnDataB3:
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK

levelColumnDataB4:
    .byte   TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_SE,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_BRICK_NE,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E

levelColumnDataB5:
    .byte   TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_SW,TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK
    .byte   TILE_CROSSWALK,TILE_CROSSWALK,TILE_CROSSWALK,TILE_BRICK_NW,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W

levelColumnDataB6:
    .byte   TILE_BRICK_NW,TILE_BRICK_W,TILE_BRICK_SW,TILE_ROAD,TILE_ROAD,TILE_BRICK_NW,TILE_BRICK_W,TILE_BRICK_W
    .byte   TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_SW

levelColumnDataB7:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnDataB8:
    .byte   TILE_BRICK_NE,TILE_BRICK_E,TILE_BRICK_SE,TILE_ROAD,TILE_ROAD,TILE_BRICK_NE,TILE_BRICK_E,TILE_BRICK_E
    .byte   TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_SE

; Rocket

levelColumnRocket0:
    .byte   TILE_BRICK_NW,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_W
    .byte   TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_SW,TILE_ROAD,TILE_BRICK_NW,TILE_BRICK_W,TILE_BRICK_W,TILE_BRICK_SW

levelColumnRocket1:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket2:
    .byte   TILE_BRICK_NE,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_E
    .byte   TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_SE,TILE_ROAD,TILE_BRICK_NE,TILE_BRICK_E,TILE_BRICK_E,TILE_BRICK_SE

levelColumnRocket_SPACE:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket_T:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,'T'-$20,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket_H:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,'H'-$20,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket_E:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,'E'-$20,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket_N:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,'N'-$20,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S

levelColumnRocket_D:
    .byte   TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_ROAD,'D'-$20,TILE_ROAD,TILE_BRICK,TILE_BRICK
    .byte   TILE_BRICK,TILE_BRICK,TILE_BRICK_S,TILE_ROAD,TILE_BRICK_N,TILE_BRICK,TILE_BRICK,TILE_BRICK_S


levelColumnRocketD0:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROCKET_A,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_C,TILE_ROCKET_FLAME,TILE_ROAD

levelColumnRocketD1:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROCKET_A,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_C,TILE_ROCKET_FLAME,TILE_ROAD

levelColumnRocketD2:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROCKET_A,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_C,TILE_ROCKET_FLAME,TILE_ROAD

levelColumnRocketD3:
    .byte   TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD,TILE_ROAD
    .byte   TILE_ROAD,TILE_ROCKET_A,TILE_ROCKET_B,TILE_ROCKET_CABIN,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_B,TILE_ROCKET_C

