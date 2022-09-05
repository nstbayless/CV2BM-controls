if rom_type == rom_kgbc4eu
    USE_ALTBANK: equ 0
    KGBC4EU_LAYOUT: equ 1
    ALTBANK1: equ 0
    ALTBANK7: equ 0
else
    if (rom_type == rom_jp) | INERTIA
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

GFX_SWAP: equ 0

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
    
    if GFX_SWAP
        if CONTROL | SUBWEAPONS
            ; we reserve this regardless of CONTROL or SUBWEAPONS.
            intercept_clear_subweapon_gfx:
                xor a
                ldi16a subweapon_gfx_loaded
                jp $2E57
        endif
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

if GFX_SWAP
    ; bits 0-1: subweapon gfx in slot 0
    ; bits 4-5: subweapon gfx in slot 1
    ; bit  7: is 1 if refresh is needed next vblank.
    org $C3E8
    subweapon_gfx_loaded:
endif

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
    
    org $28a3
    load_c882_and_F:

    org $2950
    unk_2950:
    
    org $3553
    unk_3553:
    
    org $39f0
    unk_39f0:
    
    org $3D70
    unk_3d70:
    
    org $482f
    unk_482f:
    
    if rom_type == rom_jp
        org $49a7
        unk_49a7:
    else
        org $49a9
        unk_49a7:
    endif

    org $35A9
    mbc_swap_bank_1:

    org $35B5
    mbc_swap_bank_6:

    org $35BB
    mbc_swap_bank_7:
    
    org $35C1
    mbc_swap_bank_3:
    
    org $38B0
    entity_unk_38b0:
    
    org $38E0
    ; sets animation to (bc):(bc+1)
    entity_set_animation:
    
    org $3DCC
    entity_reset_bit_0_prop_13_0E:
    
    org $3C14
    entity_unk_3C14:
    
    org $3D98
    entity_unk_3D98:
    
    org $3DA0
    entity_unk_3DA0:

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
    
    if rom_type == rom_us
        org $4a5F
        axe_update:
        
        org $49C3
        holywater_update:
    else
        org $4a5D
        axe_update:
        
        org $49C1
        holywater_update:
    endif
    

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
            call entity_set_y_velocity
            
        fin_vcancel:
    endif

    if USE_ALTBANK
            ret
        
        if ALTBANK7
            end_bank7:
        else
            if SUBWEAPONS == 1
                end_bankB1:
            else:
                end_bank1:
            endif
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
endif

if SUBWEAPONS
    if rom_type == rom_us
        
        if GFX_SWAP
            org $0B59
            banksk0
            call intercept_load_entity
            call $0002
            
            org $2E48
            banksk0
            call intercept_clear_subweapon_gfx
        endif
        
        org $3889
        banksk0 
        call intercept_apply_subweapon
    endif

    if rom_type == rom_us
        org $49BA
        banksk6
    endif
    
    ld b, a
    pushhl subweapon_dispatch
    jp mbc_swap_bank_1
    nop
    
    if rom_type == rom_us
        org $7ef0
        banksk1
    endif
    
    subweapon_dispatch:
        ld a, b
        or a
        jr z, jp_bank_swap_6 ; return if weapon is 0
        pushhl axe_update
        dec a
        jr z, jp_bank_swap_6
        pop hl
        pushhl holywater_update
        dec a
        jr z, jp_bank_swap_6
        pop hl
        
        call cross_update
    jp_bank_swap_6:
        jp mbc_swap_bank_6
        
        ; the following code has been ported from the JP rom.
        
    cross_update:
        db $C7 ; rst 0
        dw cross_update_spawn
        dw cross_update_forward
        dw cross_update_backward
        
    cross_animation:
        db $04
        db $0E
    
    cross_update_spawn:
        ; compare: JP rom, 06:4a64
        
        ; check if animation is 1
        ldai16 $C00B
        dec a
        ret nz
        
        ; set prop 8 to 1
        inc a
        ld e, $08
        ld (hl), a
        
        ; copy belmont facing (prop 9)
        ldai16 $C009
        set 0,a
        set 4,a
        inc e
        ld (de), a
        
        ; push C309
        push de
        
        ; set state to 1 (moving forward)
        db $F7 ; rst 30
        
        ; set animation
        ld bc, cross_animation
        call entity_set_animation
        
        ; reset bit 0 of prop 13, 0E.
        call entity_reset_bit_0_prop_13_0E
        
        ; with belmont...
        ld d, $C0
        
        ; x and y offset from belmont's position?
        ld bc, $08FA
        call entity_unk_3C14
        
        pop de ; de <- C309
        call entity_unk_3D98 ; set x and y?
        
        ld bc, $0140 ; velocity, not accounting for direction?
        jp entity_unk_3DA0 ; set velocity times direction?
    
    cross_update_move_common:
        pushhl mbc_swap_bank_1
        pushhl entity_unk_38b0
        pushhl unk_482f
        pushhl pop_hl_ret
        pushhl unk_49a7
        call mbc_swap_bank_6
    
    cross_update_move_common_2:
        call unk_0c52
        ld e, 00
        ld a, (de)
        or a
        jp z, pop_and_unk_49a1
        call load_c882_and_F
        ld a, $1F
        jp z, unk_3553
        ret
    
    pop_and_unk_49a1:
        pop hl
    unk_49a1:
        or a,
        ret nz
        ld h, d
        ld l, $00
        jp unk_2950
    
    cross_update_forward:
        ; compare JP 06:4a97
        call cross_update_move_common
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
        
    cross_update_backward:
        call cross_update_move_common
        ld h, $C0
        call unk_39f0
        jp c, unk_49a1
        ld e, $00
        ld a, (de)
        or a,
        jp z, unk_49a1
        ret
    
    
    ; clobbers everything
    intercept_apply_subweapon:
        call convert_subweapon_bank1
        ldi16a current_subweapon
        if GFX_SWAP
            jr replace_subweapon_gfx
        else
            ret
        endif
    
    if GFX_SWAP
        intercept_load_entity:
            ;(existing code)
            res 7, a
            ld (de), a
            
            ; store a.
            ld b, a
            
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
            jr z, ensure_subweapon_gfx_store
            inc a
            cp b
            ret nz
            
        ensure_subweapon_gfx_store:
            push de
            call ensure_subweapon_gfx
            pop de
            ret
        
        ; input: b is the subweapon to test (0/1/2)
        ; clobbers afbcehl
        ensure_subweapon_gfx:
            ldai16 subweapon_gfx_loaded
            ld c, a
            and #$03
            cp b
            ret z
            ld a, c
            dw $37CB ; swap a
            and #$03
            cp b
            ret z
            
        replace_subweapon_gfx:
            ; bank call to allocate subweapon gfx
            pushhl mbc_swap_bank_1
            pushhl allocate_subweapon_gfx
            jp mbc_swap_bank_3
    endif
        
    convert_subweapon_bank1:
        ; a -> a
        ; converts subweapon 1 to either 1 or 3 depending on value of d.
        cp a, $1
        ret nz
        
        ; if d%2==1
        bit 0, d
        ret z
        
        ld a, $3
        ret
    
    end_bank1:
    
    org $7f80
    banksk3
    
    if GFX_SWAP
        allocate_subweapon_gfx:
            ldai16 current_subweapon
            set 7, a; "needs update" flag.
            ld hl, subweapon_gfx_loaded
            ld (hl), a
            
            ; scan through lanterns to find what other subweapons are there
            ; check lanterns, which are at indices d4, d5, d6, and d7.
            ld bc, $d300
        loopnext:
            inc b
            ld a, $d8
            cp b
            jr z, endloop
            
            ; check if value is 1 or 2
            ld a, (bc)
            or a
            jr z, loopnext
            cp $3
            jr nc, loopnext
            
            ; h <- index of subweapon
            call convert_subweapon
            ld e, a
            
            ; check against gfx slot 0
            ld a, (hl)
            and #$03
            jr z, assign
            cp e
            jr z, loopnext
            
            ; skip if matches gfx slot 0
            dw $33CB ; swap e
            ld a, (hl)
            and #$30
            jr z, assign
            cp e
            jr z, assign
            
            ; matches neither and both slots are full
            ; sadly replace this lantern with a small consolation heart.
            ld a, $5
            ld (bc), a
        
        assign:
            ld a, (hl)
            or e
            ld (hl), a
            jr loopnext
        
        doswap:
            ld a, b
            dw $37CB ; swap a
            ld (hl), a
            ret
        
        endloop:
            ; if holy water is in slot 0, move it to slot 1.
            ld a, (hl)
            ld b, a
            and $03
            cp $02
            jr z, doswap
            ret
            
        convert_subweapon:
            ; a -> a
            ; converts subweapon 1 to either 1 or 3 depending on value of b.
            cp a, $1
            ret nz
            
            ; if b%2==1
            bit 0, b
            ret z
            
            ld a, $3
            ret
    endif
    
    ; IMPORTANT
    ; this must be $7FCF or lower!
    end_bank3:
endif