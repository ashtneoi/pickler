            ;;;
            ;;; PIC16F1704 registers
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
            .sfr 0x095, OPTION_REG
            .sfr 0x096, PCON
            .sfr 0x099, OSCCON
            .sfr 0x09A, OSCSTAT
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
            .sfr 0x211, SSP1BUF
            .sfr 0x212, SSP1ADD
            .sfr 0x213, SSP1MSK
            .sfr 0x214, SSP1STAT
            .sfr 0x215, SSP1CON1
            .sfr 0x216, SSP1CON2
            .sfr 0x217, SSP1CON3
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
            .sfr 0xE20, SSPCLKPPS
            .sfr 0xE21, SSPDATPPS
            .sfr 0xE22, SSPSSPPS
            .sfr 0xE24, RXPPS
            .sfr 0xE90, RA0PPS
            .sfr 0xE91, RA1PPS
            .sfr 0xE92, RA2PPS
            .sfr 0xE94, RA4PPS
            .sfr 0xE95, RA5PPS
            .sfr 0xEA0, RC0PPS
            .sfr 0xEA1, RC1PPS
            .sfr 0xEA2, RC2PPS
            .sfr 0xEA3, RC3PPS
            .sfr 0xEA4, RC4PPS
            .sfr 0xEA5, RC5PPS


            ;;;
            ;;; various declarations
            ;;;


            .reg 0, delay0


            ; FCMEN = off, IESO = off, CLKOUTEN = off, BOREN = on, CP = off,
            ; PWRTE = off, WDTE = off, FOSC = INTOSC
            .cfg 0x8007, 0n00_1111_1110_0100
            ; LVP = on, DEBUG = off, LPBOR = off, BORV = low, STVREN = on,
            ; PLLEN = off, ZCDDIS = 1, PPS1WAY = on, WRT = off
            .cfg 0x8008, 0n11_1110_1111_1111


            ;;;
            ;;; interrupt vectors
            ;;;


reset:      goto start
a0002:      nop
a0003:      nop

int:        retfie


            ;;;
            ;;; main program
            ;;;


start:
            ;;; Set up clock. ;;;

            ; SPLLEN = off, IRCF = 4 MHz HF
            movlw 0n01101000
            movwf OSCCON

            ;;; Set up ports. ;;;

            ; SDO (RA4): out 0
            ; SCK (RA5): out 0
            ;  RX (RC0): in (digital)
            ;     (RC1): out 0
            clrf LATA
            clrf LATC
            movlw 0n11001111
            movwf TRISA
            movlw 0n11111101
            movwf TRISC
            movlw 0n11001111
            movwf ANSELA
            movlw 0n11111110
            movwf ANSELC

            ; SDO -> RA4
            movlw 0n10010 ; SDO
            movwf RA4PPS

            ; SCK <- RA5
            movlw 0n00101 ; RA5
            movwf SSPCLKPPS

            ; SCK -> RA5
            movlw 0n10000 ; SCK
            movwf RA5PPS

            ; RX <- RC0
            movlw 0n10000 ; RC0
            movwf RXPPS

            ; ~SS <- RC3 (unused)
            movlw 0n10011 ; RC3
            movwf SSPSSPPS

            ; SDI <- RC3 (unused)
            movlw 0n10011 ; RC3
            movwf SSPDATPPS

            ;;; Set up EUSART. ;;;

            ; symbol rate = 2400 baud
            movlw 25
            movwf SP1BRGL

            ; BRG16 = 8-bit, WUE = off, ABDEN = off
            movlw 0n01000000
            movwf BAUD1CON

            ; TX9 = 8-bit, TXEN = off, SYNC = async, BRGH = low speed
            movlw 0n00000010
            movwf TX1STA

            ; SPEN = off, RX9 = 8-bit, CREN = on
            movlw 0n00010000
            movwf RC1STA

            ;;; Set up MSSP. ;;;

            ; SSPEN = off, SSPM[3:0] = SPI master @ F_OSC/64
            movlw 0n00010010
            movwf SSP1CON1

            ;;; Wait for oscillator to stabilize. ;;;

            movlb OSCSTAT
_s1:        btfss OSCSTAT, 0 ; HFIOFS
              *bra _s1

            ;;; Enable EUSART and MSSP. ;;;

            bsf RC1STA, 7 ; SPEN = on

            bsf SSP1CON1, 5 ; SSPEN = on

            ;;; Bridge EUSART and MSSP. ;;;

recv:       btfss PIR1, 5 ; RCIF
              *bra recv
            bcf PIR1, 5 ; RCIF
            btfsc RC1STA, 2 ; FERR
              *bra skip
            movf RC1REG, 0
            movwf SSP1BUF
            movlb PIR1
shift:      btfss PIR1, 3 ; SSP1IF
              *bra shift
            bcf PIR1, 3 ; SSP1IF
            movlw 0n00000010
            xorwf LATC
            bra recv

skip:       movf RC1REG, 0
            bra recv


            ;;;
            ;;; delay3u5
            ;;;
            ;;; A movlw and call to delay3u5 delays for 3n + 5 µs (with a 4 MHz
            ;;; system clock).
            ;;;


delay3u5:   decfsz WREG
             *bra delay3u5
            return


            ;;;
            ;;; delay500u7
            ;;;
            ;;; A movlw and call to delay500u7 delays for 500n + 7 µs (with a 4
            ;;; MHz system clock).
            ;;;


delay500u7: movlb delay0
            *movwf delay0
_d500u7lp:  movlw 165
_d500u7d3:  *decfsz WREG
             *bra _d500u7d3
            nop
            nop
            *decfsz delay0
             *bra _d500u7lp
            return
