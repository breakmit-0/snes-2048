
; input: A, Y?, 3 adress bytes on stack
; 
; var3 = y
; y = stack.pop()
; var0 = y
; #a16i16
; A = A & $00FF 
; A = A << 1
; Y = A
; A = stack.pop(2 bytes)
; var1:var2 = A
; Y += 1
; A = *(var0:var1:var2 + y)
; var0:var1 = A
; --a8i8
; Y = var3
; goto *(var0:var1:var2)

; save(Y)
; addr_lo = stack.pop()
; Y = 2 * A + 1
; addr_hi = stack.pop()
; addr_bk = stack.pop()
; A,B = addr[y]
; addr_hi = A
; addr_bk = B
; restore(Y)
; goto addr

ROUTINE.ptr_short:
    sty $03
    ply
    sty $00
    rep #$30
    and #$00FF
    asl
    tay
    pla 
    sta $01
    iny
    lda [$00],y
    sta $00
    sep #$30
    ldy $03
    jmp [$0000]


ROUTINE.ptr_long:
    sty $05
    
    ;read low byte
    ply
    sty $02

    ;calculate 3*A
    rep #$30
    and #$00FF
    sta $03
    asl
    adc $03
    tay 

    ;read high and bank bytes
    pla
    sta $03

    ;load lo and hi dest bytes
    iny
    lda [$02],y
    sta $00

    ;load hi and bk dest bytes
    iny
    lda [$02],y
    sta $01

    ;restore
    sep #$30
    ldy $05

    ;goto dest
    jmp [$0000]

