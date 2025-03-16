global _start           ;Makes it visible for a linker from where to start
 
section .data           ;Initialising variables in data segment
String db "Hello %xworld!", 10, "$"   ;conditionally format string to print
StringLen equ $-String; length of the String to make things a little bit easier
Count dq 0
section .bss
Buffer resb 128

section .text
_start:

    push 1760             ;unpaired push for giving arguments in function
    push String         ;
    call MyPrintf

    mov rax, 60
    xor rdi, rdi
    syscall

;------------------------------------------------------------------------------------------------
;MyPrintf - function that prints given string to console adding given arguments proccessed via %
;Enter: Stack: ... | par_3 | par_2 | par_1 | StringPtr
;Exit:  
;Destr: RDI, rcx, RAX (+ related to syscall)
;------------------------------------------------------------------------------------------------
MyPrintf:
    mov byte [Count], 8          ;Preparing rcx reg to count number of variables times 8 (Given value of 8 as it expects to get at least a string)
    add rsp, 8          ;obtaining arguments from the stack (string)
    mov rsi, [rsp]      ;StringPtr
    
    mov rdi, Buffer     
    ;mov rcx, StringLen
    ;______________MAIN_cycle_of_MYPRINTF__________________
    ;rsi - Format String pointer
    ;rdi - Buffer pointer
    
    CreateBuffer:

    cmp byte [rsi], '%' 
    je PercentHandle

    movsb

    Ready:
    ;dec rcx
    ;cmp rcx, 0
    cmp byte [rsi], '$'
    jne CreateBuffer
    ;________________________END___________________________

    sub rsp, qword [Count]          ;return pointer rsp where it was

    mov rsi, Buffer
    mov rdx, StringLen  ; is to be replaced by function counting number of chars
    mov rdi, 1          ; sets output in console
    ;rsi is given
    mov rax, 1          ; в RAX - номер функции для вывода в поток 
    syscall 
    ret

PercentHandle:
    add rsp, 8              ;Now rsp points to following argument in stack | StringAddress | par_1 | par_2 | par_3 | ... |
    add qword [Count], 8          
    cmp byte [rsi+1], '%'
    je PrintPercent

    cmp byte [rsi+1], 'c'
    je PrintChar

    cmp byte [rsi+1], 'd'
    je PrintDecimal

    cmp byte [rsi+1], 'x'
    je PrintHex

    inc rsi
    jmp Ready
    ;cmp [rsi+1], 'd'


    PrintPercent:
    sub rsp, 8
    sub qword [Count], 8          ; it does not requiere argument to print %, so don`t counts this
    mov byte [rdi], '%'
    inc rdi
    add rsi, 2          ; adding 2 as we have to skip another %
    jmp Ready

    PrintDecimal:
    mov rax, [rsp] 
    add al, 30h
    mov byte [rdi], al
    inc rdi
    add rsi, 2
    jmp Ready

    PrintChar:
    mov rax, [rsp] 
    mov byte [rdi], al
    inc rdi
    add rsi, 2
    jmp Ready

    PrintHex:

    ;mov rax, [rsp]
    ;cqo          ; расширяем регистр rdx знаковым битом из RAX 
    ;mov rbx, 16   ; 64-разрядный регистр
    ;div rbx 

    ;call int_to_acsii
    ;mov byte [rdi], al
    ;add rdi, 1;

    ;add rsi, 2
    ;jmp Ready

    mov eax, 0f0000000h
    mov cl, 28
    ;mov rbp, 28

    PHEX:

    mov rbx, [rsp]
    and ebx, eax
    shr ebx, cl
    call int_to_acsii
    mov byte [rdi], bl
    inc rdi

    shr rax, 4
    sub cl, 4
    ;mov Count, cl

    cmp eax, 0h
    jne PHEX

    add rsi, 2
    jmp Ready

    ;mov rbx, rax
    ;and ebx, 0ff000000h
    ;shr ebx, 24 
    ;call int_to_acsii
    ;mov byte [rdi], bl
    ;inc rdi

    ;mov ebx, eax
    ;and ebx, 00ff0000h
    ;shr ebx, 16 
    ;call int_to_acsii
    ;mov byte [rdi], bl
    ;inc rdi

    ;mov ebx, eax
    ;and ebx, 000000f0h
    ;shr ebx, 8 
    ;call int_to_acsii
    ;mov byte [rdi], bl
    ;inc rdi

    ;mov ebx, eax
    ;and ebx, 0000000fh 
    ;call int_to_acsii
    ;mov byte [rdi], bl
    ;inc rdi    
    
int_to_acsii:
    cmp bl, 10
    js DIGIT
    sub bl, 10
    add bl, 'A'
    
    jmp SKIP
    DIGIT:
    add bl, '0'
    
    SKIP:

    ret