drag_calc:
    push hl
    jr nz, drag_calc_negative
    
adjust_bc:
    ld a, h
    cp $0
    jr nz, drag_calc_zero
    ld a, l
    cp $5e*2
    jr nc, drag_calc_zero

decrease_bc:
    ; hl /= 2
    sra h
    rr l
    add hl, bc
    ld b, h
    ld c, l
    
    pop hl
    ret
        
drag_calc_negative:
    dec hl
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    jr adjust_bc
    

drag_calc_zero:
    xor a
    ld b, a
    ld c, a
    pop hl
    ret
    
    if $ - drag_calc >= $50
        panic
    endif