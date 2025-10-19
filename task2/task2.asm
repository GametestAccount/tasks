; https://syscalls.mebeim.net/?table=x86/64/x64/v6.5

; build:
;   nasm -f elf64 task2.asm
;   ld task2.o -o task2
;   ./task2

; listing: nasm -f elf64 task2.asm -l task2.lst
; tracing: strace ./task2 > strace_output.txt

global _start                      ; делаем метку _start видимой извне

section .data                      ; секция данных
    message db  "Hello world!", 10 ; строка для вывода
    length  equ $ - message

    filename db  "test.txt", 0     ; строка с именем файла (и завершающим нулевым символом)

section .text                      ; объявление секции кода
_start:                            ; точка входа в программу
    mov rax, 85                    ; creat()
    mov rdi, filename              ; передаём адрес строки с именем файла
    mov rsi, 644Q                  ; передаём значение прав на файл (владелец всё может, а остальные только читают)
    syscall                        ; выполняем системный вызов creat()
    cmp rax, 0                     ; проверяем возвращаемое значение
    je exit_failure                ; если там NULL, то аварийно завершаем программу

    mov r8, rax                    ; сохраняем дескриптор на открытый файл в регистр R8

    mov rax, 1                     ; write()
    mov rdi, r8                    ; передаём указатель на открытый файл
    mov rsi, message               ; адрес строки для вывод
    mov rdx, length                ; количество байтов
    syscall                        ; выполняем системный вызов write()
    cmp rax, length                ; проверяем возвращаемое значение
    jne exit_failure               ; если там НЕ length, то аварийно завершаем программу

    mov rax, 3                     ; close()
    mov rdi, r8                    ; передаём указатель на открытый файл
    syscall                        ; выполняем системный вызов close()
    cmp rax, 0                     ; проверяем возвращаемое значение
    jne exit_failure               ; если там НЕ 0, то аварийно завершаем программу

    mov rax, 60                    ; exit()
    mov rdi, 0                     ; передаём EXIT_SUCCESS
    syscall                        ; выполняем системный вызов exit(EXIT_SUCCESS)

exit_failure:
    mov rax, 60                    ; exit()
    mov rdi, 1                     ; передаём EXIT_FAILURE
    syscall                        ; выполняем системный вызов exit(EXIT_FAILURE)
