!fastROM = $800000



;sprite VRAM pointers, 4 bytes each
!SP_PTR_lo = $0520
!SP_PTR_hi = $0524
!SP_PTR_bk = $0528
!SPRAM_dirty = $052C

;BG tiles VRAM pointers, 1 byte each
!VRAM_PTR_lo = $0530
!VRAM_PTR_hi = $0521
!VRAM_PTR_bk = $0522


;tilemaps and screen size
!BG1SC = $2107
!BG2SC = $2108
!BG3SC = $2109
!BG4SC = $210A

;gfx adresses
!BG12NBA = $210B
!BG34NBA = $210C


;OAM mirror
!OAM_start = $0300
!OAM_x = !OAM_start
!OAM_y = !OAM_start+1
!OAM_gfx = !OAM_start+2
!OAM_prop = !OAM_start+3
!OAM_ex = !OAM_start+512
!OAM_index = !OAM_start-2
!OAMX_index = !OAM_start-3

;input can be OR-ed to get NES-like inputs
!INPUT_lo = $4218
!INPUT_hi = $4219

;low input codes
!IN_A = $80
!IN_X = $40
!IN_L = $20
!IN_R = $10

; hi input codes
!IN_B = $80
!IN_Y = $40
!IN_SELECT = $20
!IN_START = $10
!IN_UP = $08
!IN_DOWN = $04
!IN_LEFT = $02
!IN_RIGHT = $01


org $7E0300
struct mirrorOAM $7E0300
    .posx: skip 1
    .posy: skip 1
    .tile: skip 1
    .prop: skip 1
endstruct


;the main game table, 1 byte for the number
org $7E0100
struct table $7E0200
    .c0 skip 1
    .c1 skip 1
    .c2 skip 1
    .c3 skip 1
endstruct


!input1_held = $30
!input2_held = $31

!input1_changed = $32
!input2_changed = $33


!RAND_seed_lo = $40
!RAND_seed_hi = $41
!RAND_out_lo = $42
!RAND_out_hi = $43

!won_flag = $44
!lost_flag = $45

!game_mode = $46
!score = $47
!score_hi = $48
!score_ex = $49
!score_dec = $4A ; 8 bytes: $4A, $4B, $4C, $4D, $4E, $4F, $50, $51

!option_select = $52
!endgame = $53

!hiscore = $54
!hiscore_hi = $55
!hiscore_ex = $56
!hiscore_dec = $57 ; 8 bytes: $57-$5F

!save_table = $306000
!save_score = $306010
!save_best = $306013
!save_checksum = $306016
!save_complement = $306017


;apu upload input
!apu_src = $00
!apu_target_lo = $03
!apu_target_hi = $04
!apu_size = $05
!apu_ack_mem = $07
