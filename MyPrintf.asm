global _start           ;Makes it visible for a linker from where to start
 
section .data           ;Initialising variables in data segment
String db "Hello %cworld!", 10   ;conditionally format string to print
StringLen equ $-String; length of the String to make things a little bit easier
Buffer resb 128

section .text
_start:

    push 9              ;unpaired push for giving arguments in function
    push String         ;
    call MyPrintf

    mov rax, 60
    xor rdi, rdi
    syscall

;------------------------------------------------------------------------------------------------
;MyPrintf - function that prints given string to console adding given arguments proccessed via %
;Enter: Stack: ... | par_3 | par_2 | par_1 | StringPtr
;Exit:  
;Destr: RDI, RDX, RAX (+ related to syscall)
;------------------------------------------------------------------------------------------------
MyPrintf:
    mov rdx, 8          ;Preparing rdx reg to count number of variables times 8 (Given value of 8 as it expects to get at least a string)
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
    cmp rsi, String+StringLen
    jb CreateBuffer
    ;________________________END___________________________

    sub rsp, rdx          ;return pointer rsp where it was

    mov rsi, Buffer
    mov rdx, StringLen  ; is to be replaced by function counting number of chars
    mov rdi, 1          ; sets output in console
    ;rsi is given
    mov rax, 1          ; в RAX - номер функции для вывода в поток 
    syscall 
    ret

PercentHandle:
    add rsp, 8              ;Now rsp points to following argument in stack | StringAddress | par_1 | par_2 | par_3 | ... |
    add rdx, 8          
    cmp byte [rsi+1], '%'
    je PrintPercent

    cmp byte [rsi+1], 'c'
    je PrintChar

    cmp byte [rsi+1], 'd'
    je PrintDecimal

    inc rsi
    jmp Ready
    ;cmp [rsi+1], 'd'


    PrintPercent:
    sub rsp, 8
    sub rdx, 8          ; it does not requiere argument to print %, so don`t counts this
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
