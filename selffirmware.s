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
            ;;; various declarations
            ;;;


            ; RC0 = ~MCLR
            ; RC1 = ICSPCLK
            ; RC2 = ICSPDAT

            .reg 0, resetcause

            ; delay counters
            .reg 2, delay0
            .reg 2, delay1

            ; command decoding registers
            .reg 3, buf
            .reg 3, cmd
            .reg 3, datalen
            .reg 3, dataL
            .reg 3, dataH

            ; ICSP buffer
            .reg 3, icsp0
            .reg 3, icsp1

            ; ICSP word bit counter
            .reg 3, icspcount

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

int:
            btfss PIR1, 5 ; RCIF
             retfie ; Not sure how we could get here.

            ; Return if error; copy received byte to buf.
            btfsc RC1STA, 2 ; FERR
             retfie
            movf RC1REG, 0
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

            ; If datalen is 2, return.
            btfsc datalen, 1
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
            ;;; main program
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

            ;;; Determine reset cause. ;;;

            btfsc PCON, 7 ; STKOVF
             movlw 0x6F ; 'o'
            btfsc PCON, 7 ; STKOVF
             *bra cause_done
            btfsc PCON, 6 ; STKUNF
             movlw 0x75 ; 'u'
            btfsc PCON, 6 ; STKUNF
             *bra cause_done
            btfss PCON, 4 ; ~RWDT
             movlw 0x77 ; 'w'
            btfss PCON, 4 ; ~RWDT
             *bra cause_done
            btfss PCON, 3 ; ~RMCLR
             movlw 0x6D ; 'm'
            btfss PCON, 3 ; ~RMCLR
             *bra cause_done
            btfss PCON, 1 ; ~POR
             movlw 0x70 ; 'p'
            btfss PCON, 1 ; ~POR
             *bra cause_done
            btfss PCON, 0 ; ~BOR
             movlw 0x62 ; 'b'
            btfss PCON, 0 ; ~BOR
             *bra cause_done
            movlw 0x7E

cause_done: movwf resetcause

            ;;; Set up programmer. ;;;

            clrf cmd
            clrf datalen

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
            call uart_send1
            movlw 0x5F ; '_'
            call uart_send1
            movlw 0x5F ; '_'
            call uart_send1
            movf resetcause, 0
            call uart_send1


            ; '_': reset programmer
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
            movf cmd
            btfsc STATUS, 2 ; Z
             *bra handle_cmd

            bcf STATUS, 7 ; GIE

            ; If cmd is '_', reset programmer.
            movf cmd, 0
            sublw 0x5F
            btfsc STATUS, 2 ; Z
             reset

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

            ; If cmd is 'C'...
            movf cmd, 0
            sublw 0x43
            btfsc STATUS, 2 ; Z
             *bra do_C

            ; If cmd is 'L'...
            movf cmd, 0
            sublw 0x4C
            btfsc STATUS, 2 ; Z
             *bra do_L

            ; If cmd is 'D'...
            movf cmd, 0
            sublw 0x44
            btfsc STATUS, 2 ; Z
             *bra do_D

            ; If cmd is 'I'...
            movf cmd, 0
            sublw 0x49
            btfsc STATUS, 2 ; Z
             *bra do_I

            ; If cmd is 'A'...
            movf cmd, 0
            sublw 0x41
            btfsc STATUS, 2 ; Z
             *bra do_A

            ; If cmd is 'P'...
            movf cmd, 0
            sublw 0x50
            btfsc STATUS, 2 ; Z
             *bra do_P

            ; If cmd is 'E'...
            movf cmd, 0
            sublw 0x45
            btfsc STATUS, 2 ; Z
             *bra do_E

            ; If cmd is 'F'...
            movf cmd, 0
            sublw 0x46
            btfsc STATUS, 2 ; Z
             *bra do_F

            ; If cmd is 'B'...
            movf cmd, 0
            sublw 0x42
            btfsc STATUS, 2 ; Z
             *bra do_B

            ; If cmd is 'R'...
            movf cmd, 0
            sublw 0x52
            btfsc STATUS, 2 ; Z
             *bra do_R

            ; Otherwise...
            movlw 0x3F ; '?'
            call uart_send1

cmd_done:
            clrf cmd
            bsf STATUS, 7 ; GIE
            bra handle_cmd


do_N:
            ; MCLR = 1
            bsf LATC, 0

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; MCLR = 0
            bcf LATC, 0

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 0x50 ; 'P'
            movwf icsp0
            call icsp_send1

            movlw 0x48 ; 'H'
            movwf icsp0
            call icsp_send1

            movlw 0x43 ; 'C'
            movwf icsp0
            call icsp_send1

            movlw 0x4D ; 'M'
            movwf icsp0
            call icsp_send1

            movf cmd, 0
            call uart_send1

            bra cmd_done


do_X:       bsf LATC, 0

            movf cmd, 0
            call uart_send1

            bra cmd_done


do_C:       nop

            movlw 0x2E ; '.'
            call uart_send1

            bra cmd_done

do_L:       movf datalen, 0
            sublw 2
            btfss STATUS, 2 ; Z
             *bra handle_cmd

do_D:       nop
do_I:       nop
do_A:       nop
do_P:       nop
do_E:       nop
do_F:       nop
do_B:       nop
do_R:       nop

            movlw 0x2E ; '.'
            call uart_send1

            bra cmd_done


delay:      movlw 1
            subwf delay0
            movlw 0
            subwfb delay1
            movf delay0
            btfsc STATUS, 2 ; Z
             *movf delay1
            btfss STATUS, 2 ; Z
             *bra delay

            bsf LATC, 2 ; DAT (debug)

            return


uart_send1: btfss PIR1, 4 ; TXIF
             *bra uart_send1
            nop ; See erratum 4.1. Probably not needed, though.
            movwf TX1REG
            return


icsp_sendb:
            ; DAT = W[0]
            movlb LATC
            btfss WREG, 0
             *bcf LATC, 2 ; DAT
            btfsc WREG, 0
             *bsf LATC, 2 ; DAT

            ; CLK = 1
            bsf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; CLK = 0
            bcf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            return


icsp_send1:
            movlw 8
            movwf icspcount

_is1_loop:
            ; Shift next bit into C.
            lsrf icsp0

            ;; DAT = C
            ;movlb LATC
            ;btfss STATUS, 0 ; C
             ;*bcf LATC, 2 ; DAT
            ;btfsc STATUS, 0 ; C
             ;*bsf LATC, 2 ; DAT

            ; CLK = 1
            bsf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            bcf LATC, 2 ; DAT (debug)

            ; CLK = 0
            bcf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; Loop if --icspcount != 0.
            decf icspcount
            btfss STATUS, 2 ; Z
             *bra _is1_loop

            return


icsp_sendw:
            movlw 16
            movwf icspcount

            bcf STATUS, 0 ; C (LSb)
            bcf icsp1, 6 ; MSb

_isw_loop:
            ; DAT = C
            movlb LATC
            btfss STATUS, 0 ; C
             *bcf LATC, 2 ; DAT
            btfsc STATUS, 0 ; C
             *bsf LATC, 2 ; DAT

            ; CLK = 1
            bsf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; CLK = 0
            bcf LATC, 1 ; CLK

            ; Delay about 1 s.
            movlw 0x10
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; Shift next bit into C.
            lsrf icsp1
            rrf icsp0

            ; Loop if --icspcount != 0.
            decf icspcount ; (doesn't affect C)
            btfss STATUS, 2 ; Z
             *bra _isw_loop

            return
