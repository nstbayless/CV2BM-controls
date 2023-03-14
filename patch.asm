if rom_type == rom_kgbc4eu
    USE_ALTBANK: equ 0
    KGBC4EU_LAYOUT: equ 1
    ALTBANK1: equ 0
    ALTBANK7: equ 0
else
    if (rom_type == rom_jp) | (INERTIA)
        USE_ALTBANK: equ 1
        KGBC4EU_LAYOUT: equ 0
        if rom_type == rom_jp
            ALTBANK7: equ 1
            ALTBANK1: equ 0
        else
            ALTBANK7: equ 0
            ALTBANK1: equ 1
        endif
    else
        KGBC4EU_LAYOUT: equ 0
        USE_ALTBANK: equ 0
    endif
endif

if INERTIA
    ADJUST_DRAGON_PHYSICS: equ 1
else
    ADJUST_DRAGON_PHYSICS: equ 0
endif

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

banksk16: macro
    seek $4000 * (0x16-1) + $
endm

banksk19: macro
    seek $4000 * (0x19-1) + $
endm

; RAM addresses
org $C886
input_held:

; insert into free space

if KGBC4EU_LAYOUT
    org $76C0
    banksk19
else
    org $3FF1+1
    seek $
endif

is_moving_downward:
    ld hl,$C010
    add a, (hl)
    and $F0
    ret

if KGBC4EU_LAYOUT
    
    org $2339
    read_word_cb:
else
    ld_speed_hack_velocity_r_cb:
        ld hl, speed_hack_velocity_r_cb
        jp read_word_cb
    end_bank0:
endif

; z80asm seems to have trouble emitting ld a, ($imm) for some reason.
ldai16: macro addr
    db $FA
    defw addr
endm

pushhl: macro value
    ld hl, value
    push hl
endm

if KGBC4EU_LAYOUT
    ; clobbers b
    ; calls [hl] in bank (c).
    ; returns to caller.
    org $09B7
    mbc_call_bank:
    
    ; push new address
    ; a <- bank
    ; jmp here.
    org $082F
    mbc_swap_bank:
    
    org $42A2
    banksk16
    belmont_update_jump:
        call new_jump_routine_trampoline
    
    org $4878
    banksk16
        ; patch space: 34 bytes
        ; patch: 8 bytes
        ld hl, belmont_set_hvelocity_from_input
        ld c, $19
        jp mbc_call_bank
        
    ld_speed_hack_velocity_l_cb:
        ; patch: 6 bytes
        ld hl, $47E5
    _jprwcb:
        jp read_word_cb
        
    ld_speed_hack_velocity_r_cb:
        ; patch: 5 bytes
        ld hl, $47DA
        jr _jprwcb
        
    new_jump_routine_trampoline:
        ; patch: 13 bytes
        ld hl, new_jump_routine
        ld c, $19
        call mbc_call_bank
        ldai16 $C002
        ret
        
        nop
        nop
        nop
        nop
        ; ret
        
    org $2324
    entity_set_x_velocity_0:

    org $2327
    entity_set_x_velocity:
    
    org $2332
    write_word_cb:

    org $232F
    entity_set_y_velocity:

    org $2336
    entity_get_x_velocity:
    
else
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

endif; ! KGBC4EU_LAYOUT

; insert into free space
if KGBC4EU_LAYOUT
    org $76D0
    banksk19
endif
if rom_type == rom_us
    org $7FBC+1
    banksk6
endif
if rom_type == rom_jp
    org $7FE4+1
    banksk6
endif

if KGBC4EU_LAYOUT

    belmont_set_hvelocity_from_input_or_0:
        ldai16 $C886
        and $3
        jp z, entity_set_x_velocity_0
    
    belmont_set_hvelocity_from_input:
        ld c, $16
        ldai16 $C886
        and $03
        cp  $02
        jp z, _left
        
    _right:
        ld hl, ld_speed_hack_velocity_r_cb
        call mbc_call_bank
        call entity_set_x_velocity
        ld hl, $C009
        res 5, (hl)
        ret
    
    _left:
        ld hl, ld_speed_hack_velocity_l_cb
        call mbc_call_bank
        call entity_set_x_velocity
        ld hl, $C009
        set 5, (hl)
        ret
else
    ld_speed_hack_velocity_l_cb:
        ld hl, speed_hack_velocity_l_cb
        jp read_word_cb
endif

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
if (USE_ALTBANK != 1) & (KGBC4EU_LAYOUT == 0)
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
        
    if KGBC4EU_LAYOUT
        call belmont_set_hvelocity_from_input_or_0
    else
        call belmont_set_hvelocity_from_input
        
        ; check if c was changed (bit 0 will not be 1 anymore)
        bit 0, c
        
        ; if c was not changed, set x velocity to 0
        call nz, entity_set_x_velocity_0
    endif
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
    if KGBC4EU_LAYOUT
            ; adjusted first 7 bytes of normal jump routine, which were overwritten.
            ld hl, $43E3
            ld c, $16
            
            ld a, $(C002)
            dec a
            
            jp nz, mbc_call_bank
            ret
        end_bank19:
    else
            jp belmont_update_jump

        end_bank6:
    endif
endif