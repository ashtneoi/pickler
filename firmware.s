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

            ; read RA1, write RC2


reset:      goto start
a0002:      nop
a0003:      nop
int:        btfss IOCAF, 1
             retfie
            bcf IOCAF, 1
            movf PORTA, 0
            movlb LATC
            btfsc WREG, 1
             *bsf LATC, 2
            btfss WREG, 1
             *bcf LATC, 2
            retfie

start:      clrf LATC
            movlw 0n00000011
            movwf TRISA
            clrf ANSELA
            movlw 0n00101000
            movwf TRISC
            clrf ANSELC
            bsf IOCAP, 1
            bsf IOCAN, 1
            movlw 0n10001000 ; GIE, IOCIE
            iorwf INTCON
idle:       sleep
            bra idle
