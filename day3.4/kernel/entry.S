#define CYLS    0x0ff0
#define LEDS    0x0ff1
#define VMODE   0x0ff2
#define SCRNX   0x0ff4
#define SCRNY   0x0ff6
#define VRAM    0x0ff8


#define BOTPAK          0X00280000
#define DSKCAC          0x00100000
#define DSKCAC0         0X00008000 

.set CR0_PE_ON,     0x1

.globl entry
entry:
    .code16

    jmp start
    
msg:
    .asciz "\r\n\rmy kernel is running"

try:
    .asciz "\r\n\rtry it again" 

puts:
    movb    (%si), %al
    add     $1, %si
    cmp     $0, %al
    je      over
    movb    $0x0e, %ah
    movw    $15, %bx
    int     $0x10
    jmp     puts

over:
    ret

start:
    /*初始化段*/
    xorw    %ax, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %ss
    /*vga，320×200×8bit*/
    movb    $0x13, %al
    movb    $0x00, %ah
    int     $0x10
    /*保存屏幕模式*/
    movb    $10, (CYLS)
    movb    $8, (VMODE)
    movw    $320, (SCRNX)
    movw    $200, (SCRNY)
    movl    $0x000a0000, (VRAM)
    /*通过BIOS获取键盘指示灯状态*/
    movb    $0x02, %ah
    int     $0x16
    movb    %al, (LEDS)
    /*防止pic接受所有中断*/
    movb    $0xff, %al
    outb    %al, $0x21
    nop
    outb    %al, $0xa1
    cli
    /*开启a20*/
    seta20.1:
        inb     $0x64, %al  //wait for not busy
        testb   $0x02, %al
        jnz     seta20.1
        movb    $0xd1, %al
        outb    %al, $0x64 //0xd1 -> port 0x64

    seta20.2:
        inb     $0x64, %al
        test    $0x02, %al
        jnz     seta20.2
        movb    $0xdf, %al
        outb    %al, $0x60

    lgdt    gdtdesc
    movl    %cr0, %eax
    andl    $0x7fffffff, %eax  //使用bit13（禁用分页）
    orl     $CR0_PE_ON, %eax   //0x1
    movl    %eax, %cr0

    ljmp    $(2*8), $protcseg

    .code32
protcseg:
    movw    $(1*8), %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %fs
    movw    %ax, %gs
    movw    %ax, %ss

    movl    $start, %esp //设置栈指针

ccode:
    movl    $main, %esi
    movl    $BOTPAK, %edi    //c语言复制到0x00280000
    movl    $(512*1024/4), %ecx
    call    memcpy

bootsector:
    movl    $0x7c00, %esi   //源
    movl    $DSKCAC, %edi   //引导复制到0x00100000
    movl    $(512/4), %ecx
    call    memcpy

all:
    movl    $(DSKCAC0+512), %esi
    movl    $(DSKCAC+512), %edi
    movl    $0, %ecx
    movb    (CYLS), %cl
    imul    $(512*18*2/4), %ecx
    subl    $(512/4), %ecx      //ipl偏移量
    call    memcpy

    pushl   $0x280000
    ret

memcpy:
    movl    (%esi), %eax
    addl    $4, %esi
    movl    %eax, (%edi)
    addl    $4, %edi
    subl    $1, %ecx
    jnz     memcpy
    ret

.p2align 2
gdt:
    .word 0x0000, 0x0000, 0x0000, 0x0000
    .word 0xffff, 0x0000, 0x9200, 0x00cf
    .word 0xffff, 0x0000, 0x9a00, 0x0047
    .word 0xffff, 0x0000, 0x9a28, 0x0047
    .word 0x00

gdtdesc:
    .word   31 //4*8-1
    .long   gdt

main:








    
       

