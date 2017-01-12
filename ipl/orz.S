.global start
.code16
start:

    jmp entry

    .byte 0x00
    .ascii "Orzos   "
    .word 512
    .byte 1
    .word 1
    .byte 2
    .word 224
    .word 2880
    .byte 0xf0
    .word 9
    .word 18 
    .word 2
    .long 0
    .long 2880
    .byte 0,0,0x29
    .long 0xffffffff
    .ascii "Orzorzorz  "
    .ascii "fat12   "
    .fill 18

entry:
    mov $0,%ax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%ss
    mov $0x7c00,%sp
    mov %dl,(0x7def)  //把设备的drive number保存到地址0x7def

    mov $msg,%si
    call puts

    /*memory=0x8200,chs=002*/
    mov $0x820,%ax
    mov %ax,%es
    mov $0,%bx
    mov $0,%ch
    mov $0,%dh
    mov $2,%cl
    call read
    mov $okmsg,%si
    call puts

loop:
    jmp loop

read:
    mov (0x7def),%dl    //把设备的drive number存入dl
    //mov $0x00,%dl     //软盘是0x00
    mov $0x02,%ah       //读盘
    mov $1,%al           //一个扇区
    int $0x13
    jc error
    ret

error:
    mov $errormsg,%si
    call puts
    hlt
    jmp loop
    

puts:
    movb (%si),%al
    add $1,%si
    cmp $0,%al
    je finish
    movb $0x0e,%ah
    movw $15,%bx
    int $0x10
    jmp puts

finish:
    ;hlt
    ret

msg:
    .asciz "\r\nOrzorzorzzzzz\n"

okmsg:
    .asciz "\r\nOkkkkkkkkkk\n"

errormsg:
    .asciz "\r\nErrorrrrrrr\n"

.org 510
.word 0xaa55
