
;>routine should be called from with DB register in [00,3F] or [80,BF]
;>standard default settings from SnesDevManual Chap.26
BOOT.INIT_PPU:
    lda #$8F   
    stz $2100 ;> fblank

    stz $2101
    stz $2102
    stz $2103

   ;nop $2104

    stz $2105
    stz $2106
    stz $2107
    stz $2108
    stz $2109
    stz $210A
    stz $210B
    stz $210C

    stz $210D : stz $210D
    stz $210E : stz $210E
    stz $210F : stz $210F
    stz $2110 : stz $2110
    stz $2111 : stz $2111
    stz $2112 : stz $2112
    stz $2113 : stz $2113
    stz $2114 : stz $2114

    lda #$80 : sta $2115
    stz $2116
    stz $2117

   ;nop $2118
   ;nop $2119

    stz $211A

    lda #$01
    stz $211B : sta $211B
    stz $211C : stz $211C
    stz $211D : stz $211D
    stz $211E : sta $211E
    stz $211F : stz $211F
    stz $2120 : stz $2120

   ;nop $2122

    stz $2123
    stz $2124
    stz $2125
    stz $2126
    stz $2127
    stz $2128
    stz $2129
    stz $212A
    stz $212B
    stz $212C
    stz $212D
    stz $212E
    stz $212F

    lda #$30
    sta $2130

    stz $2131

    lda #$E0
    sta $2132

    stz $2133

    stz $4200
    
    lda #$FF
    sta $4201

    stz $4202
    stz $4203
    stz $4204
    stz $4205
    stz $4206
    stz $4207
    stz $4208
    stz $4209
    stz $420A
    stz $420B
    stz $420D
    stz $420D

rtl