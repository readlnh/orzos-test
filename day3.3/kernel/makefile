src=head.S
obj=head.o
elf=head.elf
boot=kernel.out
asm=head.asm
adress=0xc400

$(boot):$(src)
	gcc -c $(src) -m32 -o $(obj)
	ld -m elf_i386 $(obj) -e start -Ttext $(adress) -o $(elf)
	objcopy -S -O binary -j .text $(elf) $(boot)
	objdump -S $(elf) > $(asm)
fat12:
	@dd if=/dev/zero of=$(boot) seek=2 count=2878 >> /dev/zero
	@ls -al $(boot)

run:
	qemu-system-i386 -fda $(boot)

clean:
	-rm -f $(obj) $(elf) $(boot) $(asm)
