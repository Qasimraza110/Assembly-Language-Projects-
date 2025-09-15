.MODEL SMALL
.DATA
       zero db " 0000 ", 10
            db "0    0", 10
            db "0    0", 10
            db "0    0", 10
            db " 0000 ", 10, "$"

        one db "  11  ", 10
            db " 1 1  ", 10
            db "   1  ", 10
            db "   1  ", 10
            db " 1111 ", 10, "$"
            
        two db " 2222 ", 10
            db "2    2", 10
            db "    2 ", 10
            db "  2   ", 10
            db "222222", 10, "$"
            
      three db " 3333 ", 10
            db "     3", 10
            db "   33 ", 10
            db "     3", 10
            db " 3333 ", 10, "$"
            
       four db "   44 ", 10
            db "  4 4 ", 10
            db " 4  4 ", 10
            db "444444", 10
            db "    4 ", 10, "$"
            
       five db "555555", 10
            db "5     ", 10
            db "55555 ", 10
            db "     5", 10
            db "55555 ", 10, "$"
            
        six db " 6666 ", 10
            db "6     ", 10
            db "66666 ", 10
            db "6    6", 10
            db " 6666 ", 10, "$"
            
      seven db "777777", 10
            db "    7 ", 10
            db "   7  ", 10
            db "  7   ", 10
            db " 7    ", 10, "$"
            
      eight db " 8888 ", 10
            db "8    8", 10
            db " 8888 ", 10
            db "8    8", 10
            db " 8888 ", 10, "$"
            
       nine db " 9999 ", 10
            db "9    9", 10
            db " 99999", 10
            db "     9", 10
            db " 9999 ", 10, "$"
    
                                             
    line db 0
    column db 0   
    page_number db 0 
    digit_unit db 0
    digit_ten db 0  
    time db 0 
    hour db 0     
    minute db 0
    second db 0
    current_minute db 0
    current_second db 0    
    current_hour db 0   ; variable to store current hour
    digit_pointer dw 10 dup(?)                                   
                                             
ends

.STACK 100H
    dw   128  dup(?)
ends         

extra segment
    
ends

code segment
start:
    ; set segment registers:
    mov     ax, data
    mov     ds, ax
    mov     ax, extra
    mov     es, ax

    call    set_digit_pointer
    
    
main_loop:        

    call    load_time

    mov     al, current_second
    cmp     second, al
    jne     do_print

    mov     al, current_minute
    cmp     minute, al
    jne     do_print

    mov     al, current_hour
    cmp     hour, al
    jne     do_print

    jmp     main_loop
                 
 do_print:
    mov     al, current_minute
    mov     minute, al
    mov     al, current_second
    mov     second, al
    mov     al, current_hour
    mov     hour, al

    call    clear_screen
    call    print
    jmp     main_loop
print:
    ; print hour -----
    mov     al, current_hour
    mov     time, al
    call    parse_time

    ; hour ten
    mov     al, digit_ten
    call    set_digit

    mov     column, 0
    call    print_digit

    ; hour unit
    mov     al, digit_unit
    call    set_digit

    mov     column, 8
    call    print_digit

    ; print minute -----
    mov     al, current_minute
    mov     time, al
    call    parse_time

    ; minute ten
    mov     al, digit_ten
    call    set_digit

    mov     column, 20
    call    print_digit

    ; minute unit
    mov     al, digit_unit
    call    set_digit

    mov     column, 28
    call    print_digit

    ; print second -----
    mov     al, current_second
    mov     time, al
    call    parse_time

    ; second ten
    mov     al, digit_ten
    call    set_digit

    mov     column, 40
    call    print_digit

    ; second unit
    mov     al, digit_unit
    call    set_digit

    mov     column, 48
    call    print_digit

    ret

clear_screen:   ; get and set video mode
    mov     ah, 0fh
    int     10h   
    
    mov     ah, 0
    int     10h
    
    ret
    
    
load_time:      ; save CH = hour, CL = minute, DH = second 
    mov     ah, 2Ch
    int     21h 
    mov     current_hour, ch    ; save current hour
    mov     current_minute, cl
    mov     current_second, dh
    ret

set_digit_pointer:
    mov     digit_pointer[0], offset zero
    mov     digit_pointer[2], offset one     
    mov     digit_pointer[4], offset two
    mov     digit_pointer[6], offset three
    mov     digit_pointer[8], offset four
    mov     digit_pointer[10], offset five
    mov     digit_pointer[12], offset six
    mov     digit_pointer[14], offset seven
    mov     digit_pointer[16], offset eight
    mov     digit_pointer[18], offset nine
    
    ret
    
       
set_digit:  ; set digit from al to si
    mov     bl, 2
    mul     bl
    
    mov     si, ax
    mov     si, digit_pointer[si]
    
    ret     
    

parse_time:     ;parse time in "time", loading "digit_ten" and "digit_unit"        
    mov     ah, 0
    mov     al, time
    mov     bl, 10
    div     bl
    mov     digit_ten, al
    mov     digit_unit, ah
    
    ret

 
print_digit:    ;print digit in SI until find "$", set line = 4 and column = column   
    mov     line, 4   
    call    set_cursor
               
    print_main:    
    mov     dh, 0                        
    mov     dl, ds:[si]
    
    cmp     dx, "$"
    je      end_print
    
    cmp     dx, 10
    je      new_line              
          
    mov     ah, 2
    int     21h  
    
    inc     si
    jmp     print_main                    
    
    new_line:
    inc     line
    call    set_cursor 
    inc     si 
    jmp     print_main
    
    end_print:
    ret               
  
                   
set_cursor:              
    mov     ah, 2
    mov     bh, page_number
    mov     dh, line
    mov     dl, column
    int     10h
    
    ret      
    

fim:                
    mov     ax, 4c00h ; exit to operating system.
    int     21h       

      
code ends

end start
