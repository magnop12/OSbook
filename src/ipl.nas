; haribote-ipl
; TAB=4
CYLS	EQU 10
		ORG		0x7c00			; 命令の読み込み位置をアセンブラに通知 0x7c00はBIOS規定の番地
								; 以降の命令は0x7c00を起点としてアセンブルされる
		JMP		entry			; this operation is stored at 0x7c00
		NOP

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述
		DB		"HARIBOTE"		; ブートセクタの名前を自由に書いてよい（8バイト）
		DW		512				; 1セクタの大きさ（512にしなければいけない）
		DB		1				; クラスタの大きさ（1セクタにしなければいけない）
		DW		1				; FATがどこから始まるか（普通は1セクタ目からにする）
		DB		2				; FATの個数（2にしなければいけない）
		DW		224				; ルートディレクトリ領域の大きさ（普通は224エントリにする）
		DW		2880			; このドライブの大きさ（2880セクタにしなければいけない）
		DB		0xf0			; メディアのタイプ（0xf0にしなければいけない）
		DW		9				; FAT領域の長さ（9セクタにしなければいけない）
		DW		18				; 1トラックにいくつのセクタがあるか（18にしなければいけない）
		DW		2				; ヘッドの数（2にしなければいけない）
		DD		0				; パーティションを使ってないのでここは必ず0
		DD		2880			; このドライブ大きさをもう一度書く
		DB		0,0,0x29		; よくわからないけどこの値にしておくといいらしい
		DD		0xffffffff		; たぶんボリュームシリアル番号
		DB		"HARIBOTE-OS"	; ディスクの名前（11バイト）
		DB		"FAT12   "		; フォーマットの名前（8バイト）
		RESB	18				; とりあえず18バイトあけておく

; entry point 0x7c50

entry:
		XOR		AX,AX			; zero clear AX
		MOV		SS,AX
		MOV		SP,0x7c00		; SP = boot sector address
		MOV		DS,AX
		MOV		ES,AX

; read from disk

		MOV		AX, 0x0820		; segment address
		MOV		ES, AX
		MOV		DL, 0			; drive 0
		MOV		CH, 0			; cylinder 0
		MOV		DH, 0			; head 0
		MOV		CL, 2			; sector 2

readloop:
		XOR		SI, SI			; failed conter
retry:
		MOV 	AH, 0x02		; read function
		MOV 	AL, 1			; process 1 sector
		MOV		BX, 0			; read to [ES:BX]
		INT		0x13
		JNC 	next			; ready for next sector
		INC		SI
		CMP		SI, 5			; SI >= 5?
		JAE		error			; then error
		MOV		AH, 0			; reset drive
		INT 	0x13
		JMP		retry			; else retry
next:
		MOV		AX, ES
		ADD		AX, 0x20
		MOV		ES, AX
		INC		CL
		CMP		CL, 18			; CL <= 18?
		JBE		readloop		; then read next sector
		MOV		CL, 1
		INC		DH
		CMP 	DH, 2			; DH < 2?
		JB		readloop		; then change head from 0 to 1
		MOV	 	DH, 0			; else read next cylinder 
		INC		CH
		CMP 	CH, CYLS		; #nextcylinder < CYLS?
		JB		readloop		; then read next cylinder

; jump to habibote.sys

		MOV		[0x0ff0], CH
		JMP		0xC200			; jump to haribote.nas

error:
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
		DB		"#--------------------------#", 0x0a
		DB		"# error while reading disk #", 0x0a
		DB		"#--------------------------#", 0x0a
		DB		0

		RESB	0x7dfe-$		; fill by null
		DB		0x55, 0xaa		; boot signature
