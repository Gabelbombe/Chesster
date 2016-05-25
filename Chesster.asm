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

f:inc d [di]              ; resume exploring exhaustive [0;0ffffh] interval
  jnz e                   ; including subset ["1a1a";"8h8h"] until finished
  mov cl,2                ; convert int32 to two file-first algebraic words

g:lodsw                   ; get first int16 msw/lsw algebraic notation word
  aam 16                  ; integer to expanded zero-based file/rank nibble
  add ax,2960h            ; translate file/rank to ascii chess board origin
  stosw                   ; write pair=half of the ascii move buffer string
  loop g                  ; get next int16 msw/lsw words algebraic notation
  jmp k                   ; and proceed examining ascii move buffer strings

h:mov si,di               ; di points to 0fffbh for both input and verified

i:mov di,si               ; resets every input to algebraic notation buffer
  mov cl,4                ; one file-first algebraic notation is four bytes

j:cbw                     ; zero accumulator msb to set funct get keystroke
  int 16h                 ; al=dos bios keyboard services api blocking read
  stosb                   ; src file=fffb;rank=fffc dst file=fffd;rank=fffe
  loop j                  ; all file-first algebraic ascii quartet inputed?
  call n                  ; else verify algebraic ascii move is legal chess
  jc i                    ; if not then proceed to ask user input move anew

k:call l                  ; converts algebraic notation buffer ascii source
  push w b                ; redirect second fall-through return to printout

l:lodsw                   ; algebraic notation buffer ascii source then dst
  sub ax,3161h            ; convert to zero-based alphanumerical 3161h="a1"
  aad 16                  ; convert to x88 board representation (al+=ah*16)
  mov di,ax               ; add x88 chess board representation memory start
  test cl,cl              ; verify caller's asked mode is passive or active
  jnz m                   ; call asked mode mutex is passive so skip writes
  xchg [di],ch            ; call asked mode mutex is active so write board!

m:and al,88h              ; test if inside main chess board x88 bitmask use
  ret                     ; return to standard callers or printout redirect

n:pusha                   ; save reg vals in: si=fff7h/fffbh di=fffbh/ffffh
  mov si,0fffbh           ; point source index to current ascii move buffer
  mov cl,8                ; set passive mode count mutex for only verifying
  call x                  ; convert buffer ascii src pair to x88 memory add
  jz u                    ; source is non-conforming : illegal empty square
  xor dl,al               ; sets move conformitiy using active player color
  test dl,cl              ; test move conformity using active player colour
  jnz u                   ; source is non-conforming : opponent turn colour
  mov bx,di               ; else if source conforming then save piece addr.
  mov dh,al               ; else if source conforming then save piece value
  call x                  ; convert buffer ascii dest to x88 memory address
  jz o                    ; if move nature not an attack skip over captures
  xor dl,al               ; sets move conformitiy using active player color
  test dl,cl              ; test move conformity using active player colour
  jnz u                   ; destination is non-conforming : same turn color

o:sub di,bx               ; source & destination conforming so obtain delta
  mov [0fff5h],al         ; save piece value as non-transactional potential
  mov al,dh               ; restore previous saved move source piece nature
  and al,7                ; normalize gray piece nature colorless isolation
  test al,1               ; determine source piece's parity interval length
  jz p                    ; piece face=piece nature=piece value=piece score
  mov cl,4                ; override halfing default interval len if parity

p:cmp al,1                ; test if moving piece is a special handling pawn
  mov bx,y                ; piece memory address off-by-one index ret fixed
  xlatb                   ; move piece original start offset memory address
  xchg ax,di              ; offset becomes accumulator becomes displacement
  jnz s                   ; leave if move source piece not special handling
  test dh,8               ; else adjust move source pawn color displacement
  jnz q                   ; no White pawn displacement sub-interval fixings
  scasd                   ; displacement interval offset+=4 for black pawns

q:test ch,ch              ; verify if pawn is attacking an opponent piece ?
  mov cx,2                ; loop index clears msb placeholder also sets lsb
  jnz s                   ; if non-empty square : pawn attacking diagonally
  dec cx                  ; else decrease parity interval size special case

r:scasw                   ; displacement interval start+=2 prunes attacking

s:add di,bx               ; set displacement interval scanning start offset
  repnz scasb             ; verify move exists in displacement sub-interval
  jz v                    ; ZF set legal src piece displacement delta found
  jmp u                   ; illegal src piece displacement: delta not found

t:pop ax                  ; bail shotcircuits nested dataflow function call

u:stc                     ; carry mutex persists indicating move is illegal

v:popa                    ; persistant CF mutex is indicator to legal chess
  ret                     ; restore move mode mutex cl=passive or cl=active

x:call l                  ; verify this move legal within inside main board
  jnz t                   ; exits for illegal move piece outside main board
  cmpxchg [di],al         ; discriminate from special case zero return vals

y:db 195,21,7,19,15,15,15 ; p[1]PF4,n[2]PF8,b[3]PF4,q[4]PF8,r[5]PF4,k[6]PF8

z:db -33,-31,-18,-14,14   ; prev label is ret+1 parity displacement offsets
  db 18,31,33,-16,16,-1,1 ; z array is displacement overlap interval values
  db 15,17,-15,-17,-16    ; knight rook+8 bishop+12 pawns White+12 Black+18
  db -32,15,17,16         ; queen and king moves are rook+bishop+pawn moves
