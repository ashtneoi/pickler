            .gpr 0x020, 0x32F
            .sfr 0x00C, PORTA
            .sfr 0x00E, PORTC
            .sfr 0x08C, TRISA
            .sfr 0x08E, TRISC
            .sfr 0x10C, LATA
            .sfr 0x10E, LATC
            .sfr 0x18C, ANSELA
            .sfr 0x18E, ANSELC
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

reset:      goto start
a0002:      nop
a0003:      nop
int:        btfss IOCCF, 3
             retfie
            bcf IOCCF, 3
            bcf INTCON, 0 ; IOCIF
            btfsc PORTC, 3
             bsf LATC, 2
            btfss PORTC, 3
             bcf LATC, 2
            retfie

start:      movlw 0n00000100
            movwf LATC
            movlw 0n00111111 ; RA dir = in
            movwf TRISA
            movlw 0n00111011 ; RC dir = in, RC2 dir = out
            movwf TRISC
            bsf IOCCP, 3
            bsf IOCCN, 3
            movlw 0n10001000 ; GIE, IOCIE
            iorwf INTCON
idle:       sleep
            goto idle
