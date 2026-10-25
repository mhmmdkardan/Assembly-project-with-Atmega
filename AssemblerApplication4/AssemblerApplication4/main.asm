        .Include "M64DEF.INC"
        
		.ORG    0X0000
        JMP     main
		.ORG	0x0002
		JMP		INT0_ISR
		.ORG	0x0004
		JMP		INT1_ISR
		.ORG	0x0006
		JMP		INT2_ISR
		.ORG	0x0008
		JMP		INT3_ISR    
        .ORG    0x0020
        JMP     Timer0_ISR
        .ORG    0x0050



main:   LDI     R20,low(RAMEND)
        OUT     SPL,R20
        LDI     R20,high(RAMEND)
        OUT     SPH,R20                 ;SP = 0x10FF
		LDI     R20,0x0AA
        STS     EICRA,R20               ;FALLING EDGE INT1 AND INT2 AND INT3
        LDI     R20,8
        OUT     EIMSK,R20               ;INT3   ACCEPTED
		LDI     R20,1
        OUT     TIMSK , R20
        LDI     R20,0x06                
        OUT     TCCR0,R20               
        LDI     R20,56
        OUT     TCNT0, R20              ; timer pulse is 50ms and Fcpu is 1.024Mhz
		LDI     R20,0x0FF
        OUT     DDRA,R20
		OUT     DDRC,R20
		OUT     DDRB,R20
		OUT     DDRE,R20
		SBI		DDRD,4
		SBI		DDRD,5					;BOB LED
		CLR     R20 
		
		LDI		R28,5
		LDI		R27,50
        SEI


loop:   
		CPI		R31,1
		BREQ	start
		CPI		R18,10
		BRLO	loop
		CLR		R18
		LDI		R23,0x80
		IN		R24,PORTC
		EOR		R24,R23
		OUT		PORTC,R24
		JMP		loop

INT3_ISR:	LDI		R31,1
			RETI

		;R16,17,20 FOR NUMBER 
		;    R31 FOR COUNTER	R29,R28SABET IS LEGHNT     R18,21 FOR TIMER	R20 FOR SHITS	R23,R24 FOR YELLOW LED R30 IS THE ANSWEAR	R25,26,27 IS SCORE

start:		CBI		PORTC,7
			CLR		R29
			ADD		R29,R28
			LDI		R20,0
		    OUT		EIMSK,R20			;INT3  NOT ACCEPTED
            IN		R16,TCNT0
			EOR		R16,R15
			MOV		R17,R16
			LDI		R22,1
loop1:		LSL		R22
			INC		R22
			DEC		R29
			BRNE	loop1
			LSR		R22
			AND		R17,R22				;R17 IS THE RANDOM NUMBER
			SBRC	R16,7
			JMP		BOB
		    JMP		ALICE

BOB:		 CLR		R31
			 OUT	PORTA,R17
			 SBI	PORTD,5
			 CLR	R18
			 CLR	R21
			 
			 
waiterBOB:	 
			 CPI	R18,100
			 BREQ	NEXTBOB
			 CPI	R21,5
			 BRNE	waiterBOB
			 CLR	R21
			 LDI	R23,0x04
			 IN		R24,PORTC
			 EOR	R24,R23
			 OUT	PORTC,R24
			 JMP	waiterBOB




NEXTBOB:	CLR		R18
			OUT		PORTA,R18
			SBI		PORTC,2
WAITER2:	CPI		R18,20
			BRNE	WAITER2
			CBI		PORTC,2
			CLR		R18
			LDI		R20,7
			OUT		EIMSK,R20	;INT 0,1,2 IS ACCEPTED
			CBI		PORTC,2
			CLR		R31
			CLR		R30
BOBTURN:	CBI		PORTC,2	
			CPI		R18,200
			BRSH	BOBN
			CP		R31,R28
			BRNE	BACKER
			CALL	CHECK
BACKER:		JMP		BOBTURN
			
BOBN:		LDI		R20,0
			OUT		EIMSK,R20	
			CBI		PORTD,5				
		    SBRS	R16,7
			JMP	ROUNDend
			JMP	ALICE




ALICE:		 CLR		R31
			 OUT	PORTA,R17
			 SBI	PORTD,4
			 CLR	R18
			 CLR	R21

waiterALICE: CPI	R18,100
			 BREQ	NEXTALICE
			 
			 CPI	R21,5
			 BRNE	waiterALICE
			 CLR	R21
			 LDI	R23,0x04
			 IN		R24,PORTC
			 EOR	R24,R23
			 OUT	PORTC,R24
			 JMP	waiterALICE

NEXTALICE:	 CLR		R18
			 OUT		PORTA,R18
			 SBI		PORTC,2
WAITER3:	CPI		R18,20
			BRNE	WAITER3
			CBI		PORTC,2
			CLR		R18
			LDI		R20,7
			OUT		EIMSK,R20				;INT 0,1,2 IS ACCEPTED
			CBI		PORTC,2
			CLR		R31
			CLR		R18
			CLR		R30
ALICETURN:	CBI		PORTC,2	
			CPI		R18,200
			BRSH	ALICEN
			CP		R31,R28
			BRNE	BACKER1
			CALL	CHECK
BACKER1:		JMP		ALICETURN
			
ALICEN:		LDI		R20,0
			OUT		EIMSK,R20	
			 CBI	PORTD,4
			 SBRC	R16,7
			 JMP	ROUNDend
			 JMP	BOB

CHECK:	CBI		PORTC,2	
        LDI     R20, 0
        OUT     EIMSK, R20      
        CP      R17, R30     
		LDI		R22,8 
        BREQ    IS_RIGHT
        RJMP    IS_WRONG
IS_RIGHT:	SBIC    PORTD, 5
			INC     R25
			SBIC    PORTD, 4
			INC     R26
			LDI     R23, 0x10
			RJMP	BLINKER_LOOP1
					

IS_WRONG:		LDI     R23, 0x20

BLINKER_LOOP1:		IN      R24, PORTC      
					EOR     R24, R23       
					OUT     PORTC, R24      
        
					RCALL   DELAY_100       
        
					DEC     R22            
					BRNE    BLINKER_LOOP1     

					CBI     PORTC, 2
					CBI     PORTC, 4
					CBI     PORTC, 5
        
        RJMP    CHECKEND


DELAY_100:
        PUSH    R23
        PUSH    R24
        
        LDI     R23, 200        
Loop11:  LDI     R24, 127
Loop22:  NOP
        DEC     R24
        BRNE    Loop22
        DEC     R23
        BRNE    Loop11
        
        POP     R24
        POP     R23
        RET
CHECKEND:	LDI		R20,7
			OUT		EIMSK,R20	
			CLR     R30
			CLR     R31
			RET


ROUNDend:	OUT		PORTB,R25
			OUT		PORTE,R26
			LDI		R16,5
			INC		R28
			CP		R25,R26
			BREQ	DRAW
			BRMI	AWIN
			JMP		BWIN

DRAW:
		CLR		R18
		SBI		PORTD,5
		SBI		PORTD,4
DDD:	CPI		R18,16
		BRLO	DDD
		CBI		PORTD,5
		CBI		PORTD,4
DDDD:	CPI		R18,20
		BRLO	DDDD
		DEC		R16
		BREQ	ER
		JMP		DRAW
ER:	
			CLR		R25
			CLR		R26
			OUT		PORTB,R25
			OUT		PORTE,R26
			JMP		ENDD
AWIN:	
		CLR		R18
		SBI		PORTD,4
AAA:	CPI		R18,16
		BRLO	AAA
		CBI		PORTD,4
AAAA:	CPI		R18,20
		BRLO	AAAA
		DEC		R16
		BREQ	ALENDER
		JMP		AWIN
ALENDER:	DEC		R27
			CLR		R25
			CLR		R26
			OUT		PORTB,R25
			OUT		PORTE,R26
			JMP		ENDD
BWIN:
		CLR		R18
		SBI		PORTD,5
BBB:	CPI		R18,16
		BRLO	BBB
		CBI		PORTD,5
BBBB:	CPI		R18,20
		BRLO	BBBB
		DEC		R16
		BREQ	BOBENDER
		JMP		BWIN
BOBENDER:	INC		R27
			CLR		R25
			CLR		R26
			OUT		PORTB,R25
			OUT		PORTE,R26
			JMP		ENDD

ENDD:		

			CPI		R28,8
			BREQ	FINISH
			JMP		start



INT0_ISR:		PUSH    R20         
				IN      R20, SREG
				PUSH    R20
				LSL		R30
				INC		R31
				INC		R15
				POP		R20
				OUT		SREG,R20
				POP		R20
				RETI

INT1_ISR:		PUSH    R20         
				IN      R20, SREG
				PUSH    R20
				LSL		R30
				INC		R30
				INC		R31
				INC		R15
				POP		R20
				OUT		SREG,R20
				POP		R20
				RETI

INT2_ISR:		PUSH    R20         
				IN      R20, SREG
				PUSH    R20
				CLR		R30
				CLR		R31
				POP		R20
				OUT		SREG,R20
				POP		R20
				RETI
		


Timer0_ISR:		PUSH	R20
				IN		R20,SREG
				PUSH	R20
				LDI     R20,56
				OUT     TCNT0, R20
				INC		R18
				INC		R21
				POP		R20
				OUT		SREG,R20
				POP		R20
				RETI
				

FINISH:		CPI		R27,50
			BREQ	MOSAVI
			BRSH	BOB_BORD
			SBI		PORTD,4
			JMP		TAMAM
MOSAVI:		SBI		PORTD,5
			SBI		PORTD,4
			JMP		TAMAM
BOB_BORD:	SBI		PORTD,5
			

TAMAM:		JMP		TAMAM