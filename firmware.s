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

            .reg B0
            .reg B1


            ; FCMEN = off, IESO = off, CLKOUTEN = off, BOREN = on, CP = off,
            ; PWRTE = off, WDTE = off, FOSC = INTOSC
            .cfg 0x8005, 0n00_1111_1110_0100
            ; LVP = on, DEBUG = off, LPBOR = off, BORV = low, STVREN = on,
            ; PLLEN = off, ZCDDIS = 1, PPS1WAY = on, WRT = off
            .cfg 0x8006, 0n11_1110_1111_1111


reset:      goto start
a0002:      nop
a0003:      nop
int:
            btfsc RC1STA, 2 ; FERR
             *bra frame_err
            btfss PIR1, 5 ; RCIF
             retfie
            movf RC1REG, 0
wait_rdy:   btfss PIR1, 4 ; TXIF
             *bra wait_rdy
            movwf TX1REG
            retfie
frame_err:  movf RC1REG, 0
            retfie


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

blink1:     movlw 0xFF
            movwf B0
            movlw 0x80
            movwf B1

blink2:     movlw 1
            subwf B0
            movlw 0
            subwfb B1
            movf B0
            btfsc STATUS, 2 ; Z
             movf B1
            btfss STATUS, 2 ; Z
             *bra blink2

            movlw 0n00000100
            xorwf LATC

            bra blink1
