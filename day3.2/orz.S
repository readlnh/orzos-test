.global start
.code16
start:

    jmp entry
    /*定义fat12文件格式*/
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
    mov %dl,(0x7dfe)  //把设备的drive number保存到地址0x7def

    mov $msg,%si
    call puts

    /*memory=0x8200,chs=002*/
    mov $0x800,%ax
    mov %ax,%es
    mov $0,%bx      //es:bx=缓冲地址
    
    mov $0,%ch      //柱面0
    mov $0,%dh      //磁头0
    mov $1,%cl      //扇区1
   
/*读取63个扇区(我的u盘是63扇区，原书是18因为是软盘)*/
readloop:
    mov $0x00,%si  //记住读取扇区失败的次数
    call read

    /*把内存地址后移0x200*/
    mov %es,%ax
    add $0x0020,%ax
    mov %ax,%es

    /*循环计数，一直读64次，cl<=63继续读*/
    add $1,%cl
    cmp $63,%cl
    jbe readloop

    /*读6个head*/
    mov $0x01,%cl
    add $1,%dh
    cmp $6,%dh
    jb readloop

    /*读出内存中ds:bx=0x34ff:0xf的数据到寄存器cl,与0xaa做比较，
      如果相等，则说明读取u盘中的数据到内存没有问题，可以进行下一步了。*/
    /*push %ds
    mov $0x34ff,%ax;
    mov %ax,%ds
    mov $0xf,%bx
    mov (%bx),%cl
    
    pop %ds //恢复ds
    cmp $0xaa,%cl
    je usbok
    mov $errorusbmsg,%si
    call puts*/

loop:
    jmp loop

read:
    mov (0x7dfe),%dl    //把设备的drive number存入dl
    //mov $0x00,%dl     //软盘是0x00
    mov $0x02,%ah       //读盘
    mov $1,%al          //一个扇区 one sector
    int $0x13
    jnc over            //如果没有进位就成功了
    
    /*如果失败计数，如果出错次数到5次，报错*/ 
    add $1,%si
    cmp $5,%si
    jae error
    
    /*ah=0x00,重新启动系统,dl=0x00,设备为软盘*/
    mov $0x00,%ah
    mov $0x00,%dl
    int $0x13
    jmp read

over:
    ret
    

error:
    mov $errormsg,%si
    call puts
    jmp loop

usbok:
    mov $msgusb,%si
    call puts
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
    .asciz "\nOrzorzorzzzzz\n"

okmsg:
    .asciz "Okkkkkkkkkk\n"

errormsg:
    .asciz "\nErrorrrrrrr\n"

errorusbmsg:
    .asciz "\nUsbErrorrrrrrr\n"

msgusb:
    .asciz "\r\nlast sector of usb is ok\n"

.org 510
.word 0xaa55
