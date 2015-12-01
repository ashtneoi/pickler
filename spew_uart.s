            ;;;
            ;;; PIC12F1572 registers
            ;;;


            .gpr 0x020, 0x0BF

            .sfr 0x00C, PORTA
            .sfr 0x011, PIR1
            .sfr 0x012, PIR2
            .sfr 0x013, PIR3
            .sfr 0x015, TMR0
            .sfr 0x016, TMR1L
            .sfr 0x017, TMR1H
            .sfr 0x018, T1CON
            .sfr 0x019, T1GCON
            .sfr 0x01A, TMR2
            .sfr 0x01B, PR2
            .sfr 0x01C, T2CON

            .sfr 0x08C, TRISA
            .sfr 0x091, PIE1
            .sfr 0x092, PIE2
            .sfr 0x093, PIE3
            .sfr 0x095, OPTION_REG
            .sfr 0x096, PCON
            .sfr 0x097, WDTCON
            .sfr 0x098, OSCTUNE
            .sfr 0x099, OSCCON
            .sfr 0x09A, OSCSTAT
            .sfr 0x09B, ADRESL
            .sfr 0x09C, ADRESH
            .sfr 0x09D, ADCON0
            .sfr 0x09E, ADCON1
            .sfr 0x09F, ADCON2

            .sfr 0x10C, LATA
            .sfr 0x111, CM1CON0
            .sfr 0x112, CM1CON1
            .sfr 0x115, CMOUT
            .sfr 0x116, BORCON
            .sfr 0x117, FVRCON
            .sfr 0x118, DACCON0
            .sfr 0x119, DACCON1
            .sfr 0x11D, APFCON

            .sfr 0x18C, ANSELA
            .sfr 0x191, PMADRL
            .sfr 0x192, PMADRH
            .sfr 0x193, PMDATL
            .sfr 0x194, PMDATH
            .sfr 0x195, PMCON1
            .sfr 0x196, PMCON2
            .sfr 0x197, VREGCON
            .sfr 0x199, RCREG
            .sfr 0x19A, TXREG
            .sfr 0x19B, SPBRGL
            .sfr 0x19C, SPBRGH
            .sfr 0x19D, RCSTA
            .sfr 0x19E, TXSTA
            .sfr 0x19F, BAUDCON

            .sfr 0x20C, WPUA

            .sfr 0x28C, ODCONA

            .sfr 0x30C, SLRCONA

            .sfr 0x38C, INLVLA
            .sfr 0x391, IOCAP
            .sfr 0x392, IOCAN
            .sfr 0x393, IOCAF

            .sfr 0x691, CWG1DBR
            .sfr 0x692, CWG1DBF
            .sfr 0x693, CWG1CON0
            .sfr 0x694, CWG1CON1
            .sfr 0x695, CWG1CON2

            .sfr 0xD8E, PWMEN
            .sfr 0xD8F, PWMLD
            .sfr 0xD90, PWMOUT
            .sfr 0xD91, PWM1PHL
            .sfr 0xD92, PWM1PHH
            .sfr 0xD93, PWM1DCL
            .sfr 0xD94, PWM1DCH
            .sfr 0xD95, PWM1PRL
            .sfr 0xD96, PWM1PRH
            .sfr 0xD97, PWM1OFL
            .sfr 0xD98, PWM1OFH
            .sfr 0xD99, PWM1TMRL
            .sfr 0xD9A, PWM1TMRH
            .sfr 0xD9B, PWM1CON
            .sfr 0xD9C, PWM1INTE
            .sfr 0xD9D, PWM1INTF
            .sfr 0xD9E, PWM1CLKCON
            .sfr 0xD9F, PWM1LDCON
            .sfr 0xDA0, PWM1OFCON
            .sfr 0xDA1, PWM2PHL
            .sfr 0xDA2, PWM2PHH
            .sfr 0xDA3, PWM2DCL
            .sfr 0xDA4, PWM2DCH
            .sfr 0xDA5, PWM2PRL
            .sfr 0xDA6, PWM2PRH
            .sfr 0xDA7, PWM2OFL
            .sfr 0xDA8, PWM2OFH
            .sfr 0xDA9, PWM2TMRL
            .sfr 0xDAA, PWM2TMRH
            .sfr 0xDAB, PWM2CON
            .sfr 0xDAC, PWM2INTE
            .sfr 0xDAD, PWM2INTF
            .sfr 0xDAE, PWM2CLKCON
            .sfr 0xDAF, PWM2LDCON
            .sfr 0xDB0, PWM2OFCON
            .sfr 0xDB1, PWM3PHL
            .sfr 0xDB2, PWM3PHH
            .sfr 0xDB3, PWM3DCL
            .sfr 0xDB4, PWM3DCH
            .sfr 0xDB5, PWM3PRL
            .sfr 0xDB6, PWM3PRH
            .sfr 0xDB7, PWM3OFL
            .sfr 0xDB8, PWM3OFH
            .sfr 0xDB9, PWM3TMRL
            .sfr 0xDBA, PWM3TMRH
            .sfr 0xDBB, PWM3CON
            .sfr 0xDBC, PWM3INTE
            .sfr 0xDBD, PWM3INTF
            .sfr 0xDBE, PWM3CLKCON
            .sfr 0xDBF, PWM3LDCON
            .sfr 0xDC0, PWM3OFCON

            .sfr 0xFE4, STATUS_SHAD
            .sfr 0xFE5, WREG_SHAD
            .sfr 0xFE6, BSR_SHAD
            .sfr 0xFE7, PCLATH_SHAD
            .sfr 0xFE8, FSR0L_SHAD
            .sfr 0xFE9, FSR0H_SHAD
            .sfr 0xFEA, FSR1L_SHAD
            .sfr 0xFEB, FSR1H_SHAD
            .sfr 0xFED, STKPTR
            .sfr 0xFEE, TOSL
            .sfr 0xFEF, TOSH


            ;;;
            ;;; various declarations
            ;;;


            .reg 0, delay0
            .reg 0, counter


            ; CLKOUTEN = off, BOREN = on, CP = off, PWRTE = off, WDTE = off
            .cfg 0x8007, 0n11_1111_1110_0100
            ; LVP = on, DEBUG = off, LPBOREN = off, BORV = low, STVREN = on,
            ; PLLEN = off, WRT = off
            .cfg 0x8008, 0n11_1110_1111_1111


            ;;;
            ;;; interrupt vectors
            ;;;


reset:      goto start
a0002:      nop
a0003:      nop

int:        nop


            ;;;
            ;;; main program
            ;;;


start:
            ;;; Set up clock. ;;;

            ; SPLLEN = off, IRCF = 4 MHz HF
            movlw 0n01101000
            movwf OSCCON

            ;;; Set up ports. ;;;

            ;      (RA0): in (analog)
            ;      (RA1): in (analog)
            ;      (RA2): in (analog)
            ;      (RA3): in (analog)
            ;   TX (RA4): out 0
            ;   RX (RA5): in (analog)
            clrf LATA
            movlw 0n00101111
            movwf TRISA
            movlw 0n11101111
            movwf ANSELA
            movlw 0n10000100
            movwf APFCON

            ;;; Set up EUSART. ;;;

            ; symbol rate = 2400 baud
            movlw 25
            movwf SPBRGL

            ; BRG16 = 8-bit, WUE = off, ABDEN = off
            movlw 0n01000000
            movwf BAUDCON

            ; TX9 = 8-bit, TXEN = on, SYNC = async, BRGH = low speed
            movlw 0n00100010
            movwf TXSTA

            ; SPEN = off, RX9 = 8-bit, CREN = off
            movlw 0n00000000
            movwf RCSTA

            ;;; Wait for oscillator to stabilize. ;;;

            movlb OSCSTAT
_s1:        btfss OSCSTAT, 0 ; HFIOFS
              *bra _s1

            ;;; Enable EUSART. ;;;

            bsf RCSTA, 7 ; SPEN = on

            ;;; Spew on EUSART. ;;;

            clrf counter
spew:       movf counter, 0
            movwf TXREG
            incf counter
            movlb PIR1
send:       btfss PIR1, 4 ; TXIF
              *bra send
            bcf PIR1, 4 ; TXIF
            movlw 200
            call delay500u7
            bra spew



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
