global _start           ;Makes it visible for a linker from where to start
 
section .data           ;Initialising variables in data segment
String db "%s is the best %s", 10, "$"   ;conditionally format string to print
Linux db "Linux$"
OP db "Operation System$"
StringLen equ $-String; length of the String to make things a little bit easier
Count dq 0
BufferLen dq 0
section .bss
Buffer resb 128

section .text
_start:
    push OP
    push Linux            ;unpaired push for giving arguments in function
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

    cmp byte [rsi], '$'
    jne CreateBuffer
    movsb
    ;________________________END___________________________

    sub rsp, qword [Count]          ;return pointer rsp where it was

    mov rsi, Buffer
    call StrLen
    mov rdx, rcx  ; is to be replaced by function counting number of chars
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

    cmp byte [rsi+1], 'b'
    je PrintBinary

    cmp byte [rsi+1], 'o'
    je PrintOctal

    cmp byte [rsi+1], 's'
    je PrintString

    inc rsi
    jmp Ready


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

PrintString:
    mov rax, rsi

    mov rsi, [rsp]
    call StrLen; Counts Length of the given string and puts value to rcx
    rep movsb

    mov rsi, rax

    add rsi, 2
    jmp Ready


PrintOctal:

    mov eax, 10000000000000000000000000000000b

    add rsi, 2
    jmp Ready

PrintBinary:

    mov eax, 10000000000000000000000000000000b
    ;mov cl, 31

PBIN:

    mov rbx, [rsp]
    and ebx, eax
    cmp ebx, 0

    je Zero
    mov bl, '1'
    jmp PrtBl

    Zero:
    mov bl, '0' 

    PrtBl:
    mov byte [rdi], bl
    inc rdi

    shr rax, 1

    cmp eax, 0h
    jne PBIN

    add rsi, 2
    jmp Ready

PrintHex:
    mov eax, 0f0000000h
    mov cl, 28

PHEX:

    mov rbx, [rsp]
    and ebx, eax
    shr ebx, cl
    call int_to_acsii
    mov byte [rdi], bl
    inc rdi

    shr rax, 4
    sub cl, 4

    cmp eax, 0h
    jne PHEX

    add rsi, 2
    jmp Ready
    
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

;__________________________
; rsi - address to the string to count length of
; Exit: rcx - Length of the string
StrLen:
    mov rcx, -1
    LengthCycle:
    inc rcx
    cmp byte [rsi+rcx], '$'
    jne LengthCycle
    ret