; build:
;   nasm -f elf64 task1.asm
;   ld task1.o -o task1
;   ./task1

; listing: nasm -f elf64 task1.asm -l task1.lst
; tracing: strace ./task1 > strace_output.txt

global _start                      ; делаем метку _start видимой извне

section .data                      ; секция данных
    message db  "Hello world!", 10 ; строка для вывода на консоль
    length  equ $ - message

section .text                      ; объявление секции кода
_start:                            ; точка входа в программу
    mov rax, 1                     ; 1 - номер системного вызова функции write
    mov rdi, 1                     ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, message               ; адрес строки для вывод
    mov rdx, length                ; количество байтов
    syscall                        ; выполняем системный вызов write

    cmp rax, length                ; сравниваем возвращаемое значение с length
    jne is_failure_brunch
    mov rdi, 0                     ; если всё нормально, то rdi = 0 (EXIT_SUCCESS в Си)
    jmp next

is_failure_brunch:
    mov rdi, 1                     ; если системный вызов завершился неудачно, то rdi = 1 (EXIT_FAILURE в Си)

next:
    mov rax, 60                    ; 60 - номер системного вызова exit
    syscall                        ; выполняем системный вызов exit
