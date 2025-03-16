global _start
 
section .data
String db "Hello world!", 10
;buffer resb 128
StringLen equ $-String; length of the buffer

section .text
_start:
     
    mov rdx, StringLen
    mov rsi, String
    call MyPrintf

    mov rax, 60
    xor rdi, rdi
    syscall

;------------------------------------------------------------------------------------------------
;MyPrintf - function that prints given string to console adding given arguments proccessed via %
;Enter: RSI - address of the string to print
;Exit:  
;Destr: RDI, RDX, RAX (+ related to syscall)
;------------------------------------------------------------------------------------------------
MyPrintf:

    mov rdi, 1        ; sets output in console
    ;mov rsi, message  ; в RSI - address of the string to print
    mov rax, 1        ; в RAX - номер функции для вывода в поток 
    syscall 
    ret