w equ word                ; 16-bit prettifying helper,Chesster v1.0 in 2016
d equ dword               ; 32-bit prettifying helper,fasm assembler syntax
  org 100h                ; binary ip execution seg start address above psp
  pusha                   ; para down stack and avoid input buff collisions
  rep stosb               ; prepare board empty squares assumes ax=0 cx=255
  cwd                     ; set Black=0=top active player turn, White=8=bot
  xchg ax,di              ; shorter mov di,ax prepares writing segment base
  mov cl,20h              ; 32 initialization decoding bit rotations in all

a:mov eax,52364325h       ; back-rank "rnbqkbnr" nibble-encoded 32b pattern
  rol eax,cl              ; rotate next Black chess piece value in lsnibble
  and al,15               ; isolate a Black chess piece value from lsnibble
  stosb                   ; left-to-right write Black back-rank major piece
  mov [di+0eh],si         ; left-to-right write Black pawns assumes si=100h
  mov [di+5eh],bp         ; left-to-right write White pawns assumes bp=9xxh
  or al,8                 ; transforms Black back-rank major piece to White
  mov [di+6fh],al         ; left-to-right write White back-rank major piece
  sub cl,3                ; fixes back-rank pattern nibble rotation counter
  loop a                  ; file-by-file ranks init loops 20h/(3+1)=8 times

b:mov si,0fffbh           ; point source index to algebraic notation buffer
  push si                 ; shorter save of algebraic notation buffer start
  mov cx,4                ; print dword ascii algebraic notation buffer str

c:lodsb
  int 29h
  loop c
  xor dl,8
  pop di
  jnz h
  fldz
  fbstp [di-6]

e:mov si,0fff5h
  lodsw
  cmp al,ah
  jc f
  call n
  jc f
  mov [di-7],al
  fild d [di]
  fistp d [si]
