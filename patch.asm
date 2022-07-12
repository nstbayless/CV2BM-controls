incbin "base.gb"

org $3FF1
seek $
is_moving_downward:
    ld hl,$C010
    add a, (hl)
    and $F0
    ret
end_bank0:

; call bank after org, seeks to $ in given bank.
banksk:  macro string
    seek string ? (string - 1) * $4000 + $ : $
endm

ldai16: macro addr
    db $FA
    defw addr
endm

org $3DAC
entity_set_x_velocity_0:

org $3DB7
entity_set_y_velocity:

org $3DBA
write_word_cb:

org $4235
belmont_jumptable:

org $4235+2*3
seek $4000 * (6-1) + $
dw new_jump_routine

org $4293
belmont_update_jump:

org $4627
input_leftright_held:

org $4771
speed_hack_velocity_r:

org $477C
speed_hack_velocity_l:

org $480d
seek $4000 * (6-1) + $
belmont_set_hvelocity_from_input:
    call input_leftright_held
    ret z
    nop
    
org $4822
ret_4822:

org $7FBC
seek $4000 * (6-1) + $
new_jump_routine:
lr_ctrl:
    ld l, 2
    ld h, d
    bit 1, (hl)
    jr z, new_jump_routine_exec
    xor a
    call is_moving_downward
    jr nz, new_jump_routine_return
    
new_jump_routine_exec:
    ; push facing; c <- 9
    ld e, 9
    ld c, e
    ld a, (de)
    push af
    
    call belmont_set_hvelocity_from_input
    
    ; check if c was changed (bit 0 will not be 1 anymore)
    bit 0, c
    
    ; if c was not changed, set x velocity to 0
    call nz, entity_set_x_velocity_0
    
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
if VCANCEL == 1
vcancel:
    ldai16 $C886
    and $10
    jr nz, fin_vcancel
    
    ; check if moving downward
    ld a, 1
    call is_moving_downward
    jr z, fin_vcancel
    
    ; zero velocity
    ld bc, $FF00
    call entity_set_y_velocity
    
fin_vcancel:
endif
new_jump_routine_return:
    jp belmont_update_jump
    
end_bank6: