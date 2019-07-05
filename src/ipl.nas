; hello-os
; TAB=4

		ORG		0x7c00			; 命令の読み込み位置をアセンブラに通知 0x7c00はBIOS規定の番地
								; 以降の命令は0x7c00を起点としてアセンブルされる
		JMP		entry			; 0x7c00から始まる最初の命令

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述
		DB		0x90
		DB		"HELLOIPL"		; ブートセクタの名前を自由に書いてよい（8バイト）
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
		DB		"HELLO-OS   "	; ディスクの名前（11バイト）
		DB		"FAT12   "		; フォーマットの名前（8バイト）
		RESB	18				; とりあえず18バイトあけておく

; entry point

entry:
		XOR 	AX,AX			; zero clear AX
		MOV		SS,AX
		MOV		SP,0x7c00		; SP = entry
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]	 	 	; AL = msg[SI]
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
		DB		"HelloOS5 from ipl.nas..."
		DB		0x0a
		DB		0

		RESB	0x7dfe-$		; fill by null

		DB		0x55, 0xaa		; last 2 bytes of IPL
