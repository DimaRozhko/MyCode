.386
Node		struc
 namex 		db		'parne'
 field1		dw		?
Node		ENDS

data1        SEGMENT	USE16
 I1			db       ?
 I2			db       ?
 A1			Node 	 6 dup(4 dup(<>))
 LINK		dd		 begin2
data1        ENDS

data2       SEGMENT	USE16 
 A2			dw		24 dup (?)
data2       ENDS


code1       SEGMENT	USE16
            ASSUME   cs:code1,ds:data1
begin:
            mov     ax,data1        
            mov     ds,ax
			
			mov		di,offset A1
			mov		cx,di
			mov		bx,size Node
			mov		dx,0
			mov		I1,0
			LN1:
			cmp		I1,6
			jge		LN2

			mov		I2,0	
			LN4:
			cmp		I2,4
			jge		LN3
			
			test	di,1
			jz		odd
			jnz		eve
			
			odd:

			mov		si,di
			mov		al,'n'
			mov		[si],al
			add		si,1
			mov		al,'e'
			mov		[si],al
			add		si,1
			mov		al,'p'
			mov		[si],al
			add		si,1
			mov		al,'a'
			mov		[si],al
			add		si,1
			mov		al,'r'
			mov		[si],al

			jmp		eodd
			eve:
			mov		si,di
			mov		al,'p'
			mov		[si],al
			add		si,1
			mov		al,'a'
			mov		[si],al
			add		si,1
			mov		al,'r'
			mov		[si],al
			add		si,1
			mov		al,'n'
			mov		[si],al
			add		si,1
			mov		al,'e'
			mov		[si],al
			eodd:

			mov		si,dx
			add		di,bx
			mov		WORD PTR A1[si].field1,di
			add		dx,bx
			
			
			cont:
			inc		I2
			jmp		LN4
			LN3:
			inc		I1
			jmp		LN1
			LN2:
			
			mov		di,cx
			mov		WORD PTR A1[si].field1,di

			jmp	LINK		
code1        ENDS
			

code2		SEGMENT	USE16
            ASSUME   ds:data1, es:data2, cs:code2 
begin2:
			mov 	ax, data2
			mov 	es, ax
			mov		si,offset A1
			mov		di,offset A2
			mov		ax,0

			LN6:
			cmp		bx,24
			jge		LN5

			add		si,5
			lodsw
			test	si,1
			jnz		LN7
			stosw
			LN7:
			add		bx,1
			jmp		LN6
			LN5:
			
			nop
			mov     ax,4c00h
            int     21h
code2		ENDS
			end		begin