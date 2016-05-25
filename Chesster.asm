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

c:lodsb                   ; get one of four usr/cpu bytes from ascii buffer
  int 29h                 ; dos api fast console out display char al=[di++]
  loop c                  ; continue until ascii file-first pair chars left
  xor dl,8                ; alternate active player turn Black=0 or White=8
  pop di                  ; shorter restore algebraic notation buffer start
  jnz h                   ; if active player turn is White then do keyboard
  fldz                    ; else Black active player turn fpu load +0.0 cst
  fbstp [di-6]            ; and store back 80-bit packed bcd decimal number

e:mov si,0fff5h           ; zeroed this,best score 0fff5h and coords 0fff7h
  lodsw                   ; move lsb=potential capture vs. msb=best capture
  cmp al,ah               ; compare this capture value against best capture
  jc f                    ; prune calculations if capture already lower val
  call n                  ; else verify the attack potential chess legality
  jc f                    ; capture higher value but move was illegal chess
  mov [di-7],al           ; successful calculation thus store newer highest
  fild d [di]             ; successful calculation thus load current coords
  fistp d [si]            ; successful calculation thus store highest coord

f:inc d [di]
  jnz e
  mov cl,2

g:lodsw
  aam 16
  add ax,2960h
  stosw
  loop g
  jmp k
