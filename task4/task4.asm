; https://syscalls.mebeim.net/?table=x86/64/x64/v6.5

global _start

section .data
    first_num_msg db "Enter 1 number: "
    LEN_1 equ $ - first_num_msg

    second_num_msg db "Enter 2 number: "
    LEN_2 equ $ - second_num_msg

    answer_msg db "Answer: "
    LEN_3 equ $ - answer_msg

section .bss
    buffer resb 64             ; зарезервировать 64 байта

section .text
_start:
    mov rax, 1                 ; write()
    mov rdi, 1                 ; передаём дескриптор stdout
    mov rsi, first_num_msg     ; передаём сообщение на вывод
    mov rdx, LEN_1             ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    mov rax, 0                 ; read()
    mov rdi, 0                 ; передаём дескриптор stdin
    mov rsi, buffer            ; передаём буфер, куда будут считываться данные
    mov rdx, 64                ; передаём размер буфера в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    dec rax                    ; не учитываем '\n' в конце

    mov rdi, buffer            ; передаём указатель на буфер
    mov rsi, rax               ; передаём количество считанных данных
    call func_stoi
    mov r12, rax               ; сохраним возвращаемое значение в r12

    mov rax, 1                 ; write()
    mov rdi, 1                 ; передаём дескриптор stdout
    mov rsi, second_num_msg    ; передаём сообщение на вывод
    mov rdx, LEN_2             ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    mov rax, 0                 ; read()
    mov rdi, 0                 ; передаём дескриптор stdin
    mov rsi, buffer            ; передаём буфер, куда буду считываться данные
    mov rdx, 64                ; передаём размер буфера в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    dec rax                    ; не учитываем '\n' в конце

    mov rdi, buffer            ; передаём указатель на буфер
    mov rsi, rax               ; передаём количество считанных данных
    call func_stoi
    mov r13, rax               ; сохраним возвращаемое значение в r13

    mov rdi, r12               ; передаём первое слагаемое
    mov rsi, r13               ; передаём второе слагаемое
    call func_sum

    mov rdi, rax               ; передаём сумму (число)
    mov rsi, buffer            ; передаём указатель на буфер
    call func_itos
    mov r14, rax               ; сохраняем в r14 количество записанных символов в буфере

    mov byte[buffer + r14], 10 ; добавим \n в конец буфера
    inc r14                    ; инкрементируем кол-во символов в буфере

    mov rax, 1                 ; write()
    mov rdi, 1                 ; передаём дескриптор stdout
    mov rsi, answer_msg        ; передаём сообщение на вывод
    mov rdx, LEN_3             ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    mov rax, 1                 ; write()
    mov rdi, 1                 ; передаём дескриптор stdout
    mov rsi, buffer            ; передаём буфер с сообщением на вывод
    mov rdx, r14               ; передаём размер сообщения в байтах
    syscall
    cmp rax, -1                ; проверить возвращаемое значение
    je .exit_failure           ; если там -1, то аварийно завершаем программу

    mov rax, 60                ; exit()
    mov rdi, 0                 ; передаём EXIT_SUCCESS
    syscall

.exit_failure:
    mov rax, 60                ; exit()
    mov rdi, 1                 ; передаём EXIT_FAILURE
    syscall

; Функция вычисление суммы двух чисел
; Аргументы:
;   A - первое слагаемое;
;   B - второе слагаемое.
; Возвращаемое значение: сумма чисел
func_sum:
    add rdi, rsi               ; A + B
    mov rax, rdi               ; вернуть результат из функции
    ret

; Функция преобразования строки в число
; Аргументы:
;   buf - указатель на буфер с числом;
;   BUF_LEN - количество байт в буфере.
; Возвращаемое значение: преобразованное число
func_stoi:
    mov r8, 0                  ; sum = 0
    mov r9, 1                  ; mult = 1
    lea r10, [rdi + rsi]       ; rbuf = &buf[BUF_LEN]

.loop:
    ; rbuf -= 1
    dec r10

    ; digit = *rbuf - '0'
    mov r11, 0
    mov r11b, [r10]
    sub r11, '0'

    ; sum += digit * mult
    imul r11, r9
    add r8, r11

    ; mult *= 10
    imul r9, 10

    cmp rdi, r10
    jb .loop                   ; если buf < rbuf то переходим в начало

    mov rax, r8                ; вернуть результат из функции
    ret

; Функция преобразования числа в строку
; Аргументы:
;   m - число
;   buf - указатель на буфер с числом;
; Возвращаемое значение: количество байт, записанных в буфер
func_itos:
    mov r8, 10                 ; b = 10
    mov r9, 0                  ; i = 0

.loop:
    mov rax, rdi
    cqo                        ; расширяем RDX знаковым битом из RAX
    div r8

    add rdx, '0'               ; прибавляем к остатку '0'

    mov [rsi + r9], dl         ; buf[i] = m % 10

    mov rdi, rax               ; m /= 10
    inc r9                     ; i += 1
    cmp rdi, 0
    jnz .loop                  ; если m != 0, то возвращаемся в начало

    mov rdi, rsi               ; передать указатель на буфер
    mov rsi, r9                ; передать размер данных в буфере
    call func_reverse

    mov rax, r9                ; вернуть результат из функции
    ret

; Функция переворота массива
; Аргументы:
;   buf - указатель на буфер;
;   BUF_LEN - количество байт в буфере.
; Возвращаемое значение: преобразованное число
func_reverse:
    ; rax = LEN / 2
    mov rax, rsi               ; копируем количество байт в буфере
    shr rax, 1                 ; деление на 2

    ; rcx = i
    mov rcx, 0                 ; i = 0

.loop:
    ; r8 = LEN - i - 1
    mov r8, rsi
    sub r8, rcx
    dec r8

    mov r10b, [rdi + rcx]      ; копируем в регистр R10 байт buffer[i]
    mov r11b, [rdi + r8]       ; копируем в регистр R11 байт buffer[LEN - i - 1]
    xchg r10, r11              ; меняем значения регистров между собой
    mov [rdi + rcx], r10b      ; возвращаем байт из R10 в память
    mov [rdi + r8], r11b       ; возвращаем байт из R11 в память

    inc rcx                    ; i++
    cmp rcx, rax               ; проверяем i
    jne .loop                  ; если i != LEN/2, то продолжаем цикл

    ret