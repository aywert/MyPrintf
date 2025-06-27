global MyPrintf           ;Makes it visible for a linker from where to start
 
;extern printf
section .text
;MyPrintf:

    ;sub rsp, 8
    ;mov rdi, MessageToPrint
    ;call printf
    ;add rsp, 8

    ;push OP
    ;push Linux            ;unpaired push for giving arguments in function
    ;push String         ;
    ;call MyPrintf

    ;mov rax, 60
    ;xor rdi, rdi
    ;ret

;------------------------------------------------------------------------------------------------
;MyPrintf - function that prints given string to console adding given arguments proccessed via %
;Enter: Stack: ... | par_3 | par_2 | par_1 | StringPtr
;Exit:  
;Destr: RDI, rcx, RAX (+ related to syscall)
;------------------------------------------------------------------------------------------------
MyPrintf:
    push rbp
    mov rbp, rsp 
    
    sub rsp, 6*8
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    add rsp, 6*8

    ;mov byte [Count], 8          ;Preparing rcx reg to count number of variables times 8 (Given value of 8 as it expects to get at least a string)
    sub rsp, 8          ;obtaining arguments from the stack (string)
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

    cmp byte [rsi], 0
    jne CreateBuffer
    mov byte [rdi+1], 0
    ;movsb
    ;________________________END___________________________

    mov rsp, rbp
    pop rbp

; add full documentation to it 
    mov rsi, Buffer
    call StrLen
    mov rdx, rcx  ; is to be replaced by function counting number of chars
    mov rdi, 1          ; sets output in console
    ;rsi is given
    mov rax, 1          ; в RAX - номер функции для вывода в поток 
    syscall 
    ret

PercentHandle:
    sub rsp, 8              ;Now rsp points to following argument in stack | StringAddress | par_1 | par_2 | par_3 | ... |

    xor rax, rax
    mov al, byte [rsi+1]
    sub rax, '%'
    ; shl rax, 3
    jmp [L4 + 8*rax]

    PercentT:
    jmp PrintPercent

    CharT:
    jmp PrintChar

    DecimalT:
    jmp PrintDecimal

    HexalT:
    jmp PrintHex

    BinT:
    jmp PrintBinary

    OctalT:
    jmp PrintOctal

    StringT:
    jmp PrintString

    PercentHandleDefault: ;print % 
    inc rsi
    jmp Ready


PrintPercent:
    ;sub rsp, 8
    ;sub qword [Count], 8          ; it does not requiere argument to print %, so don`t counts this
    mov byte [rdi], '%'
    inc rdi
    add rsi, 2          ; adding 2 as we have to skip another %
    jmp Ready

PrintDecimal:
    mov rax, [rsp] 
    add al, '0'
    mov byte [rdi], al ;stosb!
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

    mov eax, 10000000000000000000000000000000b ;80000000H

    add rsi, 2
    jmp Ready

PrintBinary:

    mov eax, 10000000000000000000000000000000b ;affraid to call it cringe
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
    mov byte [rdi], bl ;change to al
    inc rdi

    shr rax, 1

    cmp eax, 0h
    jne PBIN

    add rsi, 2
    jmp Ready

PrintHex:
    mov eax, 0f0000000h
    mov cl, 32 - 0fh

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
    sub bl, 0Ah
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
    xor rcx, rcx
    mov rcx, -1
    LengthCycle:
    inc rcx
    cmp byte [rsi+rcx], 0
    mov rax, [rsi+rcx]
    
    jne LengthCycle
    ret



section .data           ;Initialising variables in data segment

 

String db "%b is the best %b", 10, "$"   ;conditionally format string to print
Linux db "Linux$"

MessageToPrint db "it is original printf", 10, 0
OP db "Operation System$"
StringLen equ $-String; length of the String to make things a little bit easier
BufferLen dq 0

align 8 ;Выравнивать адреса по границам, кратным 8
L4:
    dq PercentT; %
    times 'a' - '%' dq PercentHandleDefault  
    dq BinT ;
    dq CharT ; 
    dq DecimalT ;
    times 'o' - 'd' - 1 dq PercentHandleDefault 
    dq OctalT ;
    times 3 dq PercentHandleDefault 
    dq StringT ;
    times 4 dq PercentHandleDefault  
    dq HexalT ;
    times 2 dq PercentHandleDefault

section .bss
Buffer resb 50
