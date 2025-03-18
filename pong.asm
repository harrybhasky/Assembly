.MODEL SMALL
.STACK 256

.DATA
ball_x dw 0Ah          
ball_y dw 0Ah          
ball_size dw 04h       ; size (4x4 pixels)
time_value db 0h       ; last centisecond value
speed_x dw 03h         
speed_y dw 02h         ; Ball's vertical speed
window_width dw 140h   ; Screen width (320 pixels)
window_height dw 0C8h  ; Screen height (200 pixels)
window_bounds dw 6
reset_position_x dw 0A0h
reset_position_y dw 64h

paddle_l_x dw 0ah
paddle_l_y dw 0ah

paddle_r_x dw 130h
paddle_r_y dw 0ah

paddle_width dw 05h
paddle_height dw 0eh
paddle_speed dw 05h

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

    ; Set video mode to 320x200 (13h)
    MOV AH, 00h
    MOV AL, 13h
    INT 10h

    ; Set background color to black
    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 00h
    INT 10h

main_loop:
    ; Get system time
    MOV AH, 2Ch
    INT 21h

    ; Compare DL (current centiseconds) with time_value
    CMP DL, time_value
    JE main_loop           ; If time hasn't changed, keep checking

    ; Update time_value to the new time
    MOV time_value, DL

    ; Clear the ball at its current position
    CALL clear_ball

    ; Move the ball to its new position
    CALL move_ball

    ; Draw the ball at its new position
    CALL draw_ball

    ; Clear the paddle at its current position
    CALL clear_paddle

    ; Move the paddle based on keyboard input
    CALL move_paddle

    ; Draw the paddle at its new position
    CALL draw_paddle

    ; Check for key press (exit if a key is pressed)
    MOV AH, 01h
    INT 16h
    JZ main_loop           ; If no key pressed, continue loop

    ; Exit program
    ; Switch back to text mode (mode 03h)
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    ; Return to DOS
    MOV AH, 4Ch
    INT 21h

clear_ball:
    MOV CX, ball_x
    MOV DX, ball_y

clear_ball_horizon:
    MOV AH, 0Ch
    MOV AL, 00h          ; Black color (erase the ball)
    MOV BH, 00h          ; Page number
    INT 10h

    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, ball_x
    CMP AX, ball_size
    JNG clear_ball_horizon  ; Continue clearing horizontally

    ; Move to the next row (increase Y)
    MOV CX, ball_x       ; Reset X to start
    INC DX               ; Move down (next row)

    ; Check if we've cleared ball_size rows vertically
    MOV AX, DX
    SUB AX, ball_y
    CMP AX, ball_size
    JNG clear_ball_horizon  ; If not done, keep clearing rows

    RET

clear_paddle:
    ; Clear the left paddle
    MOV CX, paddle_l_x
    MOV DX, paddle_l_y

clear_paddle_left:
    MOV AH, 0Ch
    MOV AL, 00h          ; Black color (erase the paddle)
    MOV BH, 00h          ; Page number
    INT 10h
    
    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, paddle_l_x
    CMP AX, paddle_width
    JNG clear_paddle_left  ; Continue clearing horizontally
    
    MOV CX, paddle_l_x   ; Reset X to start
    INC DX               ; Move down (next row)

    ; Check if we've cleared paddle_height rows vertically
    MOV AX, DX
    SUB AX, paddle_l_y
    CMP AX, paddle_height
    JNG clear_paddle_left  ; If not done, keep clearing rows
    
    clear_paddle_right:
    MOV AH, 0Ch
    MOV AL, 00h          ; Black color (erase the paddle)
    MOV BH, 00h          ; Page number
    INT 10h
    
    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, paddle_r_x
    CMP AX, paddle_width
    JNG clear_paddle_right  ; Continue clearing horizontally
    
    MOV CX, paddle_r_x   ; Reset X to start
    INC DX               ; Move down (next row)

    ; Check if we've cleared paddle_height rows vertically
    MOV AX, DX
    SUB AX, paddle_r_y
    CMP AX, paddle_height
    JNG clear_paddle_right  ; If not done, keep clearing rows

    RET

draw_paddle:
    ; Draw the left paddle
    MOV CX, paddle_l_x
    MOV DX, paddle_l_y

    draw_paddle_left:
    MOV AH, 0Ch
    MOV AL, 0Fh          ; White color (draw the paddle)
    MOV BH, 00h          ; Page number
    INT 10h
    
    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, paddle_l_x
    CMP AX, paddle_width
    JNG draw_paddle_left  ; Continue drawing horizontally
    
    MOV CX, paddle_l_x   ; Reset X to start
    INC DX               ; Move down (next row)

    ; Check if we've drawn paddle_height rows vertically
    MOV AX, DX
    SUB AX, paddle_l_y
    CMP AX, paddle_height
    JNG draw_paddle_left  ; If not done, keep drawing rows
    
    ;right paddle
    mov cx, paddle_r_x
    mov dx, paddle_r_y

    draw_paddle_right:
    MOV AH, 0Ch
    MOV AL, 0Fh          ; White color (draw the ball)
    MOV BH, 00h          ; Page number
    INT 10h
    
    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, paddle_r_x
    CMP AX, paddle_width
    JNG draw_paddle_right  ; Continue drawing horizontally
    
    MOV CX, paddle_r_x       ; Reset X to start
    INC DX               ; next row

    MOV AX, DX
    SUB AX, paddle_r_y
    CMP AX, paddle_height
    JNG draw_paddle_right  ; If not done, keep drawing rows

RET

move_paddle:
    ; Check keyboard status
    MOV AH, 01h
    INT 16h
    JZ check_rp_movement ; If no key is pressed, skip movement

    ; read key pressed
    MOV AH, 00h
    INT 16h

    
    CMP AL, 77h  ; 'w'
    JE move_lp_up
    CMP AL, 57h  ; 'W'
    JE move_lp_up

    ; Check for 'S' or 's' (move left paddle down)
    CMP AL, 73h  ; 's'
    JE move_lp_down
    CMP AL, 53h  ; 'S'
    JE move_lp_down

    JMP check_rp_movement  ; If no relevant key is pressed, skip movement

    move_lp_up:
    ; Move the left paddle up
    MOV AX, paddle_speed
    SUB paddle_l_y, AX  ; Subtract speed to move up

    mov ax, window_bounds
    CMP paddle_l_y, ax
    JL FIX_PADDLE_LEFT_TOP_POSITION
	JMP check_rp_movement
			
		FIX_PADDLE_LEFT_TOP_POSITION:
		MOV paddle_l_y,AX
		
    JMP check_rp_movement
    

    move_lp_down:
    ; Move the left paddle down
    MOV AX, paddle_speed
    ADD paddle_l_y, AX  ; Add speed to move down

    MOV AX, window_height
    sub ax, window_bounds
    SUB AX, paddle_height
    CMP paddle_l_y, AX
    JG FIX_PADDLE_LEFT_BOTTOM_POSITION 
    jmp check_rp_movement

    FIX_PADDLE_LEFT_BOTTOM_POSITION:
    mov paddle_l_y, ax
    jmp check_rp_movement


    check_rp_movement:

    
    CMP AL, 69h  ; 'i'
    JE move_rp_up
    CMP AL, 49h  ; 'I'
    JE move_rp_up

    
    CMP AL, 6Bh  ; 'k'
    JE move_rp_down
    CMP AL, 4Bh  ; 'K'
    JE move_rp_down
    jmp exit_paddle_move
    
    move_rp_up:
    
    MOV AX, paddle_speed
    SUB paddle_r_y, AX  ; Subtract speed to move up

    mov ax, window_bounds
    CMP paddle_r_y, ax
    JL FIX_PADDLE_RIGHT_TOP_POSITION
	JMP exit_paddle_move
			
		FIX_PADDLE_RIGHT_TOP_POSITION:
		MOV paddle_r_y,AX
		
    JMP exit_paddle_move
    

    move_rp_down:
   
    MOV AX, paddle_speed
    ADD paddle_r_y, AX  ; Add speed to move down

    MOV AX, window_height
    sub ax, window_bounds
    SUB AX, paddle_height
    CMP paddle_r_y, AX
    JG FIX_PADDLE_RIGHT_BOTTOM_POSITION 
    jmp exit_paddle_move

    FIX_PADDLE_RIGHT_BOTTOM_POSITION:
    mov paddle_r_y, ax
    jmp exit_paddle_move

    exit_paddle_move:

RET

move_ball:
    ; Move ball_x
    MOV AX, speed_x
    ADD ball_x, AX

    ; Check if ball_x is out of bounds (left or right)
    CMP ball_x, 00h
    JB reset_ball_pos
    MOV AX, window_width
    SUB AX, ball_size
    CMP ball_x, AX
    JAE reset_ball_pos

    ; Move ball_y
    MOV AX, speed_y
    ADD ball_y, AX

    ; Check if ball_y is out of bounds (top or bottom)
    CMP ball_y, 00h
    JB reverse_ball_y
    MOV AX, window_height
    SUB AX, ball_size
    CMP ball_y, AX
    JAE reverse_ball_y

    RET

reset_ball_pos:
    CALL reset_ball          ; Reverse horizontal direction
    RET

reverse_ball_y:
    NEG speed_y          ; Reverse vertical direction
    RET

reset_ball:
    MOV AX, reset_position_x
    MOV ball_x, AX

    MOV AX, reset_position_y
    MOV ball_y, AX
    RET

draw_ball:
    MOV CX, ball_x
    MOV DX, ball_y

draw_ball_horizon:
    MOV AH, 0Ch
    MOV AL, 0Fh          ; White color (draw the ball)
    MOV BH, 00h          ; Page number
    INT 10h

    INC CX               ; Move right (next pixel horizontally)
    MOV AX, CX
    SUB AX, ball_x
    CMP AX, ball_size
    JNG draw_ball_horizon  ; Continue drawing horizontally

    ; Move to the next row (increase Y)
    MOV CX, ball_x       ; Reset X to start
    INC DX               ; Move down (next row)

    ; Check if we've drawn ball_size rows vertically
    MOV AX, DX
    SUB AX, ball_y
    CMP AX, ball_size
    JNG draw_ball_horizon  ; If not done, keep drawing rows

    RET

END MAIN