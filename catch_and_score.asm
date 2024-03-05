[org 0x0100]
jmp start

W : db 'WELCOME TO CATCH AND SCORE GAME', 0
inst: db 'INSTRUCTIONS:', 0
play : db '* Press ENTER key to Start the Game', 0
esc_key: db '* Press ESC key to Exit the Game', 0
lkey : db '* Press Left arrow "<-" key to move the Bucket Left', 0
rkey : db '* Press Right arrow "->" key to move the Bucket Right', 0
time : db 'TIME limit is 2 minutes', 0
score: db 'SCORE is as follows: ', 0
obj: db 'OTHER OBJECTS',0
GA: db 'GREEN APPLE',0
RA: db 'RED APPLE',0
BA: db 'BLUE APPLE',0
p5: db '(5 points)', 0
p10: db '(10 points)', 0
p15: db '(15 points)', 0
Bomb: db 'BOMB', 0
Bucket: db 'BUCKET', 0
semi: db ':', 0
tc: db 0x6F				; backcolour: brown  color: white 
ts: dw 5				; starting index of text on start screen

; coordinates of objects
; y coordinates
buck_y: dw 21
g_y: dw -3
r_y: dw -9
b_y: dw -7
bomb_y: dw -10

; x coordinates
g_x: dw 10
r_x: dw 40
b_x: dw 65
bomb_x : dw 50

g_c: dw 0
r_c: dw 0
b_c: dw 0

; end coordinates
GO : db 'GAME OVER!', 0
Score : db 'SCORE:', 0
Time : db 'TIME:', 0

g_coll: db 'GREEN APPLES:',0
r_coll: db 'RED APPLES:', 0
b_coll: db 'BLUE APPLES:', 0

randomNum: db 0
oldisr: dd 0

clrscreen:
push es
push ax
push di
mov ax, 0xB800
mov es, ax
mov di, 0
mov ax, 0x0720
l1:
mov word[es:di], ax
add di, 2
cmp di, 4000
jnz l1
pop di
pop ax
pop es
ret

delay:
push bp
mov bp, sp
push di
push si
push ax
mov di, 500
mov ax, [bp+4]
mul di
mov di, ax
d01:
mov si, 0
d02:
inc si
cmp si, 1000
jnz d02
dec di
cmp di, 0
jnz d01
pop ax
pop si
pop di
pop bp
ret 2

delay_time:
push bp
mov bp, sp
push di
push si
push ax
mov ax, 1000
mov bx, [bp+4]
div bx
mov di, ax
d1:
mov si, 0
d2:
inc si
cmp si, 1000
jnz d2
dec di
cmp di, 0
jnz d1
pop ax
pop si
pop di
pop bp
ret 2

randomNumber:
push cx
push dx
push ax
push bx
rdtsc
mov dx, 0
mov cx, 156
div cx
mov byte[randomNum], dl
pop bx
pop ax
pop dx
pop cx
ret

gameover:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push si
push di

mov ax, 0xB800
mov es, ax

mov di, [bp+12]		; left x-coordinate
shl di, 1
mov cx, [bp+10]		; right x-coordinate
shl cx, 1
sub cx, di			; length of rectangle

mov ax, [bp+8]		; lower y-coordinate
mov bx, 160
mul bx
add di, ax

mov ax, [bp+6]		; upper y-coordinate
mov bx, 160
mul bx
mov dx, ax
g2:
mov si, 0
mov ax, [bp+4]
g1:
mov word[es:di], ax
add di, 2
add si, 2
cmp si, cx
jl g1
add di, 160
sub di, cx
cmp di, dx
jl g2

pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 10


background:
push bp
mov bp, sp
push es
push ax
push bx
push dx
push di

mov ax, 0xB800
mov es, ax

mov ax, [bp+8]		; starting row of background
mov bx, 160
mul bx
mov di, ax
mov ax, [bp+6]		; ending row of background
mov bx, 160
mul bx
mov dx, ax
mov ax, [bp+4]		; colour in the background
loop1:
mov word[es:di], ax
add di, 2
cmp di, dx
jnz loop1

pop di
pop dx
pop bx
pop ax
pop es
pop bp
ret 6


cloud:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push di
push si

mov cx, 0
mov ax, 0xB800
mov es, ax
cl2:
; Calculating coordinates on Screen
mov ax, [bp+4]		; row number
add ax, cx
mov bx, 80
mul bx
mov di, ax
add di, [bp+6]		;  column number
shl di, 1
mov si, [bp+8]		; size of Cloud
mov ax, cx
shl ax, 2
add si, ax
sub di, si
cl1:
mov word[es:di], 0x7020		; background-colour: white
add di, 2
dec si
cmp si, 0
jnz cl1

inc cx
cmp cx, 3
jnz cl2

pop si
pop di
pop cx
pop bx
pop ax
pop es
pop bp
ret 6

bush:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push di
push si

mov cx, 0
mov ax, 0xB800
mov es, ax
bl2:
; Calculating coordinates on Screen
mov ax, [bp+4]		; row number
add ax, cx
mov bx, 80
mul bx
mov di, ax
add di, [bp+6]		; column number
shl di, 1
mov si, [bp+8]		; width of bush top
mov ax, cx
shl ax, 1
add si, ax
sub di, si
bl1:
mov word[es:di], 0x2A2B		; using '+' for leaves of bush
add di, 2
dec si
cmp si, 0
jnz bl1

inc cx
cmp cx, 4					; height of tree
jnz bl2

pop si
pop di
pop cx
pop bx
pop ax
pop es
pop bp

ret 6

print_string:
push bp
mov bp, sp
push es
push ax
push cx
push si
push di
push ds
pop es 					; load ds in es
; calculating Length of string
mov di, [bp+4] 			; point di to string
mov cx, 0xffff
mov al, 0
repne scasb 			; find zero in the string
mov ax, 0xffff
sub ax, cx
dec ax
jz exit 				; no printing if string is empty
mov cx, ax
mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+8] 		; multiply with y position
add ax, [bp+10] 		; add x position
shl ax, 1
mov di,ax ; point di to required location
mov si, [bp+4] 			; point si to string
mov ah, [bp+6] 			; load attribute in ah
cld

char: lodsb 		; load next char in al
stosw 				; print char/attribute pair
loop char 			; repeat for the whole string

exit: pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8

printnum: push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov al, 80
mul byte [bp+6] 		; multiply with y position
add ax, [bp+8] 		; add x position
shl ax, 1
mov di, ax ; point di to top left column
nextpos: pop dx ; remove a digit from the stack
mov dh, [bp+10] ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2

; Drawing Vertical Line
vertical:
push bp
mov bp, sp
push es
push ax
push bx
push si
push di

mov ax, 0xB800
mov es, ax
mov dx, 0
mov ax, [bp+6]			; starting y-coordinate
mov bx, 80
mul bx
mov di, [bp+8]			; x-coordinate
add di, ax
shl di, 1

mov dx, 0
mov ax, [bp+4]			; ending y-coordinate
mov bx, 80
mul bx
mov si, [bp+8]			; x-coordinate
add si, ax
shl si, 1
mov ax, 0x0720			; Colour: Black
ver:
mov word[es:di], ax
add di, 160
cmp di, si
jl ver
pop di
pop si
pop bx
pop ax
pop es
pop bp
ret 6

; Drawing Horizontal Line
horizontal:
push bp
mov bp, sp
push es
push ax
push bx
push si
push di

mov ax, 0xB800
mov es, ax
mov dx, 0
mov ax, [bp+4]			; y coordinate
mov bx, 80
mul bx
mov di, [bp+8]			; starting x coordinate
add di, ax
shl di, 1

mov dx, 0
mov ax, [bp+4]			; y coordinate
mov bx, 80
mul bx
mov si, [bp+6]			; ending x coordinate
add si, ax
shl si, 1
mov ax, 0x0720			; Colour: Black
hor:
mov word[es:di], ax
add di, 2
cmp di, si
jl hor
pop di
pop si
pop bx
pop ax
pop es
pop bp
ret 6


apple:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push di
push si

mov cx, 0
mov ax, 0xB800
mov es, ax

mov ax, [bp+4]				; row number
mov bx, 80
mul bx
mov di, ax
add di, [bp+6]				; column number
shl di, 1
mov bx, di
add di, 4
mov word[es:di], 0x6259		; stem of apple with 'Y'  colour: brown
add bx, 160
a2:

mov di, bx
mov si, 0
a1:
cmp cx, 0
jnz ski
cmp si, 2
jnz ski
mov word[es:di], 0x6058		; stem of apple with 'X'  colour: brown
jmp b
ski:
mov ax, [bp+8]				; colour of apple
mov word[es:di], ax
b: add di, 2
inc si
cmp si, 5
jnz a1
inc cx
add bx, 160
cmp cx, 2
jnz a2

pop si
pop di
pop cx
pop bx
pop ax
pop es
pop bp

ret 6

bucket:
push bp
mov bp, sp
push ax
push es
push bx
push cx
push di
push si

mov ax, 0xB800
mov es, ax

mov cx, 3

; using formula (row*80+col)*2 to calculate coordinates of bucket
mov ax, [bp+4]		; y coordinate
mov bx, 80
mul bx
mov di, [bp+6]		; x coordinate
add di, ax
shl di, 1

mov si, 7
b2:
b3:
cmp cx, 3
jz nobg
cmp cx, 2
jz sk
cmp si, 7
jz nobg
cmp si, 1
jz nobg
jmp it
sk:
cmp si, 2
jle nobg
cmp si, 6
jge nobg
jmp it
nobg:
mov word[es:di], 0x0020
it:
dec si
add di, 2
cmp si, 0
jnz b3
mov si, 7
sub di, 160
mov ax, si
shl ax, 1
sub di, ax
dec cx
cmp cx, 0
jnz b2

pop si
pop di
pop cx
pop bx
pop es
pop ax
pop bp
ret 4

bomb:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push di
push si

mov ax, 0xB800
mov es, ax
mov di, [bp+6]		; x coordinate
mov ax, [bp+4]		; y coordinate
mov bx, 80
mul bx
add di, ax
shl di, 1
mov bx, di
mov si, 0

mov cx, 0
bomb2:
mov si, 0
mov di, bx
bomb1:
cmp cx, 1
jnz bombskip
cmp si, 1
jz n
t:
mov ax, 0x7054				; printing T of TNT on screen
mov word[es:di], ax
jmp bombs
n:
mov ax, 0x704E				; printing N of TNT on screen
mov word[es:di], ax
jmp bombs
bombskip:
mov ax, 0x467C				; TNT cylinder  Color: RED
mov word[es:di], ax
bombs:
add di, 2
inc si
cmp si, 3
jnz bomb1
add bx, 160
inc cx
cmp cx, 3
jnz bomb2

pop si
pop di
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

square:
push bp
mov bp, sp
push ax
push bx
push es
push cx
push di
push si

mov ax, 0xB800
mov es, ax

mov ax, [bp+6]			; y coordinate
mov bx, 80
mul bx
mov di, [bp+8]			; x coordinate
add di, ax
shl di, 1
mov ah, [bp+10]			; colour of box
mov al, 0x20

mov cx, 0
box2:
mov si, 0
mov bx, di
box1:
mov word[es:di], ax
add di, 2
inc si
cmp si, [bp+4]			; length of rectangle
jnz box1
mov di, bx
add di, 160
inc cx
cmp cx, 2
jnz box2

pop si
pop di
pop cx
pop es
pop bx
pop ax
pop bp
ret 8

kbisr: push ax
in al, 0x60
cmp al, 0x4b ; has the left key pressed
jne nextcmp ; no, try next comparison
dec cl
jmp ex ; leave interrupt routine
nextcmp: cmp al, 0x4d ; has the right key pressed
jne nextcmp2 ; no, try next comparison
inc cl
jmp ex ; leave interrupt routine
nextcmp2: cmp al, 0xcb ; has the left key released
jne nextcmp3 ; no, try next comparison
jmp ex ; leave interrupt routine
nextcmp3: cmp al, 0xcd ; has the right key released
jne nomatch ; no, chain to old ISR
jmp ex ; leave interrupt routine
nomatch:
pop ax
jmp far [cs:oldisr] ; call the original ISR
ex: mov al, 0x20
out 0x20, al ; send EOI to PIC
pop ax
iret


start:
call clrscreen
mov ax, 0		; starting row number
push ax	
mov ax, 25		; ending row number
push ax
mov ax, 0x6020	; backcolour: brown  color: white
push ax
call background

mov ax, 20			; x-coordinate
push ax
mov ax, 2			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, W			; Printing 'Welcome' on starting screen
push ax
call print_string

mov ax, 2
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 5			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, inst		; Printing 'Instructions' on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 7			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, play		; Printing Enter instruction on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 8			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, lkey		; Printing left key on instruction on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 9			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, rkey		; Printing right key on instruction on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 11			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, time		; Printing Time instruction on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay


mov ax, 50			; x coordinate
push ax
mov ax, 14			; starting y coordinate
push ax
mov ax, 25			; ending y coordinate
push ax
call vertical		; Vertical Line

mov ax, 0			; starting x coordinate
push ax
mov ax, 80			; ending x coordinate
push ax
mov ax, 13			; y coordinate
push ax
call horizontal		; Horizontal Line

mov ax, 1
push ax
call delay

mov ax, [ts]		; x-coordinate
push ax
mov ax, 15			; y-coordinate
push ax
mov ax, [tc]		; backcolour: brown  color: white
push ax
mov ax, score		; Printing 'Score' on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, 5		; x-coordinate
push ax
mov ax, 17		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, GA		; Printing 'Green Apple' on screen
push ax
call print_string

mov ax, 5		; x-coordinate
push ax
mov ax, 18		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, p5		; Printing '5 points' on screen
push ax
call print_string

mov ax, 0x2020	; color: GREEN
push ax
mov ax, 7		; column number
push ax
mov ax, 20		; row number
push ax
call apple

mov ax, 1
push ax
call delay

mov ax, 20		; x-coordinate
push ax
mov ax, 17		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, RA		; Printing 'Red Apple' on screen
push ax
call print_string

mov ax, 20		; x-coordinate
push ax
mov ax, 18		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, p10		; Printing '10 points' on screen
push ax
call print_string

mov ax, 0x4020	; color: RED
push ax
mov ax, 22		; column number
push ax
mov ax, 20		; row number
push ax
call apple

mov ax, 1
push ax
call delay

mov ax, 35		; x-coordinate
push ax
mov ax, 17		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, BA		; Printing 'Blue Apple' on screen
push ax
call print_string

mov ax, 35		; x-coordinate
push ax
mov ax, 18		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, p15		; Printing '15 points' on screen
push ax
call print_string

mov ax, 0x1020	; color: BLUE
push ax
mov ax, 37		; column number
push ax
mov ax, 20		; row number
push ax
call apple

mov ax, 1
push ax
call delay

mov ax, 60		; x-coordinate
push ax
mov ax, 15		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, obj		; Printing 'Other Objects' on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, 58		; x-coordinate
push ax
mov ax, 18		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, Bomb	; Printing 'BOMB' on ending screen
push ax
call print_string


mov ax, 58		; column number
push ax
mov ax, 20		; row number
push ax
call bomb		; Bomb object

mov ax, 1
push ax
call delay

mov ax, 69		; x-coordinate
push ax
mov ax, 18		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, Bucket	; Printing 'BUCKET' on ending screen
push ax
call print_string

mov ax, 68		; column number
push ax
mov ax, 22		; row number
push ax
call bucket		; Bucket object

ent:
mov ah, 1
int 0x21
cmp al, 13
jnz ent

; Game Screen

mov di, 0		; counter for seconds
mov ch, 0		; ch for counting minutes
mov cl, 40		; cl for moving bucket
mov si, 0		; si for Scoring
game:
mov dx, 0

xor ax, ax
mov es, ax 			; point es to IVT base
mov ax, [es:9*4]
mov [oldisr], ax 	; save offset of old routine
mov ax, [es:9*4+2]
mov [oldisr+2], ax 	; save segment of old routine
cli 				; disable interrupts
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs 	; store segment at n*4+2
sti 				; enable interrupts

cmp cl, 0
jl less
cmp cl, 73
jg greater
jmp fine
less: mov cl, 0
jmp fine
greater: mov cl, 73
fine:

mov ax, 0		; starting row number
push ax	
mov ax, 22		; ending row number
push ax
mov ax, 0x3020	; bakcground-colour: turquoise
push ax
call background


mov ax, 6		; size of cloud
push ax
mov ax, di		; column number
push ax
mov ax, 2		; row number
push ax
call cloud

mov ax, 4		; size of cloud
push ax
mov ax, di		; column number
add ax, 25
push ax
mov ax, 2		; row number
push ax
call cloud

mov ax, 6		; size of cloud
push ax
mov ax, di		; column number
add ax, 50
push ax
mov ax, 3		; row number
push ax
call cloud

mov ax, 2		; size of bush
push ax
mov ax, 10		; column number
push ax
mov ax, 18		; row number
push ax
call bush

mov ax, 2		; size of bush
push ax
mov ax, 70		; column number
push ax
mov ax, 18		; row number
push ax
call bush


mov ax, 0x1F	; background-colour: BLUE	color: WHITE
push ax
mov ax, 33		; x coorinate
push ax
mov ax, 1		; y coordinate
push ax
mov ax, 8		; length of rectangle
push ax
call square

mov ax, 0x1F	; background-colour: BLUE	color: WHITE
push ax
mov ax, 68		; x coorinate
push ax
mov ax, 1		; y coordinate
push ax
mov ax, 9		; length of rectangle
push ax
call square

mov ax, 35		; x-coordinate
push ax
mov ax, 1		; y-coordinate
push ax
mov ax, 0x1F	; background-colour: BLUE	color: WHITE
push ax
mov ax, Time	; Printing 'Time' on screen
push ax
call print_string

mov ax, 0x1F	; background-colour: BLUE  color: WHITE
push ax
mov ax, 35		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax
mov al, ch	; Printing Minutes on screen
mov ah, 0
push ax
call printnum


mov ax, 36		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax
mov ax, 0x1F	; background-colour: BLUE	color: WHITE
push ax
mov ax, semi	; Printing ':' on screen
push ax
call print_string

mov ax, di
shr ax, 2
cmp ax, 10
jge ten_sec
mov ax, 0x1F	; background-colour: BLUE  color: WHITE
push ax
mov ax, 37		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax
mov ax, 0		; Printing seconds on screen
push ax
call printnum
mov ax, 0x1F	; background-colour: BLUE  color: WHITE
push ax
mov ax, 38		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax
mov ax, di
shr ax, 2		; Printing seconds on screen
push ax
call printnum
jmp one_sec
ten_sec:
mov ax, 0x1F	; background-colour: BLUE  color: WHITE
push ax
mov ax, 37		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax

mov ax, di
shr ax, 2		; Printing seconds on screen
push ax
call printnum
one_sec:

mov ax, 70		; x-coordinate
push ax
mov ax, 1		; y-coordinate
push ax
mov ax, 0x1F	; background-colour: BLUE	color: WHITE
push ax
mov ax, Score	; Printing 'Score' on screen
push ax
call print_string

mov bl, cl
mov bh, 0

; checking if bucket caught green apple
mov dx, [g_y]
cmp dx, 19
jnz fill
mov dx, [g_x]
cmp dx, bx
jl fill
sub dx, 2
cmp dx, bx
jg fill
add si, 5			; adding score
inc word[g_c]		; counting no. of green apples

mov word[g_y], -3	; giving new coordinates to green apple
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[g_x], dx
cmp dx, 75			; to make sure apple doesnot go out of bound
jl fill
mov word[g_x], 10
jmp fill2
fill:
; checking if bucket caught red apple
mov dx, [r_y]
cmp dx, 19
jnz fill1
mov dx, [r_x]
cmp dx, bx
jl fill1
sub dx, 2
cmp dx, bx
jg fill1
add si, 10				; adding score
inc word[r_c]			; counting no. of green apples
mov word[r_y], -3		; giving new coordinates to red apple
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[r_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl fill1
mov word[r_x], 25		
jmp fill2
fill1:
; checking if bucket caught blue apple
mov dx, [b_y]
cmp dx, 19
jnz fill2
mov dx, [b_x]
cmp dx, bx
jl fill2
sub dx, 2
cmp dx, bx
jg fill2
add si, 15				; adding score
inc word[b_c]			; counting no. of green apples
mov word[b_y], -5		; giving new coordinates to blue apple
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[b_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl fill2
mov word[b_x], 15
fill2:
; checking if bucket hit bomb
mov dx, [bomb_y]
cmp dx, 19
jnz fill3
mov dx, [bomb_x]
add dx, 2
cmp dx, bx
jl fill3
sub dx, 8
cmp dx, bx
jg fill3
jmp game_end
fill3:

mov ax, 0x1F	; background-colour: BLUE  color: WHITE  blinker: ON
push ax
mov ax, 72		; x-coordinate
push ax
mov ax, 2		; y-coordinate
push ax
mov ax, si		; Printing Score on screen
push ax
call printnum

mov ax, 0x4020	; color: RED
push ax
mov ax, [r_x]	; column number
push ax
mov ax, [r_y]	; row number
push ax
call apple

mov ax, 0x2020	; color: GREEN
push ax
mov ax, [g_x]	; column number
push ax
mov ax, [g_y]	; row number
push ax
call apple

mov ax, 0x1020	; color: BLUE
push ax
mov ax, [b_x]	; column number
push ax
mov ax, [b_y]		; row number
push ax
call apple

mov ax, [bomb_x]		; column number
push ax
mov ax, [bomb_y]		; row number
push ax
call bomb

mov al, cl		; column number
mov ah, 0
push ax
mov ax, [buck_y]		; row number
push ax
call bucket

mov ax, 22		; starting row number
push ax	
mov ax, 24		; ending row number
push ax
mov ax, 0x2A5E	; background-colour: Green   Grass-colour: Light Green
push ax
call background

mov ax, 24		; starting row number
push ax	
mov ax, 25		; ending row number
push ax
mov ax, 0x6020	; background-colour: Brown
push ax
call background

mov ax, 4
push ax
call delay_time

; giving new coordinates to objects if they fall on the ground
mov dx, [b_y]
inc dx
mov word[b_y], dx
cmp dx, 24
jle p1
mov word[b_y], -5
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[b_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl p1
mov word[b_x], 10
p1:
mov dx, [g_y]
inc dx
mov word[g_y], dx
cmp dx, 24
jle p2
mov word[g_y], -4
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[g_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl p2
mov word[g_x], 15
p2:
mov dx, [r_y]
inc dx
mov word[r_y], dx
cmp dx, 24
jle p3
mov word[r_y], -3
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[r_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl p3
mov word[r_x], 10
p3:
mov dx, [bomb_y]
inc dx
mov word[bomb_y], dx
cmp dx, 24
jle p4
mov word[bomb_y], -4
call randomNumber
mov dh, 0
mov dl, [randomNum]
mov word[bomb_x], dx
cmp dx, 75				; to make sure apple doesnot go out of bound
jl p4
mov word[bomb_x], 18
p4:

inc di
mov ax, di
shr ax, 2
cmp ax, 60
jnz s
mov di, 0
inc ch
s:
cmp ch, 2
jnz game

game_end:
mov ax, 15		; starting x-coordinate
push ax
mov ax, 65		; ending x-coordinate
push ax
mov ax, 6		; starting y-coordinate
push ax
mov ax, 19		; ending y-coordinate
push ax
mov ax, 0x6020	; background-colour: brown
push ax
call gameover

mov ax, 33		; x-coordinate
push ax
mov ax, 7		; y-coordinate
push ax
mov ax, 0xEF	; backcolour: brown  color: white	Blinker: ON
push ax
mov ax, GO		; Printing 'Game Over' on ending screen
push ax
call print_string

mov ax, 1
push ax
call delay

mov ax, 32		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, Time	; Printing 'Game Over' on ending screen
push ax
call print_string

mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 38		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov al, ch		; Printing Minutes on screen
mov ah, 0
push ax
call printnum

mov ax, 39		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, semi	; Printing ':' on screen
push ax
call print_string

shr di, 2
cmp di, 10
jge t_sec
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 40		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov ax, 0		; Printing seconds on screen
push ax
call printnum
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 41		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov ax, di		; Printing seconds on screen
push ax
call printnum
jmp o_sec
t_sec:
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 40		; x-coordinate
push ax
mov ax, 10		; y-coordinate
push ax
mov ax, di		; Printing seconds on screen
push ax
call printnum
o_sec:

mov ax, 1
push ax
call delay

mov ax, 32		; x-coordinate
push ax
mov ax, 12		; y-coordinate
push ax
mov ax, [tc]	; backcolour: light-blue  color: black
push ax
mov ax, Score	; Printing 'SCORE' on ending screen
push ax
call print_string

mov ax, [tc]	; background-colour: BLUE  color: WHITE  blinker: ON
push ax
mov ax, 40		; x-coordinate
push ax
mov ax, 12		; y-coordinate
push ax
mov ax, si		; Printing Score on screen
push ax
call printnum

mov ax, 1
push ax
call delay

mov ax, 30		; x-coordinate
push ax
mov ax, 15		; y-coordinate
push ax 
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, g_coll	; Printing 'Game Over' on ending screen
push ax
call print_string

mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 45		; x-coordinate
push ax
mov ax, 15		; y-coordinate
push ax
mov ax, [g_c]	; Printing Time on screen
push ax
call printnum

mov ax, 1
push ax
call delay

mov ax, 30		; x-coordinate
push ax
mov ax, 16		; y-coordinate
push ax 
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, r_coll	; Printing 'Game Over' on ending screen
push ax
call print_string

mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 45		; x-coordinate
push ax
mov ax, 16		; y-coordinate
push ax
mov ax, [r_c]	; Printing Time on screen
push ax
call printnum

mov ax, 1
push ax
call delay

mov ax, 30		; x-coordinate
push ax
mov ax, 17		; y-coordinate
push ax
mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, b_coll	; Printing 'Game Over' on ending screen
push ax
call print_string

mov ax, [tc]	; backcolour: brown  color: white
push ax
mov ax, 45		; x-coordinate
push ax
mov ax, 17		; y-coordinate
push ax
mov ax, [b_c]	; Printing Time on screen
push ax
call printnum

mov ax, 0x4c00
int 21h