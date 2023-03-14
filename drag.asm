dragphysics_adjust:
    ; hl <- belmont x velocity pixel
    ld a, $00
    ldi16a $ca82
    ld a, $5e
    ldi16a $ca80
    
    ; hl <- belmont x velocity minus $5E
    ld bc, $FFA2
    ld hl, $c014
    ldhlhl
    ; double speed if > 0
    bit 7, h
    call drag_calc
    
    db $E7 ; RST $20: a <- x position of entity
    add hl, bc
    
    bit 7, h
    jr nz, negative_drag
    
    ; check >= $f8 (or == 0, which is not possible)
    add $08
    
negative_drag:
    cp $09
    ret c
    
drag_add_to_xvelocity:
    ; OPT: probably compressable
    
    ld e, $16
    ld a, (de)
    add a, l
    ld (de), a
    ld e, $17
    ld a, (de)
    adc a, h
    ld (de), a
    ret
    
if $ - dragphysics_adjust > 46
    panic
endif