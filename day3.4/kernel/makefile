#this makefile will create  "head" file and "ckernel" file
#then cat "ckernel" file  >> "head" ,last mv  "head"  "kernel"
OBJCOPY	:= $(GCCPREFIX)objcopy
OBJDUMP	:= $(GCCPREFIX)objdump
entry_objs= entry.o
ccode_objs=main.o asmhead.o
CFLAGS := $(CFLAGS) -O1 -fno-builtin $(include) -MD
CFLAGS += -fno-omit-frame-pointer -w
CFLAGS += -Wall -Wno-format -Wno-unused  -gstabs -m32  -fno-stack-protector
LDFLAGS = -m elf_i386
addr=0xc400

#this will make c source compiled  to  object file
%.o:%.c
	$(CC) -nostdinc $(CFLAGS) -Os -c -o $@ $<

#will generate  entry.o asmint32.o
%.o:%.S
	$(CC) -nostdinc $(CFLAGS) -c -o $@ $<



kernel.out:head ckernel
	cat ckernel >> head
	cp  head kernel.out

head:$(entry_objs)
ckernel:$(ccode_objs)

#generate head file
head:
	@echo "addr=$(addr)"
	$(LD)  $(LDFLAGS) -N -e entry -Ttext 0xc400 -o $@.out $^
	$(OBJDUMP) -S -D $@.out >$@.asm
	$(OBJCOPY) -S -O binary -j .text $@.out $@

#generate ckernel
ckernel:
	@echo "addr=0x280000"
	$(LD)  $(LDFLAGS) -N -e bootmain -T kernel.ld -o $@.out $^  

#/lib/i386-linux-gnu/libgcc_s.so.1
	$(OBJDUMP)  -S -D $@.out >$@.asm
	$(OBJCOPY)  -S -O binary  $@.out $@


clean:
	-rm -f  *.o *.out  *.d head ckernel kernel *.asm entry








