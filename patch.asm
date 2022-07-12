if (rom_type == rom_jp) | (INERTIA)
    USE_ALTBANK: equ 1
    if rom_type == rom_jp
        ALTBANK7: equ 1
        ALTBANK1: equ 0
    else
        ALTBANK7: equ 0
        ALTBANK1: equ 1
    endif
else
    USE_ALTBANK: equ 0
endif

; RAM addresses
org $C886
input_held:

; insert into free space
org $3FF1+1
seek $
is_moving_downward:
    ld hl,$C010
    add a, (hl)
    and $F0
    ret
ld_speed_hack_velocity_r_cb:
    ld hl, speed_hack_velocity_r_cb
    jp read_word_cb
    
end_bank0:

; call bank after org, seeks to $ in given bank.
banksk:  macro n
    seek n ? (n - 1) * $4000 + $ : $
endm

banksk1: macro
    seek $4000 * (1-1) + $
endm

banksk6: macro
    seek $4000 * (6-1) + $
endm

banksk7: macro
    seek $4000 * (7-1) + $
endm

; z80asm seems to have trouble emitting ld a, ($imm) for some reason.
ldai16: macro addr
    db $FA
    defw addr
endm

pushhl: macro value
    ld hl, value
    push hl
endm

org $35A9
mbc_swap_bank_1:

org $35B5
mbc_swap_bank_6:

org $35BB
mbc_swap_bank_7:

org $3DAC
entity_set_x_velocity_0:

org $3DAF
entity_set_x_velocity:

org $3DB7
entity_set_y_velocity:

org $3DBE
entity_get_x_velocity:

org $3DBA
write_word_cb:

org $3DC8
read_word_cb:

; belmont update jumptable
org $4235+2*3
banksk6
dw new_jump_routine

org $4293
belmont_update_jump:

org $4627
input_leftright_held:

org $4771
speed_hack_velocity_r_cb:

org $477C
speed_hack_velocity_l_cb:

org $480d
banksk6
belmont_set_hvelocity_from_input:
    call input_leftright_held
    ret z
    nop

org $4817
banksk6
    call ld_speed_hack_velocity_r_cb
    
org $4823
banksk6
    call ld_speed_hack_velocity_l_cb

org $4822
ret_4822:

; insert into free space
if rom_type == rom_us
    org $7FBC+1
endif
if rom_type == rom_jp
    org $7FE4+1
endif
banksk6

ld_speed_hack_velocity_l_cb:
    ld hl, speed_hack_velocity_l_cb
    jp read_word_cb

new_jump_routine:

if USE_ALTBANK
        ; longcall to alt bank, then return to bank 6, belmont_update_jump
        pushhl belmont_update_jump
        pushhl mbc_swap_bank_6
        pushhl lr_ctrl
        
        if ALTBANK7
            jp mbc_swap_bank_7
        else
            jp mbc_swap_bank_1
        endif
    end_bank6:

    if ALTBANK7
        ; insert into free space
        org $7F8C+1
        banksk7
    else
        ; insert into free space
        org $7E7D+1
        banksk1
    endif
endif

lr_ctrl:
    ld l, 2
    ld h, d
    bit 1, (hl)
    jr z, new_jump_routine_exec
    xor a
    call is_moving_downward
    
if USE_ALTBANK
    ret nz
else
    jr nz, new_jump_routine_return
endif

    
new_jump_routine_exec:

if INERTIA
    ; store previous x velocity
    call entity_get_x_velocity
    push bc
endif

    ; push facing; c <- 9
    ld e, 9
if USE_ALTBANK != 1
    ld c, e
endif
    ld a, (de)
    push af

if USE_ALTBANK
        ldai16 input_held
        pushhl fin_set_lrspeed
        and 3
        jp z, entity_set_x_velocity_0
        
        if ALTBANK7
            pushhl mbc_swap_bank_7
        else
            pushhl mbc_swap_bank_1
        endif
        pushhl belmont_set_hvelocity_from_input
        jp mbc_swap_bank_6

    fin_set_lrspeed:
else
    call belmont_set_hvelocity_from_input
        
        ; check if c was changed (bit 0 will not be 1 anymore)
        bit 0, c
        
        ; if c was not changed, set x velocity to 0
        call nz, entity_set_x_velocity_0
endif
    
    ; a <- substate. if not attacking, don't reset facing.
    pop bc
    ld e, 2
    ld a, (de)
    or a
    jr z, fin_lr_ctrl
    
    ; restore previous facing
    ld h, d
    ld l, 9
    ld (hl), b
fin_lr_ctrl:

if INERTIA
    ; bc <- new velocity
    call entity_get_x_velocity
    
    ; hl <- previous velocity
    pop hl
    push hl
    
    ; hl <- hl - bc
    dec bc
    ld a,c
    cpl
    ld c,a
    ld a,b
    cpl
    ld b,a
    add hl, bc
    
    bit 7, h ; z <- ~ sign of (prev - new)
    pop bc ; hl <- previous velocity
    jr nz, new_gt_prev
new_lte_prev:
    xor a
    or l
    or h
    
    jr z, fin_inertia ; equal; skip.
    ld hl,$FFF0
    db $CA ; skip next 2 bytes of instruction.
    
new_gt_prev:
    ld hl,$0010

; new velocity <- hl
add_bc_to_hl_and_assign_to_xvelocity:
    add hl, bc
    ld b, h
    ld c, l
    call entity_set_x_velocity
    
fin_inertia:
endif

if VCANCEL == 1
    vcancel:
        ldai16 $C886
        and $10
    
    if USE_ALTBANK
        ret nz
    else
        jr nz, fin_vcancel
    endif
        
        ; check if moving downward
        ld a, 1
        call is_moving_downward
    if USE_ALTBANK
        ret z
    else
        jr z, fin_vcancel
    endif
        
        ; zero velocity
        ld bc, $FF00
        call entity_set_y_velocity
        
    fin_vcancel:
endif

if USE_ALTBANK
        ret
    
    if ALTBANK7
        end_bank7:
    else
        end_bank1:
    endif
else
new_jump_routine_return:
        jp belmont_update_jump

    end_bank6:
endif