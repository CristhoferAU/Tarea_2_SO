# comandos desde consola: 
# 1. make 
# 2. make run


ASM=nasm

# carpeta de archivos fuente
SRC_DIR=src
# carpeta de archivos generados
BUILD_DIR=build

# archivos de entrada
BOOTLOADER_SRC=$(SRC_DIR)/bootloader.asm
my_name_SRC=$(SRC_DIR)/my_name.asm

# archivos de salida en la carpeta build
BOOTLOADER_BIN=$(BUILD_DIR)/bootloader.bin
my_name_BIN=$(BUILD_DIR)/my_name.bin
BOOTLOADER_IMG=$(BUILD_DIR)/bootloader.img
BINARY_IMG=$(BUILD_DIR)/BinarioImg.txt

# unir los binarios del bootloader y el juego en una imagen para escribirlo en el USB
$(BOOTLOADER_IMG): $(BOOTLOADER_BIN) $(my_name_BIN)
	cat $(BOOTLOADER_BIN) $(my_name_BIN) > $(BOOTLOADER_IMG)
	truncate -s 1440k $(BOOTLOADER_IMG)

# crear el binario del bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	$(ASM) $(BOOTLOADER_SRC) -f bin -o $(BOOTLOADER_BIN)

# crear el binario del juego
$(my_name_BIN): $(my_name_SRC)
	$(ASM) $(my_name_SRC) -f bin -o $(my_name_BIN)

# crear archivo para visualizar lo que se escribe en memoria
$(BINARY_IMG): $(BOOTLOADER_IMG)
	xxd $(BOOTLOADER_IMG) > $(BINARY_IMG)

# ejecutar juego
run:
	qemu-system-i386 -hda $(BOOTLOADER_IMG)

# limpiar el directorio build
clean:
	rm -rf $(BUILD_DIR)




