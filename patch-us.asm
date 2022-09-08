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

pushbc: macro value
    ld bc, value
    push bc
endm

pushde: macro value
    ld de, value
    push de
endm

ldiahl: macro
    db $2A
endm

ldihla: macro
    db $22
endm

; RAM addresses
org $C886
input_held:

org $C8D0
current_subweapon:

; insert into free space
org $3FF1+1
banksk0

if CONTROL
    ld_speed_hack_velocity_r_cb:
        ld hl, speed_hack_velocity_r_cb
        jp read_word_cb
    end_bank0:
endif

; bits 0-1: subweapon gfx in slot 0 (ALT)
; bits 4-5: subweapon gfx in slot 1 (CURRENT)
; bit 6: is 1 if allocated at all (differentiates from full byte 0, i.e. unloaded)
; bit 7: is 1 if refresh is needed next vblank.
org $C3E8
subweapon_gfx_loaded:

org $0c52
unk_0c52:

org $0D9E
pop_hl_ret:

org $11D8
pop_de_ret:

org $1248
xor_a_ret:

org $28a3
load_c882_and_F:

org $2950
unk_2950:

org $297b
leftshift_bc_4:

org $2AC7
wait_for_blank:

org $2EA1
; ld de, transfer buffer
; buffer should be separated by FE, terminated by FF
; initialized by *big-endian* vram destination address.
; scf before calling.
defer_vram_transfer:

org $2f39
load_hl_vram_copy_buffer:

org $3314
; copies r%b bytes from hl to de
copy_bytes_hl_to_de:

org $336B
; copies r%d bytes from bc to hl
copy_bytes_bc_to_hl:

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

org $4293
belmont_update_jump:

org $4627
input_leftright_held:

org $4771
speed_hack_velocity_r_cb:

org $477C
speed_hack_velocity_l_cb:

org $4822
ret_4822:

org $482F
axe_animation:

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

org $499b
unk_499b:

org $49a3
; TODO: confirm this!
entity_despawn:

org $c980
vram_transfer_buffer:

org $c88c
vram_transfer_index:

; PATCHES --------------------------------------------------------------------

if CONTROL
    ; belmont update jumptable
    org $4235+2*3
    banksk6
    dw new_jump_routine

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

if SUBWEAPONS
    org $1D
    banksk0
        ; [3 bytes available]
        vblank_tramp_2:
            jp mbc_swap_bank_1
    
    org $24
    banksk0
    swaporhl_ifnz:
        ;[4 bytes available]
        inc (hl)
        dec (hl)
        jr swaporhl_ifnz_b

    org $0033
    banksk0
    axe_update:
        ; [5 bytes available]
        db $C7 ; rst 0
        dw axe_update_spawn
        dw axe_update_air
    
    org $3C
    banksk0
    ; [4 bytes available]
    swaporhl_ifnz_b:
        jp nz, swaporhl
        ret
    
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
            ; [$E bytes available]
        subweapon_gfx_sources:
            ; (9 bytes)
            db $4
            dw $4800
            db $4
            dw $4840
            db $1
            dw cross_graphics_b
        swaporhl:
            ; [4 bytes]
            dw $37CB ; swap A
        orhl:
            or (hl)
            ret
        
        org $0B59
        banksk0
        call intercept_load_entity
        call $0002
        
        org $2E48
        banksk0
        ;call intercept_clear_subweapon_gfx
        
        org $3888
        banksk0 
        jp intercept_get_new_subweapon
        nop
    set_subweapon_icon:
        cp (hl) ; compare gfx loaded in slot 1 with current subweapon
        push de
        
    org $42CF
    banksk1
        call convert_subweapon
        nop 
        nop
        nop
        
    org $42D2
    banksk1
        db $B
        
    org $4647
    banksk6
        ; ret z if a is non-zero
        or a
        jp nz, xor_a_ret
        
    org $6F19
    banksk3
        call intercept_draw_sprite
        
    org $77AB
    banksk3
        ; don't reload the subweapon UI graphics on game start.
        ; instead, we mark for refresh.
        ldai16 current_subweapon
        call set_subweapon_gfx
endif

; BANK6 SUBWEAPONS REGION PATCH --------------------------------------------------------

if SUBWEAPONS
    org $49B7
    banksk6
    
    subweapon_dispatch:
        ; a, e <- 0
        call vblank_tramp_a
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
        call spawn_common_bank6
        
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
        call spawn_common_bank6
        
        ld bc, cross_animation
    cross_axe_end: ; common ending for cross/axe spawn routine
    
        ; set animation
        call entity_set_animation
        
        ld bc, $0140 ; velocity, not accounting for direction?
        jr jp_entity_set_velocity_times_direction
        
    axe_update_spawn:
        ; compare $4a64 in base rom
        ld bc, $08F8 ; (position offset)
        call spawn_common_bank6
        
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
endif

; BANK6 -------------------------------------------------------------------------

; insert into free space
org $7FBC+1
banksk6

if SUBWEAPONS
    spawn_common_bank6:
        pushhl spawn_common
        pushhl spawn_common_bank3
        jp mbc_swap_bank_3
        
    axe_cross_update_unk:
        call entity_animate
        call load_c882_and_F
        ld a, $1F
        call z, unk_3553
        ret
        
    become_flame:
        ; return
        ;pushhl mbc_swap_bank_6
        
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

if CONTROL
    ld_speed_hack_velocity_l_cb:
        ld hl, speed_hack_velocity_l_cb
        jp read_word_cb

    new_jump_routine:
        ; longcall to alt bank, then return to bank 6, belmont_update_jump
        pushhl belmont_update_jump
        pushhl mbc_swap_bank_6
        pushhl lr_ctrl
        jp mbc_swap_bank_1
endif
end_bank6:

; BANK1 -------------------------------------------------------------------------

; insert into free space
org $7E7D;+1
banksk1

if SUBWEAPONS
    ; we need this address to not cross pages.
    ; it makes math later easier.
    cross_graphics_b:
        db $00, $00, $00, $00, $70, $00, $FC, $70
        db $EF, $5C, $DB, $67, $76, $39, $3F, $0C
        db $0D, $06, $0F, $04, $1B, $0D, $1D, $0B
        db $37, $1A, $3B, $16, $3E, $1C, $1C, $00
    cross_graphics_c:
        db $38, $00, $7C, $38, $DC, $68, $EC, $58
        db $B8, $d0, $D8, $B0, $F0, $20, $B0, $60
        db $FC, $30, $6E, $9C, $DB, $E6, $F7, $3A
        db $3F, $0E, $0E, $00, $00, $00, $00, $00
endif

if CONTROL
    lr_ctrl:
        ld l, 2
        ld h, d
        bit 1, (hl)
        jr z, new_jump_routine_exec
        xor a
        
        ld hl,$C010
        add a, (hl)
        and $F0
        ret nz
        
    new_jump_routine_exec:

    if INERTIA
        ; store previous x velocity
        call entity_get_x_velocity
        push bc
    endif

        ; push facing;
        ld e, 9
        ld a, (de)
        push af
        
        ldai16 input_held
        pushhl fin_set_lrspeed
        and 3
        jp z, entity_set_x_velocity_0
        pushhl mbc_swap_bank_1
        pushhl belmont_set_hvelocity_from_input
        jp mbc_swap_bank_6

    fin_set_lrspeed:
        
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

    if VCANCEL
    vcancel:
        ldai16 $C886
        and $10
    
        ret nz
        
        ; check if moving downward
        ld a, 1
        
        ; is moving downward
        ld hl,$C010
        add a, (hl)
        and $F0
        
        ret z
        
        ; zero velocity
        ld bc, $FF00
        jp entity_set_y_velocity
    else
        ret
    endif
endif ; CONTROL

if SUBWEAPONS
    intercept_load_entity:
        ;(existing code)
        res 7, a
        ld (de), a
        
        ; check that this would be a weapon index
        cp $3
        ret nc
        
        ; preserve de.
        push de
        pushhl pop_de_ret
        
        ; check if d in range d4-d7 inclusive
        ; if so, this isn't a lantern, so we quit.
        ld a, $d3
        cp d
        ret nc
        ;ld a, $d8
        ;cp d
        ;ret c
        jr allocate_subweapon_gfx
        
    intercept_get_new_subweapon:
        ; preserve de
        push de
        pushhl pop_de_ret
        
        call convert_subweapon
        ldi16a current_subweapon
        ; fallthrough
        
    allocate_subweapon_gfx:
        ldai16 current_subweapon
        ld hl, $c300
        or a
        call z, orhl
        cp (hl)
        call nz, swaporhl_ifnz
        
        ; active goes in slot 1
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
    
        ; this function decides what lanterns are replaced with crosses.
    convert_subweapon:
        ; a -> a
        ; converts subweapon 1 to either 1 or 3 depending on value of d.
        cp $2
        ret nz
        
        ; if d%2==1
        bit 0, d
        ret z
        
        ld a, $3
        ret
        
    vblank_intercept_0:
        ld h, d
        ld l, e
        ld a, (hl)
        set 2, (hl)
        ld e, $40
        ; fallthrough
        
    ; input: $88e is vram address to store to
    ; b: load offset
    ; bits 012 of a is which item to load
    ; 0 = none
    ; 1 = axe
    ; 2 = holy water
    ; 3 = cross
    ; returns from interrupt
    page_in_subweapon_gfx:
        and $03
        jr z, vblank_intercept_return
        
        ; a <- 3A
        ld l, a
        add a
        add l
        
        ; hl <- subweapon_gfx_sources + 3*input
        ld hl, subweapon_gfx_sources-3
        db $ef; rst 28
        
        ldiahl
        push af ; bank to load from
            ; dangerous! 1-byte add to 2-byte value
            ldiahl
            add b
            ld c, a
            
            ld b, (hl)
            ; fallthrough
    
            ; input:
            ; bc: vram address to store to
            ; de: address to load from
            ; push: offset
            ; push: bank to load from
            ; transfers $20 bytes.
            transfer_buff_to_vram:
                call load_hl_vram_copy_buffer
            
            ; destination
            ld a, $88
            ldihla
            ld a, e
            ldihla
        
            ; stride <- 1
            xor a
            inc a
            ldihla
        pop af ; a <- source bank
        
        ; uses bc
        call _copy
        
        ld a, $FF ; terminal
        ldihla
        
        ; post-terminal 0
        xor a
        ld (hl), a
        
        ; update index
        ld a, l
        ldi16a vram_transfer_index
        
    vblank_intercept_return:
        pop de ; this is pushed by caller. mixed save/restore.
        jp mbc_swap_bank_6
        
    _copy:
        pushde mbc_swap_bank_1
        pushde copy_bytes_bc_to_hl
        ld d, $20
        jp mbc_swap_bank_a
        
    vblank_intercept_1:
        ld h, d
        ld l, e
        
        ; a <- subweapon
        ld a, (hl)
        set 3, (hl)
        ld b, $20
        ld e, $60
        jr page_in_subweapon_gfx
        
    vblank_intercept_2:
        ld h, d
        ld l, e
        
        ld a, (hl)
        dw $37CB ; swap A
        res 2, (hl)
        ld e, $00
        jr page_in_subweapon_gfx
        
    vblank_intercept_3:
        ; this one is messy because in addition to paging in
        ; graphics like the other three, we also must load the
        ; "subweapon icon."
        ld h, d
        ld l, e
        
        ld a, (hl)
        dw $37CB ; swap A
        push af
            push af
            
                res 7, (hl) ; clear 'dirty' flag -- this is our last update.
                
                ; replace subweapon icon
                ld hl, current_subweapon
                xor a
                or (hl)
            
            ; a <- gfx loaded in slot 1
            pop af
            and $3
            jr z, _cont ; if no subweapon icon, skip this.
            
            ; load subweapon icon accordingly.
            call set_subweapon_icon
            
        _cont:
            ld e, $20
        pop af
        ld b, e ; ld b, $20
        jr page_in_subweapon_gfx
        
    vblank_intercept:
        ; hl <- &subweapon_gfx_loaded
        pop hl 
        
        ; abort if buffer already used
        ldai16 vram_transfer_buffer
        or a
        jr nz, vblank_intercept_return
        
        ; a <- (subweapon_gfx_loaded)
        ld a, (hl)

        push hl
        pop de
        ld b, $00
        
        ; a >>= 2
        db $0f ; rrca
        db $0f ; rrca
        and $03
        
    vblank_dispatch:
        call $0003
        dw vblank_intercept_0
        dw vblank_intercept_1
        dw vblank_intercept_3
        dw vblank_intercept_2
    end_bank1:
endif    

; BANK3 (A) -------------------------------------------------------------------------

org $69C8+1
banksk3

if SUBWEAPONS
spawn_common_bank3:
    pushhl mbc_swap_bank_6
    ldai16 subweapon_gfx_loaded
    dw $37CB ; swap A
    and $3
    ld h, d
    ld l, $0
    cp (hl)
    ret z
    pushhl allocate_subweapon_gfx
    jp mbc_swap_bank_1
endif

; BANK3 (B) -------------------------------------------------------------------------

org $7f7f+1
banksk3
if SUBWEAPONS
    set_subweapon_gfx:
        dw $37CB ; swap A
        set 7, a
        ldi16a subweapon_gfx_loaded
        ret
    
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
        dw axe_sprite_0
        dw cross_sprite_1
        
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