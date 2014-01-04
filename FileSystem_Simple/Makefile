all:
	nasm -f bin boot.asm -o boot.img
	nasm -f bin stage2.asm -o stage2.sys
	
	cp stage2.sys ./floppyimg
	
clean:
	rm -rf *.bin
