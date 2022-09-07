if rom_type == rom_kgbc4eu
    USE_ALTBANK: equ 0
    KGBC4EU_LAYOUT: equ 1
    ALTBANK1: equ 0
    ALTBANK7: equ 0
else
    if 1
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

UPDATE_GFX_VBLANK: equ 0

; call bank after org, seeks to $ in given bank.
banksk:  macro n
    seek n ? (n - 1) * $4000 + $ : $
endm

banksk0: macro
    seek $
endm

banksk1: macro
    seek $4000 * (1-1) + $
endm

banksk3: macro
    seek $4000 * (3-1) + $
endm

banksk4: macro
    seek $4000 * (4-1) + $
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

; z80asm seems to have trouble emitting ld a, ($imm) for some reason.
ldai16: macro addr
    db $FA
    defw addr
endm

ldi16a: macro addr
    db $EA
    defw addr
endm

pushhl: macro value
    ld hl, value
    push hl
endm

; RAM addresses
org $C886
input_held:

org $C8D0
current_subweapon:

; insert into free space

if KGBC4EU_LAYOUT
    org $76C0
    banksk19
else
    org $3FF1+1
    banksk0
    
    if CONTROL | SUBWEAPONS
        ; we reserve this regardless of CONTROL or SUBWEAPONS.
        intercept_clear_subweapon_gfx:
            xor a
            ldi16a subweapon_gfx_loaded
            jp $2E57
    endif

endif


if CONTROL
    if KGBC4EU_LAYOUT
        org $2339
        read_word_cb:
    else
        ld_speed_hack_velocity_r_cb:
            ld hl, speed_hack_velocity_r_cb
            jp read_word_cb
        end_bank0:
    endif
endif

; bits 0-1: subweapon gfx in slot 0 (ALT)
; bits 4-5: subweapon gfx in slot 1 (CURRENT)
; bit 6: is 1 if allocated at all (differentiates from full byte 0, i.e. unloaded)
; bit 7: is 1 if refresh is needed next vblank.
org $C3E8
subweapon_gfx_loaded:

; part of hram used to transfer subweapon gfx
org $FFB0
subweapon_gfx_buffer:

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
    
    if CONTROL
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
    endif
        
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
    org $0c52
    unk_0c52:
    
    org $0D9E
    pop_hl_ret:
    
    org $11D8
    pop_de_ret:
    
    org $28a3
    load_c882_and_F:

    org $2950
    unk_2950:
    
    org $297b
    leftshift_bc_4:
    
    org $2AC7
    wait_for_blank:
    
    org $3553
    unk_3553:
    
    org $39f0
    unk_39f0:
    
    org $3D70
    unk_3d70:
    
    org $35Ab
    mbc_swap_bank_a:

    org $35A9
    mbc_swap_bank_1:

    org $35B5
    mbc_swap_bank_6:

    org $35BB
    mbc_swap_bank_7:
    
    org $35C1
    mbc_swap_bank_3:
    
    org $38B0
    entity_animate:
    
    org $38E0
    ; sets animation to (bc):(bc+1)
    entity_set_animation:
    
    org $3DCC
    entity_reset_bit_0_prop_13_0E:
    
    ; BC gets B+X position, C+Y position
    org $3C0A
    entity_get_position_with_offset:
    
    org $3C14
    entity_get_position_with_offset_times_direction:
    
    org $3D98
    entity_set_position:
    
    org $3DA0
    entity_set_velocity_times_direction:

    org $3DAC
    entity_set_x_velocity_0:

    org $3DAF
    entity_set_x_velocity:

    org $3DB7
    entity_set_y_velocity:

    org $3DBE
    entity_get_x_velocity:
    
    org $3DD6
    entity_get_y_velocity:
    
    ; x velocity += bc
    org $3D82
    entity_add_x_velocity:
    
    ; y velocity += bc
    org $3D8C
    entity_add_y_velocity:

    org $3DBA
    write_word_cb:

    org $3DC8
    read_word_cb:

    if CONTROL
        ; belmont update jumptable
        org $4235+2*3
        banksk6
        dw new_jump_routine
    endif

    org $4293
    belmont_update_jump:

    org $4627
    input_leftright_held:

    org $4771
    speed_hack_velocity_r_cb:

    org $477C
    speed_hack_velocity_l_cb:

    if CONTROL
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
    endif

    org $4822
    ret_4822:
    
    org $482F
    axe_animation:
    
    org $499b
    unk_499b:
    
    org $49a3
    ; TODO: confirm this!
    entity_despawn:
    
endif; ! KGBC4EU_LAYOUT

; insert into free space
if KGBC4EU_LAYOUT
    org $76D0
    banksk19
endif
if rom_type == rom_us
    org $7FBC+1
    banksk6
    
    if 1
    ; only used by SUBWEAPONS, but reserved regardless
    axe_cross_update_unk:
        call entity_animate
        call load_c882_and_F
        ld a, $1F
        call z, unk_3553
        ret
        
    become_flame:
        ; return
        pushhl mbc_swap_bank_6
        
        ; image <- fire frame 0
        ld a, $08
        db $D7 ; rst 10
        
        call entity_get_y_velocity
        
        ; timer <- $50
        ld a, $50
        db $DF ; rst 18 
        
        ; $C02B <- 0
        xor a
        ldi16a $C02B
        
        ; increment state
        db $F7 ; rst 30
        
        ld a, $19
        jp unk_3553
    endif
        
        
endif
if rom_type == rom_jp
    org $7FE4+1
    banksk6
endif

if CONTROL
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
        
        ld hl,$C010
        add a, (hl)
        and $F0
        
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
            
            ; is moving downward
            ld hl,$C010
            add a, (hl)
            and $F0
            
        if USE_ALTBANK
            ret z
        else
            jr z, fin_vcancel
        endif
            
            ; zero velocity
            ld bc, $FF00
            
            if USE_ALTBANK
                jp entity_set_y_velocity
            else
                call entity_set_y_velocity
            endif
            
        fin_vcancel:
    endif

    if USE_ALTBANK
        if VCANCEL == 0
            ret
        endif
        
        if ALTBANK7
            end_bank7:
        else
            if SUBWEAPONS == 0
                end_bank1:
            endif
        endif
    else
        new_jump_routine_return:
        if KGBC4EU_LAYOUT
                ; adjusted first 7 bytes of normal jump routine, which were overwritten.
                ld hl, $43E3
                ld c, $16
                
                ldai16 $C002
                dec a
                
                jp nz, mbc_call_bank
                ret
            end_bank19:
        else
                jp belmont_update_jump

            end_bank6:
        endif
    endif
endif

if SUBWEAPONS
    if rom_type == rom_us
        
        org $0033
        banksk0
    axe_update:
        ; [5 bytes available]
        db $C7 ; rst 0
        dw axe_update_spawn
        dw axe_update_air
        
        org $1D
        banksk0
        ; [3 bytes available]
        vblank_tramp_2:
            jp mbc_swap_bank_1
        
        ; vblank
        org $0040
        banksk0
        di
        push af
        push bc
        push de
        push hl
        jr vblank_start
        
        org $4B
        banksk0
        vblank_tramp_0:
            ; [5 bytes available]
            ret z
            push de
            push hl
            jr vblank_tramp_1
        
        org $50
        banksk0
            db $d9; reti
            ; [7 bytes available]
        cross_animation:
            db $04, $0D, $04, $0E, $04, $0F, $FE
        
        org $58
        banksk0
            db $d9; reti
        vblank_tramp_1:
            ; [7 bytes available]
            pushhl vblank_intercept
            jp mbc_swap_bank_1
        
        org $60
        banksk0
            db $d9; reti
            
        ; [7 bytes available]
    vblank_tramp_a:
        ld hl, subweapon_gfx_loaded
        bit 7, (hl)
        jr vblank_tramp_0
        ; [end 7 bytes]
        
    vblank_start:
        ; lcdc
        ld hl, $FF40
        res 0, (hl)
        res 1, (hl)
        
        ; unknown $DEC2
        ld hl, $DEC2
        inc (hl)
        
        ; note that $3Df8 is basically space
        ; we can replace RST 30 with it.
        
        org $F2
        banksk0
            
    copy_to_hram:
        ; copy r%e bytes to destination, then return to bank 1.
        
        push bc
        pop hl
        ld bc, subweapon_gfx_buffer ; note: b is unused here.
    copy_loop:
        db $2a ; ld a, (hl+)
        db $e2 ; ld (c), a
        ;ld (bc), a
        inc c
        dec e
        jr nz, copy_loop
        jp mbc_swap_bank_1
        
        org $0B59
        banksk0
        call intercept_load_entity
        call $0002
        
        org $2E48
        banksk0
        call intercept_clear_subweapon_gfx
        
        org $3889
        banksk0 
        call intercept_apply_subweapon
        
        org $6F19
        banksk3
        call intercept_draw_sprite
        
        org $6F4D
        draw_sprite:
        
        org $6F51
        draw_sprite_hl:
        
        
        org $4292
        axe_sprite_0:
        
        org $4299
        axe_sprite_1:
        
        org $42a2
        axe_sprite_2:
        
        org $42ab
        axe_sprite_3:
    endif

    if rom_type == rom_us
        org $49B7
        banksk6
    endif
    
if 1
    subweapon_dispatch:
        call vblank_tramp_a
        ; a, e <- 0
        xor a
        ld e, a
        
        call $002
        dw _ret_ ; (ret)
        dw axe_update
        dw holywater_update
        dw cross_update
        
    holywater_update:
        db $C7 ; rst 0
        dw holywater_update_spawn
        dw holywater_update_air
        dw holywater_update_fire
        
    cross_update:
        db $C7 ; rst 0
        dw cross_update_spawn
        dw cross_update_air
        dw cross_update_air
        
    spawn_common:
        ; check if animation is 1
        ldai16 $C00B
        dec a
        jp nz, pop_hl_ret
        
        ; set prop 8 to 1
        inc a
        ld e, $08
        ld (de), a ; CONFIRM
        
        ; copy belmont facing
        inc e
        ldai16 $C009
        set 0, a
        set 4, a
        ld (de), a
        
        ; set position to belmont offset by bc
        push de
        ld d, $C0
        call entity_get_position_with_offset_times_direction
        pop de
        call entity_set_position
        
        ; increment state
        db $f7 ; rst 30
        
        ; misc./unk.
        jp entity_reset_bit_0_prop_13_0E
        
    holywater_update_spawn:
        ; compare $49CA in base rom
        ld bc, $0800 ; (position offset)
        call spawn_common
        
        ; $C02b <- 0
        xor a
        ldi16a $C02B
        
        ld a, $0C
        db $D7; rst 10
        
        ld bc, $FE00
        call entity_set_y_velocity
        ld bc, $0100
    jp_entity_set_velocity_times_direction:
        jp entity_set_velocity_times_direction
    
    cross_update_spawn:
        ; compare: JP rom, 06:4a64
        ld bc, $08FA ; (position offset)
        call spawn_common
        
        ld bc, cross_animation
    cross_axe_end: ; common ending for cross/axe spawn routine
    
        ; set animation
        call entity_set_animation
        
        ld bc, $0140 ; velocity, not accounting for direction?
        jr jp_entity_set_velocity_times_direction
        
    axe_update_spawn:
        ; compare $4a64 in base rom
        ld bc, $08F8 ; (position offset)
        call spawn_common
        
        ; set prop $1f to $03
        ; (unknown)
        ld e, $1F
        ld a, $03
        ld (de), a
        
        ld bc, $FC00
        call entity_set_y_velocity
        
        ld bc, axe_animation
        jr cross_axe_end
    
    holywater_update_fire:
        ; compare $4a42 in ROM
        xor a
        ldi16a $C02B
        call $49a9
        call $3B80
        jr z, jp_entity_despawn
        call unk_0c52_and_despawn_if_0
        jp $3C5C
        
    unk_0c52_and_despawn_if_0:
        call $0C52
        ld e, $00
        ld a, (de)
        or a
        ret nz
        pop af
    jp_entity_despawn:
        jp entity_despawn
    
    gravity:
        ld bc, $0030
        ; if prop 10 != 4, apply gravity
        ld e, $10
        ld a, (de)
        cp $04
        call nz, entity_add_y_velocity
    _ret_:
        ret
        
    holywater_update_air:
        ; compare 4a01 in base ROM
        call $49a9
        call gravity
        call unk_0c52_and_despawn_if_0
        
        ldai16 $C02B
        or a
    jp_nz_become_flame:
        jp nz, become_flame
        
        ; ret if y + 8 >= $80
        ld bc, $0008
        call entity_get_position_with_offset
        ld a, c
        cp $80
        ret nc
        
        ; unknown...
        call $3F2F
        bit 0, a
        ret z
        jr jp_nz_become_flame
    
    axe_update_air:
        ; compare $4a9f in base ROM
        call $49a9
        ld hl, axe_animation
        call axe_cross_update_unk
        call gravity
        call unk_0c52
        
    ; bounds check.
        ; a <- y position
        db $FF ; rst 38
        cp $A0
        jr c, _skip_axe_bounds_check
        cp $B0
        jr c, jp_entity_despawn
    _skip_axe_bounds_check:
        db $e7 ; rst 20 (get x position)
        cp $a0
        ret c
        cp $F0
        ret nc
        jr jp_entity_despawn
        
    cross_update_air:
        ; compare JP 06:4a97
        call $49a9
        call unk_0c52_and_despawn_if_0
        ld hl, cross_animation
        call axe_cross_update_unk
        ldai16 $C301
        dec a
        jr z, cross_update_forward
        
    cross_update_backward:
        ld h, $C0
        call unk_39f0
        jr c, jp_entity_despawn
        ld e, $00
        ld a, (de)
        or a,
        jr z, jp_entity_despawn
        ret
        
    cross_update_forward:
        db $E7; rst 20
        cp $98
        jr nc, label_4abe
        cp $08
        jr c, label_4abe
        ret
    label_4abe:
        ; switch to 'return' state
        db $F7; $rst 30
        jp unk_3d70
    
    ; MUST BE <= $4AD2
    end_subweapon_region:
else
    axe_update_spawn:
    axe_update_air:
endif
    
    if rom_type == rom_us
        org $7ef0 ; IMPORTANT -- this value is in build.sh as well. Must update both.
        banksk1
    endif
    
    ; clobbers everything
    intercept_apply_subweapon:
        call convert_subweapon
        ldi16a current_subweapon
        jr allocate_subweapon_gfx_asub
    
    intercept_load_entity:
        ;(existing code)
        res 7, a
        ld (de), a
        
        ; preserve de.
        push de
        pushhl pop_de_ret
        
        ; b <- a.
        ld b, a
        
        ; if subweapon_gfx_loaded is fully 0, then we must refresh.
        ldai16 subweapon_gfx_loaded
        or a
        jr z, allocate_subweapon_gfx
        
        ; check if d in range d4-d7 inclusive
        ; if so, this isn't a lantern, so we quit.
        ld a, $d4
        cp d
        ret c
        ld a, $d8
        cp d
        ret nc
        
        ; check that lantern has subweapon
        ld a, $1
        cp b
        jr z, allocate_subweapon_gfx
        inc a
        cp b
        ret nz
        
        ; fallthrough
        
    allocate_subweapon_gfx:
        ldai16 current_subweapon
    allocate_subweapon_gfx_asub:
        dw $37CB ; swap A
        or $C0 ; "needs update" flag and "is allocated" flag
        ld hl, subweapon_gfx_loaded
        ld (hl), a
        
        ; scan through lanterns to find what other subweapons are there
        ; check lanterns, which are at indices d4, d5, d6, and d7.
        ld de, $d300
    loopnext:
        inc d
        ld a, $d8
        cp d
        ret z
        
        ; check if value is 1 or 2
        ld a, (de)
        or a
        jr z, loopnext
        cp $3
        jr nc, loopnext
        
        ; b <- index of subweapon
        call convert_subweapon
        ld b, a
        
        ; check against gfx slot 0 (ALT)
        ld a, (hl)
        and $03
        jr z, assign
        cp b
        jr z, loopnext
        
        ; does not match slot 0 (ALT)
        ; sadly replace this lantern with a small consolation heart.
        ld a, $5
        ld (de), a
        jr loopnext
    
    assign:
        ld a, (hl)
        or b
        ld (hl), a
        jr loopnext
    
        
    convert_subweapon:
        ; a -> a
        ; converts subweapon 1 to either 1 or 3 depending on value of d.
        cp $1
        ret nz
        
        ; if d%2==1
        bit 0, d
        ret z
        
        ld a, $3
        ret
        
    cross_graphics_b:
        db $00, $00, $00, $00, $70, $00, $FC, $70
        db $EF, $5C, $DB, $67, $76, $39, $3F, $0C
    cross_graphics_c:
        db $0D, $06, $0F, $04, $1b, $0d, $1d, $0b
        db $37, $1a, $3b, $16, $3e, $1c, $1c, $00
        
    ; input: b,c are vram slots to page into
    ; a is which item to load
    ; 0 = none
    ; 1 = axe
    ; 2 = holy water
    ; 3 = cross
    ; 4 = none
    ; 5 = axe
    ; 6 = holy water (projectile)
    ; 7 = cross (projectile)
    page_in_subweapon_gfx:
        push bc
        and $03
        call $003
        dw pop_hl_ret
        dw page_in_axe
        dw page_in_holywater
        dw page_in_cross
    
    ; transfers $20 bytes from subweapon_gfx_buffer in hram to vram slot given by register c
    
    transfer_buff_to_vram:
        ld hl, subweapon_gfx_buffer
    transfer_to_vram:
        ld e, $20
        
    transfer_to_vram_x:
        ; transfers r%e-1 bytes from (hl...) to (bc...)
        ld b, $08
        call leftshift_bc_4
        
        if UPDATE_GFX_VBLANK == 1
            loop_top:
                db $2a ; ld a, (hl+)
                ld (bc), a
                inc c ; inc bc would be more correct, but this is faster.
                dec e
                jr nz, loop_top
            loop_bottom:
                ret
        else
            loop_top:
                ; we write 2 bytes each loop during hblank.
                ; it looks like we could even have time to write 4,
                ; but this works so let's play it safe.
                db $2a ; ld a, (hl+)
                call wait_for_blank
                ld (bc), a
                inc c ; inc bc would be more correct, but this is faster.
                db $2a ; ld a, (hl+)
                ld (bc), a
                inc c
                dec e
                dec e
                jr nz, loop_top
            loop_bottom:
                ei ; combine into reti?
                ret
        endif
        
        
    page_in_cross:
        ld hl, cross_graphics_b
        pop bc
        if UPDATE_GFX_VBLANK == 0
            di
        endif
        jr transfer_to_vram
    
    page_in_holywater:    
        ld bc, $4860
        ld de, $4840
        jr page_in_direct
    page_in_axe:
        ld bc, $4820
        ld de, $4800
    page_in_direct:
        call copy_from_bank4
        
        pop bc
        push bc
        ld c, b
        push de
        call transfer_buff_to_vram
        pop bc
        
        call copy_from_bank4
        pop bc
        jr transfer_buff_to_vram
        ret
        
    vblank_intercept:
        
        ; hl <- subweapon_gfx_loaded
        pop hl 
        ld a, (hl)
        
        ; check that there is enough room on the stack for this operation
        ; $48 bytes should suffice.
        ; db $f8, $80-$48
        ; jr nc, vblank_intercept_return
        ld hl, subweapon_gfx_loaded
        
        ; clear 'dirty' flag 
        res 7, (hl)
        
        ; load ALT graphics into 84,86
        push af
        ld bc, $8684
        call page_in_subweapon_gfx
        
        ; load ACTIVE graphics into $80,82
        pop af
        dw $37CB ; swap A
        push af
        ld bc, $8280
        call page_in_subweapon_gfx
        
        pop af
        
    vblank_intercept_return:
        ; pop and return return
        pop de
        jp mbc_swap_bank_6
    
    copy_from_bank4:
        push de
        pushhl pop_de_ret
        pushhl copy_to_hram
        ld e, $20
        ld a, $4
        if UPDATE_GFX_VBLANK == 0
            di
        endif
    jp_to_mbc_swap_bank_a:
        jp mbc_swap_bank_a
    
    end_bank1:
    
    org $7f7f+1
    banksk3
    
        ; TODO -- replace holy water icon sprite.
    
    intercept_draw_sprite:
        ld a, $c3
        cp h
        call z, substitute_sprite
        ld a, (hl)
        jp draw_sprite
    
    substitute_sprite:
        ; only substitute sprites D through 10
        ld a, (hl) ; a <- sprite index
        cp $d
        ret c
        cp $11
        ret nc
        
        ; only substitue if it's the cross
        ld e, $0
        ld d, h
        ld a, (de)
        cp $3
        ret nz
        
        ; ok, let's substitute.
        ld a, (hl)
        pop hl ; remove return address
        ld h, $7F
        add a
        add cross_sprite_table - $7F00 - 2*$D
        ld l, a
        jp draw_sprite_hl
    
    cross_sprite_table:
        dw cross_sprite_2
        dw cross_sprite_1
        dw cross_sprite_0
        dw cross_sprite_1
    
    cross_sprite_0:
        db $2 ; number of images
        db $f8, $f8, $80
        db $f8, $00, $81
        db $60 ; flags
        
    cross_sprite_1:
        db $2 ; number of images
        db $f8, $f8, $7C
        db $f8, $00, $7D
        db $60 ; flags
        
    cross_sprite_2:
        db $2 ; number of images
        db $f8, $f8, $81
        db $40 ; flags
        db $f8, $00, $81
        db $20 ; flags
    
    ; MUST BE <= $7FCF
    end_bank3:
endif