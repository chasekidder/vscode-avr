@echo off
:: #########################################################
:: # Author: Chase Kidder (https://github.com/chasekidder) #
:: # Written for the Purdue ECET Program on 4.24.2020      #
:: # Description:                                          #
:: # Compiles and uploads all .c files in the directory to #
:: # the AVR of choice.                                    #
:: # NOTES:                                                #
:: # ** THIS SCRIPT IS WINDOWS ONLY!!! **                  #
:: # For a UNIX/Linux script see the corresponding Makefile#
:: #########################################################

:: ################################
:: # \/ Change These Variables \/ #
:: ################################

:: ** THERE CAN'T BE SPACES BETWEEN THE EQUALS SIGN AND THE TEXT **

:: Path To Arduino Installation Folder
SET ARDUINOPATH=C:/Program Files (x86)/Arduino

:: COM Port
SET COMPORT=COM4

:: uC Type (UNO=atmega328p, MEGA=atmega2560)
SET MCU=atmega2560




:: ############################################################
:: # \/ DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING!! \/ #
:: ############################################################

:: #######################
:: # \/ CONFIGURATION \/ #
:: #######################

::  Main hex file path looking in same folder as .cmd file
SET MAIN_HEX_PATH="%CD%/main.hex"

:: GCC Paths
SET CC="%ARDUINOPATH%/hardware/tools/avr/bin/avr-gcc.exe"
SET OBJCOPY="%ARDUINOPATH%/hardware/tools/avr/bin/avr-objcopy.exe"
SET AVRDUDE="%ARDUINOPATH%/hardware/tools/avr/bin/avrdude.exe"
SET OBJDUMP="%ARDUINOPATH%/hardware/tools/avr/bin/avr-objdump.exe"

:: Config Path
SET CONFIG="%ARDUINOPATH%/hardware/tools/avr/etc/avrdude.conf"

:: Options for avr-gcc
SET CFLAGS=-g 

:: Linking options for avr-gcc
SET LFLAGS=-Os -mmcu=%MCU% -o

:: Options for HEX file generation
SET HFLAGS=-j .text -j .data -O ihex

:: Options for avrdude to burn the hex file (if needed you can copy these settings
:: from the arduino ide's commands)
SET MCUFLAG=-p %MCU%  
SET PORTFLAG=-P %COMPORT%
SET BAUDFLAG=-b 115200
SET CONFIGFLAG=-C %CONFIG%
SET FLASHFLAG=-U flash:w:%MAIN_HEX_PATH%:i

:: The headers files needed for building the application
SET INCLUDE=-I. 




:: ####################
:: # \/ MAIN LOGIC \/ #
:: ####################

:: Change to match programming mode (UNO = arduino, MEGA = wiring)
IF %MCU%==atmega328p ( SET PGMFLAG=-c arduino )
IF %MCU%==atmega2560 ( SET PGMFLAG=-c wiring )

:: Get List of All .c Files
FOR %%i IN (*.c) DO call set "SRC=%%SRC%% %%i"

CALL :compiler
CALL :linker
CALL :build
CALL :burn
CALL :clean
EXIT /B 0




:: ########################
:: # \/ FUNCTION LOGIC \/ #
:: ########################

:: Flash .hex to microcontroller
:burn 
    %AVRDUDE% %PGMFLAG% %MCUFLAG% %PORTFLAG% %BAUDFLAG% %CONFIGFLAG% -D %FLASHFLAG%
    EXIT /B 0

:: Build .hex file
:build
    %OBJCOPY% %HFLAGS% main.elf main.hex
    EXIT /B 0

:: Generate .elf files
:linker
	%CC% %SRC% %INCLUDE% %LFLAGS% main.elf
    EXIT /B 0
	
:: Generate .o files
:compiler
	%CC% %SRC% %INCLUDE% %CFLAGS% %LFLAGS% main.o
    EXIT /B 0

:: Remove compiled files
:clean
	del *.hex
	del *.elf
	del /S *.o
    EXIT /B 0

:: Test connection to microcontroller
:test
	%AVRDUDE% -v %CONFIGFLAG% %PGMFLAG% %MCUFLAG% %PORTFLAG%
    EXIT /B 0

