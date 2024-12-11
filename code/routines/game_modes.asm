
macro if_just_pressed2(input_code, else)
    lda !input2_changed
    and #<input_code>
    beq <else>

    lda !input2_held
    and #<input_code>
    beq <else>
endmacro

GM.play:

    %if_just_pressed2(!IN_RIGHT, .in_not_right)
    jsl ROUTINE.move_right    
.in_not_right

    %if_just_pressed2(!IN_LEFT, .in_not_left)
    jsl ROUTINE.move_left
.in_not_left

    %if_just_pressed2(!IN_UP, .in_not_up)
    jsl ROUTINE.move_up
.in_not_up

    %if_just_pressed2(!IN_DOWN, .in_not_down)
    jsl ROUTINE.move_down
.in_not_down

    lda !won_flag
    beq +

    lda #$02
    sta !game_mode
+

    lda !lost_flag
    beq +

    lda #$03
    sta !game_mode
+

    %if_just_pressed2(!IN_START, .in_not_pause)
    lda #$05
    sta !game_mode
    inc !won_flag
.in_not_pause

    ;update high score
    %compare_long(!score, !hiscore, 3)
    bcc .not_hiscore


    lda !score
    sta !hiscore
    lda !score_hi
    sta !hiscore_hi
    lda !score_ex
    sta !hiscore_ex

.not_hiscore
    jsl ROUTINE.save

rtl

GM.animated:

rtl


GM.won:

    %if_just_pressed2(!IN_RIGHT, .not_right)
    lda #$01
    sta !option_select
.not_right

    %if_just_pressed2(!IN_LEFT, .not_left)
    stz !option_select
.not_left

    %if_just_pressed2(!IN_B, .not_select)

    lda !option_select
    bne GM.lost_reset

    lda #$04
    sta !game_mode

    inc !endgame

.not_select
rtl


GM.lost:

    %if_just_pressed2(!IN_B, .end)
.reset
    lda #$04
    sta !game_mode

    lda #$00
    ldx #$00
.loop
    sta table(0,0),x

    inx
    cpx #$10
    bne .loop

    stz !score
    stz !score_ex
    stz !score_hi

    stz !endgame

.end
rtl

GM.back_to_game:
    stz !game_mode
rtl


GM.pause:

    %if_just_pressed2(!IN_RIGHT, .not_right)
    lda #$01
    sta !option_select
.not_right

    %if_just_pressed2(!IN_LEFT, .not_left)
    stz !option_select
.not_left

    %if_just_pressed2(!IN_B, .not_select)

    lda !option_select
    bne GM.lost_reset

    lda #$04
    sta !game_mode
.not_select

rtl



GM.begin:

    %if_just_pressed2(!IN_DOWN, .in_not_down)

    lda !option_select
    cmp #$02
    beq .in_not_down

    inc !option_select

.in_not_down

    %if_just_pressed2(!IN_UP, .in_not_up)

    lda !option_select
    beq .in_not_up

    dec !option_select

.in_not_up


    %if_just_pressed2(!IN_B, .in_not_select)

    lda #$04
    sta !game_mode

    lda !option_select
    jsl ROUTINE.ptr_short
        dw .continue
        dw .reset
        dw .scores


.in_not_select
rtl


.continue
    ;restore the save
    ldx #$00
..loop1
    lda !save_table,x
    sta table(0,0),x

    inx
    cpx #$10
    bne ..loop1

    ldx #$00
..loop2
    lda !save_score,x
    sta !score,x
    lda !save_best,x
    sta !hiscore,x

    inx
    cpx #$03
    bne ..loop2
rtl


.reset
    ;wipe the save file, except high score
    ldx #$00
..loop
    lda !save_best,x
    sta !hiscore,x

    inx
    cpx #$03
    bne ..loop

    jsl ROUTINE.save
rtl


.scores
    ;full reset, just wipe the save file
    jsl ROUTINE.save
rtl