            ;;;
            ;;; PIC16(L)F1454 registers
            ;;;


            .sfr 0x00C, PORTA
            .sfr 0x00E, PORTC
            .sfr 0x011, PIR1
            .sfr 0x012, PIR2
            .sfr 0x015, TMR0
            .sfr 0x016, TMR1L
            .sfr 0x017, TMR1H
            .sfr 0x018, T1CON
            .sfr 0x019, T1GCON
            .sfr 0x01A, TMR2
            .sfr 0x01B, PR2
            .sfr 0x01C, T2CON
            .sfr 0x08C, TRISA
            .sfr 0x08E, TRISC
            .sfr 0x091, PIE1
            .sfr 0x092, PIE2
            .sfr 0x095, OPTION_REG
            .sfr 0x096, PCON
            .sfr 0x097, WDTCON
            .sfr 0x098, OSCTUNE
            .sfr 0x099, OSCCON
            .sfr 0x09A, OSCSTAT
            .sfr 0x10C, LATA
            .sfr 0x10E, LATC
            .sfr 0x116, BORCON
            .sfr 0x11D, APFCON
            .sfr 0x18C, ANSELA
            .sfr 0x18E, ANSELC
            .sfr 0x191, PMADRL
            .sfr 0x192, PMADRH
            .sfr 0x193, PMDATL
            .sfr 0x194, PMDATH
            .sfr 0x195, PMCON1
            .sfr 0x196, PMCON2
            .sfr 0x197, VREGCON
            .sfr 0x199, RCREG
            .sfr 0x19A, TXREG
            .sfr 0x19B, SPBRG
            .sfr 0x19C, SPBRGH
            .sfr 0x19D, RCSTA
            .sfr 0x19E, TXSTA
            .sfr 0x19F, BAUDCON
            .sfr 0x20C, WPUA
            .sfr 0x211, SSP1BUF
            .sfr 0x212, SSP1ADD
            .sfr 0x213, SSP1MSK
            .sfr 0x214, SSP1STAT
            .sfr 0x215, SSP1CON1
            .sfr 0x216, SSP1CON2
            .sfr 0x217, SSP1CON3
            .sfr 0x391, IOCAP
            .sfr 0x392, IOCAN
            .sfr 0x393, IOCAF
            .sfr 0x39A, CLKRCON
            .sfr 0x39B, ACTCON
            .sfr 0x611, PWM1DCL
            .sfr 0x612, PWM1DCH
            .sfr 0x613, PWM1CON
            .sfr 0x614, PWM2DCL
            .sfr 0x615, PWM2DCH
            .sfr 0x616, PWM2CON
            .sfr 0xE8E, UCON
            .sfr 0xE8F, USTAT
            .sfr 0xE90, UIR
            .sfr 0xE91, UCFG
            .sfr 0xE92, UIE
            .sfr 0xE93, UEIR
            .sfr 0xE94, UFRMH
            .sfr 0xE95, UFRML
            .sfr 0xE96, UADDR
            .sfr 0xE97, UEIE
            .sfr 0xE98, UEP0
            .sfr 0xE99, UEP1
            .sfr 0xE9A, UEP2
            .sfr 0xE9B, UEP3
            .sfr 0xE9C, UEP4
            .sfr 0xE9D, UEP5
            .sfr 0xE9E, UEP6
            .sfr 0xE9F, UEP7
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
            ;;; PIC16(L)F1454 USB registers (no ping-pong buffers)
            ;;;


            .gpr 0x330, 0x64F

            .sfr 0x020, BD0STAT
            .sfr 0x021, BD0CNT
            .sfr 0x022, BD0ADRL
            .sfr 0x023, BD0ADRH
            .sfr 0x024, BD1STAT
            .sfr 0x025, BD1CNT
            .sfr 0x026, BD1ADRL
            .sfr 0x027, BD1ADRH
            .sfr 0x028, BD2STAT
            .sfr 0x029, BD2CNT
            .sfr 0x02A, BD2ADRL
            .sfr 0x02B, BD2ADRH
            .sfr 0x02C, BD3STAT
            .sfr 0x02D, BD3CNT
            .sfr 0x02E, BD3ADRL
            .sfr 0x02F, BD3ADRH
            .sfr 0x030, BD4STAT
            .sfr 0x031, BD4CNT
            .sfr 0x032, BD4ADRL
            .sfr 0x033, BD4ADRH
            .sfr 0x034, BD5STAT
            .sfr 0x035, BD5CNT
            .sfr 0x036, BD5ADRL
            .sfr 0x037, BD5ADRH
            .sfr 0x038, BD6STAT
            .sfr 0x039, BD6CNT
            .sfr 0x03A, BD6ADRL
            .sfr 0x03B, BD6ADRH
            .sfr 0x03C, BD7STAT
            .sfr 0x03D, BD7CNT
            .sfr 0x03E, BD7ADRL
            .sfr 0x03F, BD7ADRH
            .sfr 0x040, BD8STAT
            .sfr 0x041, BD8CNT
            .sfr 0x042, BD8ADRL
            .sfr 0x043, BD8ADRH
            .sfr 0x044, BD9STAT
            .sfr 0x045, BD9CNT
            .sfr 0x046, BD9ADRL
            .sfr 0x047, BD9ADRH
            .sfr 0x048, BD10STAT
            .sfr 0x049, BD10CNT
            .sfr 0x04A, BD10ADRL
            .sfr 0x04B, BD10ADRH
            .sfr 0x04C, BD11STAT
            .sfr 0x04D, BD11CNT
            .sfr 0x04E, BD11ADRL
            .sfr 0x04F, BD11ADRH
            .sfr 0x050, BD12STAT
            .sfr 0x051, BD12CNT
            .sfr 0x052, BD12ADRL
            .sfr 0x053, BD12ADRH
            .sfr 0x054, BD13STAT
            .sfr 0x055, BD13CNT
            .sfr 0x056, BD13ADRL
            .sfr 0x057, BD13ADRH
            .sfr 0x058, BD14STAT
            .sfr 0x059, BD14CNT
            .sfr 0x05A, BD14ADRL
            .sfr 0x05B, BD14ADRH
            .sfr 0x05C, BD15STAT
            .sfr 0x05D, BD15CNT
            .sfr 0x05E, BD15ADRL
            .sfr 0x05F, BD15ADRH


            ;;;
            ;;; various declarations
            ;;;


            ; FCMEN = off, IESO = off, ~CLKOUTEN = off, BOREN = on, ~CP = off,
            ; ~PWRTE = off, WDTE = off, FOSC = INTOSC
            .cfg 0x8007, 0n00_1111_1110_0100
            ; LVP = on, ~DEBUG = off, ~LPBOR = off, BORV = low, STVREN = on,
            ; PLLEN = on, PLLMULT = 3x, USBLSCLK = 48 MHz / 8, CPUDIV = 1,
            ; WRT = off
            .cfg 0x8008, 0n11_1111_1100_1111

            .sfr 0x100, bmRequestType
            .sfr 0x101, bRequest
            .sfr 0x102, wValue
            .sfr 0x104, wIndex
            .sfr 0x106, wLength


            ;;;
            ;;; interrupt vectors
            ;;;


reset:      ; (state = ?)
            goto start
a0002:      nop
a0003:      nop


            ;;;
            ;;; main program
            ;;;


start:
            ;;; Set up clock. ;;;

            ; SPLLEN = X, SPLLMULT = 3x, IRCF = 16 MHz, SCS = config
            movlw 0n01111100
            movwf OSCCON

            ; ACTEN = on, ACTUD = on, ACTSRC = USB
            movlw 0n10010000
            movwf ACTCON

            ;;; Set up ports. ;;;

            ;      (D+) RA0: X
            ;      (D-) RA1: X
            ;   (~MCLR) RA3: X
            ; (SELFCLK) RA4: out 0
            ; (SELFDAT) RA5: out 0
            ; (ICSPDAT) RC0: in (analog)
            ; (ICSPCLK) RC1: in (analog)
            ;           RC2: out 0
            ;           RC3: out 0
            ;           RC4: out 0
            ;           RC5: in (digital)

            clrf LATA
            clrf LATC

            movlw 0n11001111
            movwf TRISA
            movlw 0n11100011
            movwf TRISC

            movlw 0n11001111
            movwf ANSELA
            movlw 0n11000011
            movwf ANSELC

            ;;; Wait for clock to stabilize. ;;;

            movlb OSCSTAT
hfwait:     *btfss OSCSTAT, 0 ; HFIOFS
              *bra hfwait ; (Interrupts are disabled.)

            movlb OSCSTAT
pllwait:    *btfss OSCSTAT, 6 ; PLLRDY
              *bra pllwait ; (Interrupts are disabled.)

            ;;; Set up USB module. ;;;

            ; UTEYE = off, UPUEN = on, FSEN = full-speed, PPB = off
            movlw 0n00010100
            movwf UCFG

            ; SOFIE = off, STALLIE = off, IDLEIE = on, TRNIE = off,
            ; ACTVIE = off, UERRIE = off, URSTIE = off
            movlw 0n00010000
            movwf UIE

            ;;; Set up endpoint 0. ;;;

            ; EPHSHK = on, EPCONDIS = on, EPOUTEN = off, EPINEN = off,
            ; EPSTALL = off
            movlw 0n00010000
            movwf UEP0

            ;;; Set up BD 0 (EP0 OUT). ;;;

            ; bank 2
            movlw 0x20
            movwf BD0ADRH
            movlw 0xA0
            movwf BD0ADRL

            ;;; Set up BD 1 (EP0 IN). ;;;

            ; bank 3
            movlw 0x20
            movwf BD0ADRH
            movlw 0xF0
            movwf BD0ADRL

            ;;; Set up other endpoints. ;;;

            clrf UEP1
            clrf UEP2
            clrf UEP3
            clrf UEP4
            clrf UEP5
            clrf UEP6
            clrf UEP7

            ;;; Enable USB module. ;;;

            bsf UCON, 3 ; USBEN = on

            ;;; Wait for USB reset. ;;;

            movlb UIR
rstwait:    *btfss UIR, 0 ; URSTIF
              *bra rstwait ; (Interrupts are disabled.)
            bcf UIR, 0 ; URSTIF

            movlb UCON
            movlp se0wait
se0wait:    *btfsc UCON, 5 ; SE0
              *goto se0wait

            ;;; Enable endpoint 0. ;;;

            bsf UEP0, 2 ; EPOUTEN
            bsf UEP0, 1 ; EPINEN

            ;;; Handle setup transfers. ;;;

default:    ; Wait for SETUP token.

            movlw 0x50
            movwf BD0CNT
            movlw 0n00001000
            movwf BD0STAT
            bsf BD0STAT, 7 ; UOWN = SIE

            movlb UCON
            movlp _d_wait
_d_wait:    *btfss UCON, 4 ; PKTDIS
              *goto _d_wait

            movlw 0
            movwf BD1CNT
            movlw 0n01001000
            movwf BD1STAT
            bsf BD1STAT, 7 ; UOWN = SIE
            bcf UCON, 4 ; PKTDIS
            movlp _d_wait2
_d_wait2:   *btfsc BD1STAT, 7 ; UOWN
              *goto _d_wait2

            movlw 0n00000100
            xorwf LATC

            goto default

            ;;;
            ;;; control transfer, setup stage, SETUP transaction
            ;;;


setup:      ; If request is too short, ignore it.
            movf BD0CNT, 0
            sublw 8
            btfss STATUS, 2 ; Z
              return

            ; If request type is Vendor or Reserved, ignore request.
            btfsc bmRequestType, 6 ; Vendor or Reserved
              return

            ;movlp setup_cls
            btfsc bmRequestType, 5 ; Class
              return

            movf bRequest, 0
            sublw 5 ; SET_ADDRESS
            movlp set_address
            btfsc STATUS, 2 ; Z
              *goto set_address

            return


set_address:
            movf wValue, 0
            movwf UADDR
            return