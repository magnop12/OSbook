; harobote-os
; TAB=4
        ORG     0xC200

		MOV		SI,msg
putloop:
		MOV		AL,[SI]			; AL = msg[DS:SI]
		ADD		SI,1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; one character display function code
		MOV		BX,15			; color code
		INT		0x10			; BIOS function call
		JMP		putloop
fin:
		HLT						; halt
		JMP		fin

msg:
		DB		0x0a, 0x0a 
		DB		"[*] write string from haribote.nas", 0x0a
		DB		0
