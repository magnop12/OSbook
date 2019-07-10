void io_hlt(void);
void io_cli(void);
void io_out8(int port, int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);

#define COL8_000000		0
#define COL8_FF0000		1
#define COL8_00FF00		2
#define COL8_0000FF		3
#define COL8_FFFF00		4
#define COL8_00FFFF		5
#define COL8_FF00FF		6
#define COL8_FFFFFF		7
#define COL8_C6C6C6		8
#define COL8_840000		9
#define COL8_008400		10
#define COL8_000084		11
#define COL8_848400		12
#define COL8_008484		13
#define COL8_840084		14
#define COL8_848484		15

void HariMain(void)
{
	int i;
	char *p = 0xa0000;

	init_palette();

	for(i=0; i<0xffff; i++){
		//if (i<0xfa00) continue;
		p[i] = i & 0x0f;
	}

	for(;;){
		io_hlt();
	}
}

void init_palette(void)
{
	static unsigned char table_rgb[] = {
		0x00, 0x00, 0x00,	// black
		0xff, 0x00, 0x00,	// red
		0x00, 0xff, 0x00,	// green
		0x00, 0x00, 0xff,	// blue
		0xff, 0xff, 0x00,	// yellow
		0x00, 0xff, 0xff,	// cyan
		0xff, 0x00, 0xff,	// magenta
		0xff, 0xff, 0xff,	// white
		0xc6, 0xc6, 0xc6,	// gray
		0x84, 0x00, 0x00,	// dark red
		0x00, 0x84, 0x00,	// dark green
		0x00, 0x00, 0x84,	// dark blue
		0x84, 0x84, 0x00,	// dark yellow
		0x00, 0x84, 0x84,	// dark cyan
		0x84, 0x00, 0x84,	// dark magenta
		0x84, 0x84, 0x84	// dark gray
	};
	set_palette(0, 15, table_rgb);
	return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	eflags = io_load_eflags();	// save eflags
	io_cli();					// set IF = 0
	io_out8(0x03c8, start);
	for(i=start; i<=end; i++){
		io_out8(0x03c9, rgb[0]);
		io_out8(0x03c9, rgb[1]);
		io_out8(0x03c9, rgb[2]);
		rgb += 3;
	}
	io_store_eflags(eflags);	// resotre eflags
	return;
}