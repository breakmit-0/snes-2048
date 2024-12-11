;all the interrupt handlers including RESET and NMI



org $008000 ;start of ROM

INT.RESET:
    clc
    xce
    lda #$01
    sta $420D
    jml BOOT
.end

INT.NMI:
    jml NMI
.end

INT.IRQ:
    rti
.end

INT.BRK:
    rti
.end

INT.END: