.386
.586
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf:proc


includelib canvas.lib
extern BeginDrawing: proc



format db "%d  %d"
window_title DB "Battleships",0
contor dd 0
area_width EQU 940
area_height EQU 780
area DD 0
aux1 dd 0
aux2 dd 0
aux dd 0
p2 dd 0
p1 dd 0
nr dd 10
ixu dd 0
igrec dd 0
lovite dd 0
ratate dd 0
nedescoperite dd 18

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20



symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
 
m dd 0



.code


red_square macro x,y,n
local bucla_line1,bucla_line2
    mov edx, 0
    mov eax, y
    mov ebx, area_width
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
bucla_line2:
    mov ecx, n
bucla_line1:
    mov dword ptr[eax], 0FF0000h
    add eax, 4
    loop bucla_line1
    inc edx
    shr eax,2
    sub eax,n
    add eax, area_width
    shl eax,2
    cmp edx,n
    jl bucla_line2
endm




blue_square macro x,y,n
local bucla_line1,bucla_line2
    mov edx, 0
    mov eax, y
    mov ebx, area_width
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
bucla_line2:
    mov ecx, n
bucla_line1:
    mov dword ptr[eax], 0FFh
    add eax, 4
    loop bucla_line1
    inc edx
    shr eax,2
    sub eax,n
    add eax, area_width
    shl eax,2
    cmp edx,n
    jl bucla_line2
endm



; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

line_vertical macro x, y, len, color
local bucla_line
    mov eax, y
    mov ebx, area_width
    mul ebx
    add eax, x
    shl eax, 2
    add eax, area
    mov ecx, len
bucla_line:
    mov dword ptr[eax], color
    mov ebx, area_width
    shl ebx, 2
    add eax, ebx
    loop bucla_line
endm

line_horizontal macro x, y, len, color
local bucla_line
    mov ecx, len
    mov eax, y
    mov ebx, area_width
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
bucla_line:
    mov dword ptr[eax], color
    add eax, 4
    loop bucla_line
endm


; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm



; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:

mov eax ,[ebp+arg2]
mov ebx, [ebp+arg3]
cmp eax ,40
jl diff
cmp ebx,120
jl diff
cmp eax ,440
jg diff
cmp ebx,520
jg diff

mov p1,eax
mov p2 ,ebx

mov edx,0
mov aux1,40
div aux1

sub p1,edx
mov edx,0
mov eax,p2
div aux1

sub p2,edx


mov ecx,[ebp+arg2]
mov esi,[ebp+arg3]



                       ;ma uit daca e lovit
sub ecx,40
mov eax,ecx
mov edx,0
mov aux2,40
div aux2
 shl eax,2
 add eax,4
 
mov ecx,eax

  sub esi,120
mov eax,esi
mov edx,0
div aux2


 
mov esi,eax

mov ebx ,ecx
mov eax, esi
mul aux2

add ebx,eax

cmp nedescoperite,0
je castigat
cmp m[ebx],2
je nimic
cmp m[ebx],1

je face_lovit


inc ratate
mov m[ebx],2
blue_square p1,p2,40 
jmp face_ratat

face_lovit:

inc lovite
mov m[ebx],2
dec nedescoperite
red_square p1,p2,40

face_ratat:
nimic:

castigat:
; make_text_macro 'A', area, 150, 650
	; make_text_macro 'I', area, 160, 650
	; make_text_macro 'C', area, 180, 650
	; make_text_macro 'A', area, 190, 650
	; make_text_macro 'S', area, 200, 650
	; make_text_macro 'T', area, 210, 650
	; make_text_macro 'I', area, 220, 650
	; make_text_macro 'G', area, 230, 650
	; make_text_macro 'A', area, 240, 650
	; make_text_macro 'T', area, 250, 650



diff:
	jmp afisare_litere
	
evt_timer:
	inc counter

	
afisare_litere:

;afisez lovite
mov ebx, 10
	mov eax, lovite
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,700, 150
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,690, 150
	
	;afisez ratate
	
	mov ebx, 10
	mov eax, ratate
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,700, 185
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,690, 185
	
	;parti nedescoperite
	
	mov ebx, 10
	mov eax, nedescoperite
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,750,220
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area,740, 220
	
	;scriem un mesaj
	make_text_macro 'O', area, 800, 750
	make_text_macro 'A', area, 810, 750
	make_text_macro 'R', area, 820, 750
	make_text_macro 'A', area, 830, 750
	make_text_macro 'R', area, 860, 750
	make_text_macro 'A', area, 870, 750
	make_text_macro 'Z', area, 880, 750
	make_text_macro 'V', area, 890, 750
	make_text_macro 'A', area, 900, 750
	make_text_macro 'N', area, 910, 750

	
	
	
	make_text_macro 'A', area, 600, 150
	make_text_macro 'I', area, 610, 150	
	make_text_macro 'L', area, 630, 150
	make_text_macro 'O', area, 640, 150
	make_text_macro 'V', area, 650, 150
	make_text_macro 'I', area, 660, 150
	make_text_macro 'T', area, 670, 150
	
	make_text_macro 'A', area, 600, 185
	make_text_macro 'I', area, 610, 185
	make_text_macro 'R', area, 630, 185
	make_text_macro 'A', area, 640, 185
	make_text_macro 'T', area, 650, 185
	make_text_macro 'A', area, 660, 185
	make_text_macro 'T', area, 670, 185
	
	make_text_macro 'N', area, 600, 220
	make_text_macro 'E', area, 610, 220
	make_text_macro 'D', area, 620, 220
	make_text_macro 'E', area, 630, 220
	make_text_macro 'S', area, 640, 220
	make_text_macro 'C', area, 650, 220
	make_text_macro 'O', area, 660, 220
	make_text_macro 'P', area, 670, 220
	make_text_macro 'E', area, 680, 220
	make_text_macro 'R', area, 690, 220
	make_text_macro 'I', area, 700, 220
	make_text_macro 'T', area, 710, 220
	make_text_macro 'E', area, 720, 220
	
	
	
	
	
	line_vertical  40, 120, 400, 0h
    line_vertical  80, 120, 400, 0h
	line_vertical  120, 120,400, 0h
	line_vertical  160, 120, 400, 0h
    line_vertical  200, 120, 400, 0h
	line_vertical  240, 120, 400, 0h
	line_vertical  280, 120, 400, 0h
    line_vertical  320, 120, 400, 0h
	line_vertical  360, 120, 400, 0h
	line_vertical  400, 120, 400,0h
    line_vertical  440, 120, 400,0h
	
	line_horizontal  40, 120, 400, 0h
	line_horizontal  40, 160, 400, 0h
	line_horizontal  40, 200, 400, 0h
	line_horizontal  40, 240, 400, 0h
	line_horizontal  40, 280, 400, 0h
	line_horizontal  40, 320, 400, 0h
	line_horizontal  40, 360, 400, 0h
	line_horizontal  40, 400, 400, 0h
	line_horizontal  40, 440, 400, 0h
	line_horizontal  40, 480, 400, 0h
	line_horizontal  40, 520, 400, 0h
	
	


final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:



	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	
	
	mov eax, nr
    mul nr
    push eax
    call malloc
    add esp, 4
    mov m, eax
	
	mov eax,1
	
	buci:
	cmp eax,400 ; initializez
	jg peste
	 mov m[eax],0
	 add eax,4
	 jmp buci
	 

	 
	
buciv2:

cmp contor,3
je peste_bucla

rdtsc ; generez nr random
mov edx,0
mov aux2,100
div aux2
inc edx;

cmp edx,10 ;margini
jle peste

cmp edx,80
jge peste

cmp edx,20
je peste
cmp edx,30
je peste
cmp edx,40
je peste
cmp edx,50
je peste
cmp edx,60
je peste
cmp edx,70
je peste

cmp edx,11
je peste
cmp edx,21
je peste
cmp edx,31
je peste
cmp edx,41
je peste
cmp edx,51
je peste
cmp edx,61
je peste
cmp edx,71
je peste


shl edx,2


cmp m[edx],1
je peste
cmp m[edx-4],1
je peste
cmp m[edx+4],1
je peste
cmp m[edx-40],1
je peste
cmp m[edx+40],1
je peste
cmp m[edx+80],1
je peste

;daca e ok

mov m[edx],1
mov m[edx-4],1
mov m[edx+4],1
mov m[edx-40],1   ; il bag 
mov m[edx+40],1
mov m[edx+80],1

inc contor



peste:

jmp buciv2


	
peste_bucla:




	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	
	
	
	
	
	
	


	
	
	
	;terminarea programului
	push 0
	call exit
end start
