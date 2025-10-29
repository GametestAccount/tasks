; https://syscalls.mebeim.net/?table=x86/64/x64/v6.5

global _start

section .data
    enter_msg db "Enter your string: "
    LEN_1 equ $ - enter_msg

    result_msg db "Reversed: "
    LEN_2 equ $ - result_msg

section .bss
    buffer resb 64               ; зарезервировать 64 байта в буфере

section .text
_start:
    mov rax, 1                   ; write()
    mov rdi, 1                   ; передаём дескриптор stdout
    mov rsi, enter_msg           ; передаём сообщение на вывод
    mov rdx, LEN_1               ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                  ; проверить возвращаемое значение
    je .exit_failure             ; если там -1, то аварийно завершаем программу

    mov rax, 0                   ; read()
    mov rdi, 0                   ; передаём дескриптор stdin
    mov rsi, buffer              ; передаём буфер, куда буду считываться данные
    mov rdx, 64                  ; передаём размер буфера в байтах
    syscall
    cmp rax, -1                  ; проверить возвращаемое значение
    je .exit_failure             ; если там -1, то аварийно завершаем программу

    mov r15, rax                 ; сохраняем количество прочитанных байт

    mov rdi, r15                 ; передаём в функцию количество байт в буфере
    dec rdi                      ; отбрасываем \n в конце
    call func_reverse

    mov rax, 1                   ; write()
    mov rdi, 1                   ; передаём дескриптор stdout
    mov rsi, result_msg          ; передаём сообщение на вывод
    mov rdx, LEN_2               ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                  ; проверить возвращаемое значение
    je .exit_failure             ; если там -1, то аварийно завершаем программу

    mov rax, 1                   ; write()
    mov rdi, 1                   ; передаём дескриптор stdout
    mov rsi, buffer              ; передаём сообщение на вывод
    mov rdx, r15                 ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                  ; проверить возвращаемое значение
    je .exit_failure             ; если там -1, то аварийно завершаем программу

    mov rax, 60                  ; exit()
    mov rdi, 0                   ; передаём EXIT_SUCCESS
    syscall

.exit_failure:
    mov rax, 60                  ; exit()
    mov rdi, 1                   ; передаём EXIT_FAILURE
    syscall

func_reverse:
    push rbp                     ; сохраняем значение RBP в стеке
    mov rbp, rsp                 ; копируем вершину стека в RBP

    ; rax = LEN / 2
    mov rax, rdi                 ; копируем количество байт в буфере (1-й аргумент функции)
    shr rax, 1                   ; деление на 2

    ; rcx = i
    mov rcx, 0                   ; i = 0

.loop:
    ; rsi = LEN - i - 1
    mov rsi, rdi
    sub rsi, rcx
    dec rsi

    mov r10b, [buffer + rcx]     ; копируем в регистр R10 байт buffer[i]
    mov r11b, [buffer + rsi]     ; копируем в регистр R11 байт buffer[LEN - i - 1]
    xchg r10, r11                ; меняем значения регистров между собой
    mov [buffer + rcx], r10b     ; возвращаем байт из R10 в память
    mov [buffer + rsi], r11b     ; возвращаем байт из R11 в память

    inc rcx                      ; i++
    cmp rcx, rax                 ; проверяем i
    jne .loop                    ; если i != LEN/2, то продолжаем цикл

    mov rsp, rbp                 ; восстанавливаем старое значение вершины стека
    pop rbp                      ; удаляем из стека RBP
    ret