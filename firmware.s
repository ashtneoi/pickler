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

            .sfr 0x120, req_bmRequestType
            .sfr 0x121, req_bRequest
            .sfr 0x122, req_wValue0
            .sfr 0x123, req_wValue1
            .sfr 0x124, req_wIndex0
            .sfr 0x125, req_wIndex1
            .sfr 0x126, req_wLength0
            .sfr 0x127, req_wLength1

            ; 0 = powered
            ; 1 = default
            ; 2 = address
            ; 3 = configured
            .reg 6, usbstate

            ; 0 = waiting
            ; 2 = read
            ; 3 = write
            .reg 6, ep0state

            .reg 6, ep0len

            .reg 6, copylen


            ;;;
            ;;; interrupt vectors
            ;;;


reset:      goto start
a0002:      nop
a0003:      nop

int:        btfss PIR2, 2 ; USBIF
              retfie
            btfsc UIR, 0 ; URSTIF
              *bra intreset
            btfsc UIR, 3 ; TRNIF
              *bra inttrans
            retfie


intreset:   ; Clear all USB interrupt flags.
            clrf UIR
            bcf PIR2, 2 ; USBIF

            ; Reinitialize call stack.
            movlw 0x1F
            movwf STKPTR

            ; Do other initialization.
            call init

            ; Start.
            call ctrlwait ; (Kind of hacky.)
            goto freeze


inttrans:   ; Clear interrupt flags.
            bcf UIR, 3 ; TRNIF
            bcf PIR2, 2 ; USBIF

            ; If transaction is SETUP...
            btfsc UCON, 4 ; PKTDIS
              *bra ctrlsetup

            ; If in read or write mode...
            btfsc ep0state, 1
              *bra ctrl

            retfie ; Is this to spec?


stall:      bra freeze ; Implement me!


ctrl:       ; If transaction is IN...
            btfsc USTAT, 2 ; DIR
              *bra ctrlin

ctrlout:    ; If in write mode...
            btfsc ep0state, 0
              *bra ctrlwait

            ; ep0len -= BD0CNT
            movf BD0CNT, 0
            subwf ep0len
            btfsc STATUS, 2 ; Z
              *bra ctrlinst

            ; BD0ADR[H:L] += BD0CNT
            movf BD0CNT, 0
            addwf BD0ADRL
            movlw 0
            addwfc BD0ADRH

            ; Set up BD0STAT.
            movlw 0n01001000
            andwf BD0STAT
            movlw 0n01000000 ; DTS mask
            xorwf BD0STAT

_ctrlout:   ; BD0CNT = min(ep0len, 64)
            movf ep0len, 0
            andlw 0n11000000
            btfss STATUS, 2 ; Z
              movlw 64
            movwf BD0CNT

            ; Arm OUT 0.
            bsf BD0STAT, 7 ; UOWN
            retfie


ctrloutst:  bsf BD0STAT, 6 ; DTS = 1
            bra _ctrlout


ctrlin:     ; If in read mode...
            btfss ep0state, 0
              *bra ctrlwait

            ; ep0len -= BD1CNT
            movf BD1CNT, 0
            subwf ep0len
            btfsc STATUS, 2 ; Z
              *bra ctrloutst

            ; BD1ADR[H:L] += BD1CNT
            movf BD1CNT, 0
            addwf BD1ADRL
            movlw 0
            addwfc BD1ADRH

            ; Set up BD1STAT.
            movlw 0n01001000
            andwf BD1STAT
            movlw 0n01000000 ; DTS mask
            xorwf BD1STAT

_ctrlin:    ; BD1CNT = min(ep0len, 64)
            movf ep0len, 0
            andlw 0n11000000
            btfss STATUS, 2 ; Z
              movlw 64
            movwf BD1CNT

            ; Arm IN 0.
            bsf BD1STAT, 7 ; UOWN
            retfie


ctrlinst:   bsf BD1STAT, 6 ; DTS = 1
            bra _ctrlin


ctrlsetup:  btfsc req_bmRequestType, 6 ; vendor or reserved
              *bra stall
            btfsc req_bmRequestType, 5 ; class
              *bra stall

            bsf LATC, 2

            movf req_bRequest, 0
            ; 0 = GET_STATUS
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 1 = CLEAR_FEATURE
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 2 = reserved
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 3 = SET_ADDRESS
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 4 = reserved
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 5 = SET_ADDRESS
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 6 = GET_DESCRIPTOR
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 7 = SET_DESCRIPTOR
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 8 = GET_CONFIGURATION
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 9 = SET_CONFIGURATION
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 10 = GET_INTERFACE
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 11 = SET_INTERFACE
            btfsc STATUS, 2 ; Z
              *bra stall
            decf WREG
            ; 12 = SYNCH_FRAME
            btfsc STATUS, 2 ; Z
              *bra stall
            bra stall


ctrlwait:   ; ep0state = waiting
            clrf ep0state

            ; Set up OUT 0.
            movlw 0n00001000 ; DTSEN = on
            movwf BD0STAT
            movlw 0x20
            movwf BD0ADRH
            movlw 0xA0
            movwf BD0ADRL
            movlw 64
            movwf BD0CNT
            bsf BD0STAT, 7 ; UOWN = SIE

            retfie


init:       clrf ep0state ; waiting
            return


            ;;;
            ;;; Initialize.
            ;;;


start:      ;;; Set up clock. ;;;

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
_hfwait:    *btfss OSCSTAT, 0 ; HFIOFS
              *bra _hfwait ; (Interrupts are disabled.)

            movlb OSCSTAT
_pllwait:   *btfss OSCSTAT, 6 ; PLLRDY
              *bra _pllwait ; (Interrupts are disabled.)

            ;;; Set up USB module. ;;;

            clrf usbstate ; powered
            call init

            ; UPUEN = on, FSEN = on
            movlw 0n00010100
            movwf UCFG

            ; EPHSHK = on, EPOUTEN = on, EPINEN = on
            movlw 0n00010110
            movwf UEP0

            clrf BD0STAT
            clrf BD1STAT
            clrf BD2STAT
            clrf BD3STAT
            clrf BD4STAT
            clrf BD5STAT
            clrf BD6STAT
            clrf BD7STAT

            ; TRNIE = on, URSTIE = on
            movlw 0n00001001
            movwf UIE

            bsf PIE2, 2 ; USBIE = on
            bsf INTCON, 6 ; PEIE = on

            bsf INTCON, 7 ; GIE = on

            goto freeze


            ;;;
            ;;; utilities
            ;;;


copy:       movwf copylen
            movlp _copy
_copy:      moviw FSR0++
            movwi FSR1++
            *decfsz copylen
              *goto _copy
            return


freeze:     goto freeze


            ;;;
            ;;; data
            ;;;


device_descriptor:
            movlw 18 ; bLength
            movlw 1 ; bDescriptorType = DEVICE
            movlw 0x00 ; bcdUSB = 0x0200
            movlw 0x02 ; same
            movlw 0xFF ; bDeviceClass = vendor-specific
            movlw 0x00 ; bDeviceSubClass
            movlw 0xFF ; bDeviceProtocol = vendor-specific
            movlw 64 ; bMaxPacketSize0
            movlw 0xD8 ; idVendor
            movlw 0x04 ; same
            movlw 0x00 ; idProduct
            movlw 0x40 ; same
            movlw 0x01 ; bcdDevice
            movlw 0x00 ; same
            movlw 0x00 ; iManufacturer
            movlw 0x00 ; iProduct
            movlw 0x00 ; iSerialNumber
            movlw 0x01 ; bNumConfigurations


config0_descriptor:
            movlw 9 ; bLength
            movlw 2 ; bDescriptorType = CONFIGURATION
            movlw 9 ; wTotalLength = 9
            movlw 0 ; same
            movlw 0 ; bNumInterfaces
            movlw 0 ; bConfigurationValue
            movlw 0 ; iConfiguration
            movlw 0n10000000 ; bmAttributes
            movlw 20 ; bMaxPower = 20 * 2 mA
