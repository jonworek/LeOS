all:
	nasm -f bin boot2stg.asm -o boot2stg.bin
	nasm -f bin cboot.asm -o cboot.bin
	
	cat boot2stg.bin cboot.bin > boot.img
	
clean:
	rm -rf *.bin
