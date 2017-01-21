src=orz.S
obj=orz.o
elf=boot.elf
boot=boot.out
asm=boot.asm



$(boot):$(orz.S)
	gcc -c $(src) -m32 -o $(obj)
	ld -m elf_i386 $(obj) -e start -Ttext 0x7c00 -o $(elf)
	objcopy -S -O binary -j .text $(elf)  $(boot)
	objdump -S $(elf) > $(asm)
fat12:
	@dd if=/dev/zero of=$(boot) seek=2 count=2878 >> /dev/zero
	@ls -al $(boot)

run:$(asm)
	qemu-system-i386 -fda $(boot)

writeusb:
	sudo dd if=$(boot) of=/dev/sdc4
runusb:writeusb
	sudo qemu-system-i386   -drive file=/dev/sdc4
clean:
	-rm -f $(obj) $(elf) $(boot) $(asm)

umount:
	sudo umount /dev/sdc4
