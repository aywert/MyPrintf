global _start           ;Makes it visible for a linker from where to start
 
section .data           ;Initialising variables in data segment
String db "Hello %world!", 10   ;conditionally format string to print
StringLen equ $-String; length of the String to make things a little bit easier
Buffer resb 128

section .text
_start:

    push String         ;unpaired push for giving arguments in function
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

    add rsp, 8          ;obtaining arguments from the stack
    mov rsi, [rsp]      ;StringPtr
    sub rsp, 8

    ;SEEMS_like_MAIN_cycle_of_MYPRINTF
    cld                 ;drops direction flag so rsi and rdi increase every time (to ensure that it goes in the rigth direction)
    mov rdi, Buffer     
    mov rcx, StringLen
    rep movsb
    ;_______________END________________

    mov rsi, Buffer
    mov rdx, StringLen  ; is to be replaced by function counting number of chars
    mov rdi, 1          ; sets output in console
    ;rsi is given
    mov rax, 1          ; в RAX - номер функции для вывода в поток 
    syscall 
    ret