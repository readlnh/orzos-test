#目的

利用int0x13读取u盘，软盘后面扇区的过程
读取u盘的第2个扇区到内存

es:bx=0x820:0x0000
ch=0    c
dh=0    h
cl=2    s

```
dl=0x00  ;driver number 这个是区分u盘，软盘，硬盘的数字
ah=0x01  ;read
al=1     ; one sector
bx=0
int 0x13
```
