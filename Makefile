#########################################################
# Author: Chase Kidder (https://github.com/chasekidder) #
# Written for the Purdue ECET Program on 4.24.2020      #
# Description:                                          #
# Compiles and uploads all .c files in the directory to #
# the AVR of choice.                                    #
# NOTES:                                                #
# ** THIS SCRIPT IS DESIGNED FOR UNIX/LINUX!!! **       #
# For a Windows script see the corresponding .cmd file  #
# This depends on GNU make being installed              #
#########################################################

################################
# \/ Change These Variables \/ #
################################

# Path To Arduino Installation Folder
# MACOS: 
ARDUINOPATH = /Applications/Arduino.app/Contents/Java

# COM Port
COMPORT = COM5

# uC Type (UNO = atmega328p, MEGA = atmega2560)
MCU = atmega2560




############################################################
# \/ DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING!! \/ #
############################################################

#######################
# \/ CONFIGURATION \/ #
#######################

# Main hex file path looking in same folder as makefile
MAIN_HEX_PATH = "$(CURDIR)/main.hex"

# GCC Paths
CC = "$(ARDUINOPATH)/hardware/tools/avr/bin/avr-gcc"
OBJCOPY = "$(ARDUINOPATH)/hardware/tools/avr/bin/avr-objcopy"
AVRDUDE := "$(ARDUINOPATH)/hardware/tools/avr/bin/avrdude"
OBJDUMP = "$(ARDUINOPATH)/hardware/tools/avr/bin/avr-objdump"

# Config Path
CONFIG = "$(ARDUINOPATH)/hardware/tools/avr/etc/avrdude.conf"

#Options for avr-gcc
CFLAGS = -g 

#Linking options for avr-gcc
LFLAGS = -Os -mmcu=$(MCU) -o

#Options for HEX file generation
HFLAGS = -j .text -j .data -O ihex

#Options for avrdude to burn the hex file (if needed you can copy these settings
# from the arduino ide's commands)
MCUFLAG = -p $(MCU)  
PORTFLAG = -P $(COMPORT) 
BAUDFLAG = -b 115200
CONFIGFLAG = -C $(CONFIG)
FLASHFLAG = -U flash:w:$(MAIN_HEX_PATH):i


# Get List of All .c Files
SRC = $(wildcard $(CURDIR)/*.c)

# The headers files needed for building the application
INCLUDE = -I. 

# Change to match programming mode (UNO = arduino, MEGA = wiring)
ifeq ($(MCU), atmega328p) 
	PGMFLAG = -c arduino 
endif
ifeq ($(MCU), atmega2560) 
	PGMFLAG = -c wiring
endif



#######################
# \/ MAKE COMMANDS \/ #
#######################

# Flash .hex to microcontroller
Burn : Build
	$(AVRDUDE) $(PGMFLAG) $(MCUFLAG) $(PORTFLAG) $(BAUDFLAG) $(CONFIGFLAG) -D $(FLASHFLAG)
	make clean

# Generate .hex file
Build : main.elf
	$(OBJCOPY) $(HFLAGS) $< main.hex

# Generate .elf files
main.elf: main.o
	$(CC) $(SRC) $(INCLUDE) $(LFLAGS) $@
	
# Generate .o files
main.o:
	$(CC) $(SRC) $(INCLUDE) $(CFLAGS) $(LFLAGS) $@

# Remove compiled files
clean:
	rm -f *.hex *.elf *.o
	$(foreach dir, $(EXT), del $(dir)/*.o;)
	
# Test connection to microcontroller
test:
	$(AVRDUDE) -v $(CONFIGFLAG) $(PGMFLAG) $(MCUFLAG) $(PORTFLAG)

