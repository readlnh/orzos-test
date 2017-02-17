void write_mem8(int addr, int data);

void bootmain() {
    int i;
    for(i = 0xa0000; i <= 0xaffff; i++) {
        write_mem8(i, 15);
    }
    while(1);    
}
