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

            ; ICSP temp bit
            .reg 0, icspbit

            ; delay counters
            .reg 2, delay0
            .reg 2, delay1
            .reg 2, delay1_def

            ; command decoding registers
            .reg 3, buf
            .reg 3, cmd
            .reg 3, datalen
            .reg 3, data0
            .reg 3, data1

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
            ; Return if error.
            btfsc RC1STA, 2 ; FERR
             retfie

            ; Copy received byte to buf.
            movf RC1REG, 0
            movwf buf

            ; If cmd[7], set data.
            btfsc cmd, 7
             *bra set_data

            ; If buf is '_', reset programmer.
            movf buf, 0
            sublw 0x5F
            btfsc STATUS, 2 ; Z
             reset

            ; If cmd is nonzero, return.
            movf cmd ; test cmd
            btfss STATUS, 2 ; Z
             retfie

            ; Set cmd.
            movf buf, 0
            movwf cmd
            ; If cmd is 'L', set high bit.
            sublw 0x4C ; 'L'
            btfsc STATUS, 2 ; Z
             *bsf cmd, 7

            clrf datalen
            retfie

set_data:   ; If datalen is 2, return.
            btfsc datalen, 1
             retfie

            ; Increment datalen.
            incf datalen

            ; If datalen is now 2, set data1.
            btfsc datalen, 1
             *bra set_data1
            ; Else set data0.
            movf buf, 0
            movwf data0
            retfie
set_data1:  ; Set data1.
            movf buf, 0
            movwf data1
            bcf cmd, 7 ; cmd is ready
            retfie

            ;;;
            ;;; main program
            ;;;


start:
            ;;; Set up clock. ;;;

            ; SPLLEN = off, IRCF = 1 MHz HF
            movlw 0n01011000
            movwf OSCCON

            ;;; Set up ports. ;;;

            ;   ~MCLR (RC0): out 1
            ; ICSPCLK (RC1): in (digital)
            ; ICSPDAT (RC2): in (digital)
            ;  USBCFG (RC3): in (digital)
            ;      TX (RC4): out X
            ;      RX (RC5): in (digital)
            movlw 0n00000001
            movwf LATC
            movlw 0n11101110
            movwf TRISC
            movlw 0n11000000
            movwf ANSELC

            ; RC5 in = RX
            movlw 0n00010101 ; RC5
            movwf RXPPS

            ; RC4 out = TX
            movlw 0n00010100 ; TX/CK
            movwf RC4PPS

            ;;; Determine reset cause. ;;;

            ; stack overflow
            btfsc PCON, 7 ; STKOVF
             movlw 0x6F ; 'o'
            btfsc PCON, 7
             *bra cause_done

            ; stack underflow
            btfsc PCON, 6 ; STKUNF
             movlw 0x75 ; 'u'
            btfsc PCON, 6
             *bra cause_done

            ; watchdog timer timeout
            btfss PCON, 4 ; ~RWDT
             movlw 0x77 ; 'w'
            btfss PCON, 4
             *bra cause_done

            ; MCLR reset
            btfss PCON, 3 ; ~RMCLR
             movlw 0x6D ; 'm'
            btfss PCON, 3 ; ~RMCLR
             *bra cause_done

            ; reset instruction
            btfss PCON, 2 ; ~RI
             movlw 0x72 ; 'r'
            btfss PCON, 2 ; ~RI
             *bra cause_done

            ; power-on reset
            btfss PCON, 1 ; ~POR
             movlw 0x70 ; 'p'
            btfss PCON, 1 ; ~POR
             *bra cause_done

            ; brownout reset
            btfss PCON, 0 ; ~BOR
             movlw 0x62 ; 'b'
            btfss PCON, 0 ; ~BOR
             *bra cause_done

            ; unknown
            movlw 0x7E ; '~'

cause_done: movwf resetcause

            movlw 0n00011111
            movwf PCON

            ;;; Set up programmer. ;;;

            clrf cmd

            clrf datalen

            movlw 0x01 ; fast
            movwf delay1_def

            ;;; Set up EUSART. ;;;

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
            call uart_send
            movlw 0x5F ; '_'
            call uart_send
            movlw 0x5F ; '_'
            call uart_send
            movf resetcause, 0
            call uart_send

            bra handle_cmd


            ;;;
            ;;;
            ;;;


do_slow:
            movlw 0x10
            movwf delay1_def

            movlw 1
            bra cmd_done

do_fast:
            movlw 0x01
            movwf delay1_def

            movlw 1
            bra cmd_done


            ;;;
            ;;;
            ;;;


            ; '_': reset programmer
            ; '[': slow
            ; ']': fast
            ; 'N': eNter LVP
            ; 'X': eXit lVP
            ; 'C': load Configuration
            ; 'L': Load data for program memory
            ; 'D': reaD data from program memory
            ; 'I': Increment address
            ; 'A': reset Address
            ; 'P': begin internally timed Programming
            ; 'E': begin Externally timed programming
            ; 'F': end externally timed programming
            ; 'B': Bulk erase program memory
            ; 'R': Row erase program memory

handle_cmd:
            ; If cmd is 0 or the high bit is set, do nothing.
            movf cmd
            btfsc STATUS, 2 ; Z
             *bra handle_cmd
            btfsc cmd, 7
             *bra handle_cmd

            ; If cmd is '['...
            movf cmd, 0
            sublw 0x5B
            btfsc STATUS, 2 ; Z
             *bra do_slow

            ; If cmd is ']'...
            movf cmd, 0
            sublw 0x5D
            btfsc STATUS, 2 ; Z
             *bra do_fast

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
            call uart_send
            bra next_cmd

cmd_done:
            movf WREG
            movlb cmd
            btfsc STATUS, 2 ; Z
             movlw 0x2E ; '.'
            btfss STATUS, 2 ; Z
             *movf cmd, 0
            call uart_send

next_cmd:
            clrf cmd
            bra handle_cmd


            ;;;
            ;;; 'N': eNter LVP
            ;;;


do_N:
            ; ~MCLR = 1
            bsf LATC, 0

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; ~MCLR = 0
            bcf LATC, 0

            ; CLK = out 0
            bcf LATC, 1
            bcf TRISC, 1

            ; DAT = out
            bcf TRISC, 2

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 0x50 ; 'P'
            movwf icsp0
            movlw 0x48 ; 'H'
            movwf icsp1
            movlw 16
            call icsp_send

            movlw 0x43 ; 'C'
            movwf icsp0
            movlw 0x4D ; 'M'
            movwf icsp1
            movlw 16
            call icsp_send

            ; icsp0[0] is 0 now.
            movlw 1
            call icsp_send

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'X': eXit LVP
            ;;;


do_X:       ; CLK = in (digital)
            bsf TRISC, 1

            ; DAT = in (digital)
            bsf TRISC, 2

            ; ~MCLR = 1
            bsf LATC, 0

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'C': load Configuration
            ;;;


do_C:       clrf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            call icsp_sendw ; Data doesn't matter.

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'L': Load data for program memory
            ;;;


do_L:       movlw 0n000010
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movf data1, 0
            movwf icsp1
            movf data0, 0
            movwf icsp0
            call icsp_sendw

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'D': reaD data for program memory
            ;;;


do_D:       movlw 0n000100
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            call icsp_recvw

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movf icsp0, 0
            call uart_send

            movf icsp1, 0
            call uart_send

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'I': Increment address
            ;;;


do_I:       movlw 0n000110
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'A': reset Address
            ;;;


do_A:       movlw 0n010110
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'P': begin internally timed Programming
            ;;;


do_P:       movlw 0n001000
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'E': begin Externally timed programming
            ;;;


do_E:       movlw 0n011000
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'F': end externally timed programming
            ;;;


do_F:       movlw 0n001010
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'B': Bulk erase program memory
            ;;;


do_B:       movlw 0n001001
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;; 'R': Row erase program memory
            ;;;


do_R:       movlw 0n010001
            movwf icsp0
            movlw 6
            call icsp_send

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            movlw 1
            bra cmd_done


            ;;;
            ;;;
            ;;;


delay:      movlw 1
            subwf delay0
            movlw 0
            subwfb delay1
            movf delay0
            btfsc STATUS, 2 ; Z
             *movf delay1
            btfss STATUS, 2 ; Z
             *bra delay
            return


            ;;;
            ;;;
            ;;;


uart_send:  btfss PIR1, 4 ; TXIF
             *bra uart_send
            nop ; See erratum 4.1. Probably not needed, though.
            movwf TX1REG
            return


            ;;;
            ;;;
            ;;;


icsp_send:
            movwf icspcount

_is_loop:
            ; Shift next bit into C.
            lsrf icsp1
            rrf icsp0

            ; DAT = C
            movlb LATC
            btfss STATUS, 0 ; C
             *bcf LATC, 2 ; DAT
            btfsc STATUS, 0 ; C
             *bsf LATC, 2 ; DAT

            ; CLK = 1
            bsf LATC, 1 ; CLK

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; CLK = 0
            bcf LATC, 1 ; CLK

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; Loop if --icspcount != 0.
            decf icspcount
            btfss STATUS, 2 ; Z
             *bra _is_loop

            return


            ;;;
            ;;;
            ;;;


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

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; CLK = 0
            bcf LATC, 1 ; CLK

            movf delay1_def, 0
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


            ;;;
            ;;;
            ;;;


icsp_recvw:
            movlw 16
            movwf icspcount

            bsf TRISC, 2 ; DAT

            bcf icspbit, 0

_irw_loop:
            ; Shift next bit from icspbit into buffer.
            lsrf icspbit
            rrf icsp1
            rrf icsp0

            ; CLK = 1
            bsf LATC, 1 ; CLK

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; CLK = 0
            bcf LATC, 1 ; CLK

            btfss PORTC, 2 ; DAT
             *bcf icspbit, 0
            btfsc PORTC, 2 ; DAT
             *bsf icspbit, 0

            movf delay1_def, 0
            movwf delay1
            movlw 0xFF
            movwf delay0
            call delay

            ; Loop if --icspcount != 0.
            decf icspcount
            btfss STATUS, 2 ; Z
             *bra _irw_loop

            bcf TRISC, 2 ; DAT

            bcf STATUS, 0 ; C
            rrf icsp1
            rrf icsp0
            bcf STATUS, 0 ; C
            rrf icsp1
            rrf icsp0

            return
