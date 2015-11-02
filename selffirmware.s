            ;;;
            ;;; PIC16(L)F1704 registers
            ;;;


            .gpr 0x020, 0x32F
            .sfr 0x00C, PORTA
            .sfr 0x00E, PORTC
            .sfr 0x011, PIR1
            .sfr 0x012, PIR2
            .sfr 0x013, PIR3
            .sfr 0x08C, TRISA
            .sfr 0x08E, TRISC
            .sfr 0x091, PIE1
            .sfr 0x092, PIE2
            .sfr 0x093, PIE3
            .sfr 0x099, OSCCON
            .sfr 0x10C, LATA
            .sfr 0x10E, LATC
            .sfr 0x18C, ANSELA
            .sfr 0x18E, ANSELC
            .sfr 0x199, RC1REG
            .sfr 0x19A, TX1REG
            .sfr 0x19B, SP1BRGL
            .sfr 0x19C, SP1BRGH
            .sfr 0x19D, RC1STA
            .sfr 0x19E, TX1STA
            .sfr 0x19F, BAUD1CON
            .sfr 0x20C, WPUA
            .sfr 0x20E, WPUC
            .sfr 0x28C, ODCONA
            .sfr 0x28E, ODCONC
            .sfr 0x30C, SLRCONA
            .sfr 0x30E, SLRCONC
            .sfr 0x38C, INLVLA
            .sfr 0x38E, INLVLC
            .sfr 0x391, IOCAP
            .sfr 0x392, IOCAN
            .sfr 0x393, IOCAF
            .sfr 0x397, IOCCP
            .sfr 0x398, IOCCN
            .sfr 0x399, IOCCF
            .sfr 0xE24, RXPPS
            .sfr 0xEA4, RC4PPS


            ;;;
            ;;; Various declarations
            ;;;


            ; RC0 = ~MCLR
            ; RC1 = ICSPCLK
            ; RC2 = ICSPDAT

            ; Delay counters
            .reg 2, delay0
            .reg 2, delay1

            ; Command decoding registers
            .reg 3, buf
            .reg 3, cmd
            .reg 3, datalen
            .reg 3, dataL
            .reg 3, dataH

            ; FCMEN = off, IESO = off, CLKOUTEN = off, BOREN = on, CP = off,
            ; PWRTE = off, WDTE = off, FOSC = INTOSC
            .cfg 0x8007, 0n00_1111_1110_0100
            ; LVP = on, DEBUG = off, LPBOR = off, BORV = low, STVREN = on,
            ; PLLEN = off, ZCDDIS = 1, PPS1WAY = on, WRT = off
            .cfg 0x8008, 0n11_1110_1111_1111


            ;;;
            ;;; Interrupt vectors
            ;;;


reset:      goto start
a0002:      nop
a0003:      nop

int:
            btfss PIR1, 5 ; RCIF
             retfie ; Not sure how we could get here.

            movf RC1REG, 0
            btfsc RC1STA, 2 ; FERR
             retfie
            movwf buf

            ; If cmd is 0, set cmd.
            movf cmd ; test cmd
            btfsc STATUS, 2 ; Z
             *bra set_cmd

            ; If cmd is 'L' and datalen < 2, set data.
            movf cmd, 0
            sublw 0x4C ; 'L'
            btfss STATUS, 2 ; Z
             retfie
            retfie

            ; If datalen is 2, return.  btfsc datalen, 1
             retfie
            ; Increment datalen.
            incf datalen
            ; If datalen is 2, set dataH.
            btfsc datalen, 1
             *bra set_dataH
            ; Else set dataL.
            movf buf, 0
            movwf dataL
            retfie
set_dataH:  movf buf, 0
            movwf dataH
            retfie

set_cmd:    movwf cmd
            clrf datalen
            retfie


            ;;;
            ;;; Main program
            ;;;

start:
            ;;; Set up ports. ;;;

            clrf LATC

            movlw 0n00000011 ; 1, 0
            movwf TRISA

            clrf ANSELA

            movlw 0n00101000 ; 5, 3
            movwf TRISC

            clrf ANSELC

            ;;; Set up clock. ;;;

            ; SPLLEN = off, IRCF = 1 MHz HF
            movlw 0n01011000
            movwf OSCCON

            ;;; Set up EUSART. ;;;

            ; RC5 in = RX
            movlw 0n00010101 ; RC5
            movwf RXPPS

            ; RC4 out = TX
            movlw 0n00010100 ; TX/CK
            movwf RC4PPS

            ; symbol rate = 1200 baud
            movlw 12
            movwf SP1BRGL

            ; TX9 = 8-bit, TXEN = on, SYNC = synchronous, BRGH = low speed
            movlw 0n00100000
            movwf TX1STA

            ; SCKP = non-inverted, BRG16 = 8-bit, ABDEN = no
            movlw 0n01000010
            movwf BAUD1CON

            ; RCIE = on
            movlw 0n00100000
            movwf PIE1

            ; GIE = on, PEIE = on
            movlw 0n11000000
            iorwf INTCON

            ; SPEN = on, RX9 = 8-bit, CREN = on
            movlw 0n10010000
            movwf RC1STA

            movlw 0x5F ; '_'
            call send_char

            ; 'N': eNter LVP
            ; 'X': eXit lVP
            ; 'C': load Configuration
            ; 'L': Load data for program memory
            ; 'D': reaD data from program memory
            ; 'I': Increment address
            ; 'A': reset Address
            ; 'P': begin internally timed Programming
            ; 'E': (begin Externally timed programming)
            ; 'F': (end externally timed programming)
            ; 'B': Bulk erase program memory
            ; 'R': (Row erase program memory)

handle_cmd:
            movf cmd, 0
            btfsc STATUS, 2 ; Z
             *bra handle_cmd

            call send_char

            ; If cmd is 'N'...
            movf cmd, 0
            sublw 0x4E
            btfsc STATUS, 2 ; Z
             *bra do_N
            ; If cmd is 'X'...
            movf cmd, 0
            sublw 0x58
            btfsc STATUS, 2 ; Z
             *bra do_X
            clrf cmd
            bra handle_cmd

do_N:       bcf LATC, 0
            clrf cmd
            bra handle_cmd

do_X:       bsf LATC, 0
            clrf cmd
            bra handle_cmd



delay:      movlw 1
            subwf delay0
            movlw 0
            subwfb delay1
            movf delay0
            btfsc STATUS, 2 ; Z
             *movf delay1
            btfss STATUS, 2 ; Z
             *bra delay

send_char:  btfss PIR1, 4 ; TXIF
             *bra send_char
            movwf TX1REG
            return
