; level data
ROOM: macro
    db $FF
endm
ROOM_COMPRESSED: macro
    db $FE
endm
ENDROOMS: macro
    db $FD
endm

ENT_NONE:                equ $00
ENT_ITM_AXE:             equ $01 ; only in even slots
ENT_ITM_HOLY:            equ $02 ; only in even slots
ENT_ITM_HHOLY:           equ $01 ; only in odd slots
ENT_ITM_HCROSS:          equ $02 ; only in odd slots
ENT_ITM_COIN:            equ $03
ENT_ITM_WHIP_FIRE:       equ $04
ENT_ITM_HEARTSMALL:      equ $05
ENT_ITM_HEARTBIG:        equ $06
ENT_WALL_1UP:            equ $08
ENT_ENM_RAT_09:          equ $09
ENT_WALL_MEAT:           equ $0b
ENT_ENM_PANAGUCHI_0C:    equ $0c
ENT_ENM_PANAGUCHI_0D:    equ $0d
ENT_ENM_RAT_0E:          equ $0e
ENT_ENM_BAT_1F:          equ $1f
ENT_BOSS_22:             equ $22
ENT_SPAWNEYE_RIGHT:      equ $25
ENT_SPAWNEYE_LEFT:       equ $26
ENT_ENM_RAVEN:           equ $34
ENT_ITM_WHIP_CHAIN:      equ $35
ENT_SPAWNEYE_ABOVE:      equ $3c
ENT_ENM_DAGGER:          equ $41
ENT_BOSS_55:             equ $45
ENT_BGFLAME:             equ $4e
ENT_BOSS_ANGEL_MUMMY:    equ $53
ENT_BOSS_60:             equ $60
ENT_BOSS_BONE_SERPENT:   equ $69
ENT_BOSS_SOLEIL:         equ $72
ENT_BOSS_DRACULA:        equ $73

SLOT0: equ $00
SLOT1: equ $01
SLOT2: equ $02
SLOT3: equ $03

org $5d77
banksk3
LvlPlant_0_Items:
    db $04, $58, SLOT2, ENT_ITM_COIN,        $a8, $38
    db $05, $18, SLOT3, ENT_ITM_HEARTSMALL,  $a8, $38
    db $06, $18, SLOT0, ENT_ITM_HEARTSMALL,  $a8, $4c
    db $06, $58, SLOT1, ENT_ITM_COIN,        $a8, $38
    db $07, $18, SLOT2, ENT_ITM_WHIP_FIRE,   $a8, $38
    db $07, $58, SLOT0, ENT_ITM_HEARTBIG,    $a8, $38
    ENDROOMS

org $5d9c
banksk3
LvlPlant_1_Items:
    db $06, $48, SLOT0, ENT_ITM_WHIP_FIRE,   $a8, $60
    db $07, $10, SLOT1, ENT_ITM_HEARTBIG,    $a8, $30
    ROOM
    db $03, $78, SLOT2, ENT_ITM_HEARTBIG,    $a8, $58
    db $04, $68, SLOT3, ENT_ITM_WHIP_FIRE,   $a8, $28
    db $04, $78, SLOT0, ENT_ITM_HEARTSMALL,  $a8, $58
    db $06, $48, SLOT1, ENT_ITM_HHOLY,       $a8, $2c ; HOLY
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $40, $28
    db           SLOT1, ENT_ITM_COIN,        $70, $28
    ENDROOMS

org $5dcb
banksk3
LvlPlant_2_Items:
    db $81, $20, SLOT0, ENT_ITM_COIN,        $38, $88
    db $81, $68, SLOT3, ENT_ITM_COIN,        $78, $88
    db $83, $28, SLOT2, ENT_ITM_AXE,         $78, $88 ; AXE
    db $83, $60, SLOT0, ENT_ITM_HEARTBIG,    $30, $88
    db $85, $50, SLOT3, ENT_ITM_HEARTSMALL,  $40, $88
    db $85, $50, SLOT0, ENT_ITM_WHIP_CHAIN,  $60, $88
    db $85, $60, SLOT1, ENT_WALL_MEAT,       $18, $88
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $18, $18
    ENDROOMS

org $5dfb
banksk3
LvlPlant_3_Items:
    db $04, $38, SLOT0, ENT_ITM_COIN,        $a8, $58
    db $04, $88, SLOT1, ENT_ITM_HEARTSMALL,  $a8, $20
    db $05, $68, SLOT0, ENT_ITM_HEARTBIG,    $a8, $20
    db $06, $48, SLOT1, ENT_ITM_WHIP_FIRE,   $a8, $58
    db $06, $68, SLOT2, ENT_ITM_COIN,        $a8, $20
    db $07, $18, SLOT0, ENT_ITM_HOLY,        $a8, $20
    ROOM
    db $04, $68, SLOT1, ENT_ITM_HEARTSMALL,  $a8, $24
    db $05, $28, SLOT2, ENT_ITM_COIN,        $a8, $58
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $18, $18
    db           SLOT2, ENT_ITM_COIN,        $68, $30
    ROOM_COMPRESSED
    db           SLOT1, ENT_ITM_WHIP_FIRE,   $48, $30
    db           SLOT0, ENT_ITM_AXE,         $68, $30
    db           SLOT2, ENT_WALL_1UP,        $78, $48
    ENDROOMS

org $5e43
banksk3
LvlPlant_4_Items:
    db $03, $28, SLOT0, ENT_WALL_1UP,        $b0, $48
    db $04, $20, SLOT1, ENT_ITM_HCROSS,      $b0, $30
    db $04, $40, SLOT3, ENT_ITM_COIN,        $b0, $30
    db $04, $68, SLOT0, ENT_ITM_WHIP_CHAIN,  $a8, $30
    ENDROOMS

org $5e5c
banksk3
LvlPlant_5_Items:
    ROOM
    db $07, $7c, SLOT3, ENT_ITM_HCROSS,      $a8, $28
    db $09, $28, SLOT1, ENT_ITM_WHIP_FIRE,   $a8, $28
    db $09, $60, SLOT2, ENT_ITM_HEARTBIG,    $a8, $60
    ENDROOMS

org $5e70
banksk3
LvlCrystal_0_Items:
    db $04, $20, SLOT0, ENT_ITM_AXE,         $b0, $58
    db $04, $58, SLOT1, ENT_ITM_HEARTSMALL,  $b0, $28
    db $05, $90, SLOT3, ENT_ITM_COIN,        $b0, $58
    db $06, $30, SLOT0, ENT_ITM_HEARTBIG,    $b0, $58
    db $06, $70, SLOT1, ENT_ITM_HEARTSMALL,  $b0, $58
    db $07, $10, SLOT2, ENT_ITM_WHIP_FIRE,   $b0, $58
    ROOM
    db $04, $20, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $58
    db $04, $40, SLOT1, ENT_ITM_COIN,        $b0, $28
    db $05, $20, SLOT3, ENT_ITM_HEARTBIG,    $b0, $58
    db $05, $48, SLOT0, ENT_ITM_HOLY,        $a8, $28
    ENDROOMS

org $5eae
banksk3
LvlCrystal_1_Items:
    db $02, $60, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $28
    db $04, $08, SLOT2, ENT_ITM_COIN,        $b0, $28
    db $05, $18, SLOT1, ENT_ITM_HEARTSMALL,  $b0, $40
    db $06, $00, SLOT3, ENT_ITM_COIN,        $b0, $50
    db $06, $78, SLOT0, ENT_ITM_HEARTBIG,    $b0, $30
    db $07, $28, SLOT2, ENT_ITM_WHIP_FIRE,   $b0, $30
    db $07, $60, SLOT1, ENT_ITM_HCROSS,      $b0, $58
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_1UP,        $18, $18
    db           SLOT2, ENT_ITM_COIN,        $30, $1c
    db           SLOT3, ENT_ITM_HEARTSMALL,  $70, $2c
    ENDROOMS

org $5ee6
banksk3
LvlCrystal_2_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $40, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTSMALL,  $28, $28
    db           SLOT1, ENT_ITM_WHIP_FIRE,   $38, $58
    ROOM
    db $85, $20, SLOT0, ENT_ITM_COIN,        $3c, $88
    db $86, $40, SLOT2, ENT_ITM_HEARTSMALL,  $28, $90
    db $86, $40, SLOT3, ENT_ITM_COIN,        $50, $90
    db $87, $30, SLOT0, ENT_WALL_MEAT,       $38, $88
    db $88, $68, SLOT1, ENT_ITM_HCROSS,      $40, $88
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_1UP,        $58, $20
    db           SLOT2, ENT_WALL_MEAT,       $88, $38
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HOLY,        $76, $30
    db           SLOT1, ENT_WALL_MEAT,       $88, $18
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $28, $1c
    db           SLOT1, ENT_ITM_WHIP_FIRE,   $48, $2c
    db           SLOT2, ENT_ITM_COIN,        $68, $2c
    ENDROOMS

org $5f33
banksk3
LvlCrystal_3_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_CHAIN,  $30, $30
    db           SLOT1, ENT_ITM_COIN,        $50, $50
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $70, $5c
    db           SLOT1, ENT_WALL_MEAT,       $38, $68
    ROOM
    db $04, $70, SLOT0, ENT_ITM_COIN,        $b0, $34
    db $05, $60, SLOT3, ENT_ITM_HCROSS,      $b0, $34
    db $06, $70, SLOT2, ENT_ITM_WHIP_FIRE,   $b0, $34
    db $07, $08, SLOT0, ENT_ITM_HEARTBIG,    $a8, $34
    ROOM
    db $04, $12, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $2c
    db $05, $5c, SLOT1, ENT_ITM_HEARTBIG,    $b0, $30
    db $06, $18, SLOT2, ENT_ITM_HOLY,        $a8, $44
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $78, $20
    ENDROOMS

org $5f77
banksk3
LvlCrystal_4_Items:
    db $06, $08, SLOT0, ENT_ITM_WHIP_CHAIN,  $b0, $40
    db $07, $04, SLOT1, ENT_ITM_COIN,        $a8, $48
    db $07, $44, SLOT2, ENT_ITM_HEARTBIG,    $a8, $38
    ENDROOMS

org $5f8a
banksk3
LvlCloud_0_Items:
    db $07, $4c, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $4c
    db $07, $8c, SLOT1, ENT_ITM_HEARTSMALL,  $b0, $4c
    db $08, $2c, SLOT2, ENT_ITM_COIN,        $b0, $4c
    db $08, $6c, SLOT3, ENT_ITM_HEARTBIG,    $b0, $4c
    db $09, $0c, SLOT0, ENT_ITM_COIN,        $b0, $4c
    ENDROOMS

org $5fa9
banksk3
LvlCloud_1_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_CHAIN,  $28, $28
    db           SLOT1, ENT_ITM_HEARTBIG,    $78, $28
    ROOM
    db $07, $48, SLOT3, ENT_ITM_HHOLY,       $a8, $44
    db $07, $88, SLOT0, ENT_ITM_COIN,        $a8, $28
    db $08, $28, SLOT1, ENT_ITM_HEARTSMALL,  $a8, $48
    db $08, $68, SLOT2, ENT_ITM_HEARTSMALL,  $a8, $40
    db $0a, $77, SLOT0, ENT_ITM_AXE,         $a8, $20
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $30, $30
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $48, $68
    ENDROOMS

org $5fdc
banksk3
LvlCloud_2_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $7c, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_FIRE,   $72, $30
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HOLY,        $14, $58
    db           SLOT1, ENT_ITM_COIN,        $70, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $58, $18
    ENDROOMS

org $5ff5
banksk3
LvlCloud_3_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_CHAIN,  $44, $50
    db           SLOT1, ENT_ITM_HCROSS,      $5c, $50
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $34, $60
    db           SLOT1, ENT_ITM_HEARTSMALL,  $6c, $60
    ROOM
    db $85, $58, SLOT2, ENT_ITM_COIN,        $30, $90
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $58, $18
    db           SLOT2, ENT_ITM_HEARTBIG,    $44, $48
    db           SLOT3, ENT_ITM_WHIP_FIRE,   $5c, $48
    ENDROOMS

org $601c
banksk3
LvlCloud_4_Items:
    db $07, $04, SLOT0, ENT_ITM_WHIP_CHAIN,  $b0, $60
    db $07, $88, SLOT1, ENT_ITM_COIN,        $a8, $48
    db $08, $18, SLOT2, ENT_ITM_HEARTBIG,    $a8, $48
    db $09, $18, SLOT0, ENT_ITM_HEARTBIG,    $a8, $58
    db $09, $48, SLOT1, ENT_ITM_HCROSS,      $a8, $48
    db $09, $70, SLOT2, ENT_WALL_1UP,        $a8, $0a
    ENDROOMS

org $6041
banksk3
LvlRock_0_Items:
    db $07, $38, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $50
    db $07, $68, SLOT1, ENT_ITM_HCROSS,      $b0, $50
    db $08, $20, SLOT2, ENT_ITM_HEARTBIG,    $b0, $50
    db $08, $78, SLOT3, ENT_ITM_COIN,        $b0, $40
    db $09, $70, SLOT1, ENT_ITM_COIN,        $b0, $50
    db $0a, $30, SLOT2, ENT_ITM_HEARTSMALL,  $b0, $50
    db $0b, $40, SLOT3, ENT_ITM_COIN,        $b0, $40
    ENDROOMS

org $606c
banksk3
LvlRock_1_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $38, $30
    db           SLOT1, ENT_ITM_WHIP_CHAIN,  $70, $20
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTSMALL,  $30, $40
    ROOM
    db $09, $70, SLOT0, ENT_WALL_MEAT,       $a8, $08
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $50, $28
    ROOM
    db $09, $48, SLOT0, ENT_ITM_COIN,        $b0, $28
    db $0b, $60, SLOT1, ENT_ITM_COIN,        $b0, $30
    ENDROOMS

org $6094
banksk3
LvlRock_2_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_CHAIN,  $50, $30
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $40, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $70, $30
    ROOM_COMPRESSED
    db           SLOT1, ENT_ITM_COIN,        $70, $50
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_FIRE,   $50, $28
    db           SLOT1, ENT_WALL_MEAT,       $28, $08
    ENDROOMS

org $60b2
banksk3
LvlRock_3_Items:
    db $07, $40, SLOT3, ENT_ITM_HEARTBIG,    $b0, $50
    db $07, $50, SLOT0, ENT_ITM_COIN,        $b0, $30
    db $07, $80, SLOT1, ENT_ITM_HHOLY,       $b0, $50
    db $08, $58, SLOT2, ENT_ITM_HEARTBIG,    $b0, $50
    db $09, $00, SLOT0, ENT_ITM_HEARTBIG,    $b0, $50
    db $09, $40, SLOT1, ENT_ITM_WHIP_CHAIN,  $b0, $50
    db $0a, $08, SLOT2, ENT_ITM_HEARTBIG,    $a8, $50
    db $0a, $48, SLOT3, ENT_ITM_HEARTSMALL,  $a8, $30
    ROOM
    db $07, $70, SLOT0, ENT_ITM_COIN,        $b0, $30
    db $07, $78, SLOT1, ENT_WALL_1UP,        $b0, $18
    db $08, $68, SLOT3, ENT_ITM_COIN,        $b0, $30
    db $09, $18, SLOT0, ENT_ITM_HEARTBIG,    $b0, $30
    db $09, $90, SLOT1, ENT_ITM_HEARTBIG,    $a8, $50
    db $0a, $60, SLOT2, ENT_ITM_HEARTBIG,    $b0, $58
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $38, $18
    db           SLOT3, ENT_ITM_WHIP_FIRE,   $4c, $28
    db           SLOT2, ENT_ITM_AXE,         $70, $28
    ENDROOMS

org $6115
banksk3
LvlRock_4_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $46, $50
    db           SLOT1, ENT_ITM_WHIP_CHAIN,  $5a, $38
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $68, $68
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $48, $20
    db           SLOT1, ENT_ITM_HEARTBIG,    $70, $60
    ENDROOMS

org $612d
banksk3
LvlRock_5_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTSMALL,  $38, $38
    db           SLOT1, ENT_ITM_HEARTBIG,    $58, $28
    ROOM
    db $89, $50, SLOT0, ENT_ITM_WHIP_CHAIN,  $6c, $90
    db $8a, $60, SLOT2, ENT_ITM_WHIP_CHAIN,  $6c, $90
    db $8b, $40, SLOT1, ENT_ITM_HCROSS,      $6c, $90
    db $8d, $10, SLOT3, ENT_ITM_WHIP_CHAIN,  $6c, $90
    ENDROOMS

org $6150
banksk3
LvlDrac1_0_Items:
    db $00, $44, SLOT0, ENT_ITM_WHIP_FIRE,   $b0, $50
    db $00, $6e, SLOT1, ENT_ITM_COIN,        $b0, $50
    db $01, $9e, SLOT2, ENT_ITM_HEARTBIG,    $b0, $46
    db $02, $42, SLOT3, ENT_ITM_COIN,        $b0, $46
    db $03, $60, SLOT0, ENT_ITM_HEARTSMALL,  $b0, $48
    db $04, $30, SLOT2, ENT_ITM_COIN,        $b0, $48
    db $06, $00, SLOT0, ENT_ITM_HEARTSMALL,  $b0, $40
    db $06, $40, SLOT1, ENT_ITM_COIN,        $b0, $40
    db $08, $02, SLOT2, ENT_ITM_COIN,        $b0, $46
    ENDROOMS

org $6187
banksk3
LvlDrac1_1_Items:
    ROOM_COMPRESSED
    db           SLOT1, ENT_ITM_WHIP_CHAIN,  $68, $18
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $72, $20
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $40, $28
    db           SLOT1, ENT_WALL_MEAT,       $58, $08
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $58, $18
    ENDROOMS

org $61a0
banksk3
LvlDrac1_2_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_1UP,        $18, $48
    db           SLOT2, ENT_ITM_WHIP_FIRE,   $70, $50
    ROOM
    db $84, $50, SLOT0, ENT_ITM_HEARTBIG,    $70, $88
    db $85, $10, SLOT1, ENT_ITM_HHOLY,       $70, $88
    ROOM_COMPRESSED
    db           SLOT3, ENT_ITM_HCROSS,      $40, $18
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $68, $68
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $18, $58
    db           SLOT2, ENT_ITM_HEARTBIG,    $70, $58
    db           SLOT3, ENT_ITM_WHIP_FIRE,   $4e, $2c
    ENDROOMS

org $61ce
banksk3
LvlDrac1_3_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTSMALL,  $30, $48
    db           SLOT1, ENT_ITM_WHIP_CHAIN,  $60, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_COIN,        $48, $58
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $48, $18
    ROOM_COMPRESSED
    db           SLOT3, ENT_ITM_HCROSS,      $88, $18
    db           SLOT1, ENT_WALL_1UP,        $58, $08
    ENDROOMS

org $61eb
banksk3
LvlDrac1_4_Items:
    db $07, $58, SLOT1, ENT_ITM_COIN,        $b0, $48
    db $08, $40, SLOT2, ENT_ITM_HEARTBIG,    $b0, $48
    db $09, $00, SLOT3, ENT_ITM_WHIP_CHAIN,  $b0, $38
    ENDROOMS

org $61fe
banksk3
LvlDrac2_0_Items:
    db $07, $50, SLOT0, ENT_ITM_WHIP_FIRE,   $a8, $28
    db $08, $3c, SLOT1, ENT_ITM_HEARTBIG,    $a8, $20
    db $09, $74, SLOT2, ENT_ITM_COIN,        $a8, $38
    ENDROOMS

org $6211
banksk3
LvlDrac2_1_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTSMALL,  $43, $40
    db           SLOT1, ENT_ITM_WHIP_CHAIN,  $5d, $58
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HOLY,        $50, $18
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_AXE,         $58, $24
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $48, $70
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_CHAIN,  $50, $26
    db           SLOT1, ENT_ITM_HEARTBIG,    $88, $50
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $60, $30
    ENDROOMS

org $6238
banksk3
LvlDrac2_2_Items:
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_WHIP_FIRE,   $60, $30
    db           SLOT1, ENT_WALL_MEAT,       $18, $48
    ROOM
    db $82, $20, SLOT0, ENT_ITM_AXE,         $8c, $90
    db $83, $50, SLOT1, ENT_ITM_HEARTBIG,    $30, $90
    db $86, $3c, SLOT2, ENT_ITM_COIN,        $30, $90
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $30, $28
    ROOM_COMPRESSED
    db           SLOT0, ENT_ITM_HEARTBIG,    $70, $50
    db           SLOT1, ENT_WALL_1UP,        $48, $18
    ROOM_COMPRESSED
    db           SLOT0, ENT_WALL_MEAT,       $58, $18
    db           SLOT2, ENT_ITM_HEARTBIG,    $50, $58
    db           SLOT3, ENT_ITM_WHIP_FIRE,   $8c, $68
    ENDROOMS

org $6270
banksk3
LvlDrac2_3_Items:
    db $07, $74, SLOT0, ENT_ITM_WHIP_CHAIN,  $a8, $28
    db $08, $7c, SLOT1, ENT_ITM_COIN,        $a8, $40
    db $09, $55, SLOT2, ENT_ITM_HEARTBIG,    $a8, $40
    db $0b, $9c, SLOT3, ENT_ITM_HCROSS,      $a8, $18
    db $0d, $80, SLOT1, ENT_WALL_MEAT,       $a8, $38
    ENDROOMS

org $628f
banksk3
LvlDrac2_4_Items:
    db $07, $24, SLOT0, ENT_ITM_COIN,        $a8, $60
    db $08, $28, SLOT2, ENT_ITM_WHIP_CHAIN,  $a8, $64
    db $08, $60, SLOT0, ENT_ITM_HEARTBIG,    $a8, $64
    db $09, $64, SLOT1, ENT_ITM_HCROSS,      $a8, $60
    ENDROOMS

org $62a8
banksk3
LvlDrac3_0_Items:
    db $07, $54, SLOT2, ENT_ITM_AXE,          $b0, $40
    db $08, $34, SLOT1, ENT_ITM_WHIP_CHAIN,   $b0, $40
    db $09, $14, SLOT3, ENT_ITM_HCROSS,       $b0, $40
    db $0a, $38, SLOT0, ENT_ITM_WHIP_FIRE,    $b0, $40
    ENDROOMS
