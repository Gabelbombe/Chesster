w equ word                ; 16-bit prettifying helper,Chesslin v1.0 in 2016
d equ dword               ; 32-bit prettifying helper,fasm assembler syntax
  org 100h                ; binary ip execution seg start address above psp
  pusha                   ; para down stack and avoid input buff collisions
  rep stosb               ; prepare board empty squares assumes ax=0 cx=255
  cwd                     ; set Black=0=top active player turn, White=8=bot
  xchg ax,di              ; shorter mov di,ax prepares writing segment base
  mov cl,20h              ; 32 initialization decoding bit rotations in all

a:mov eax,52364325h
  rol eax,cl
  and al,15
  stosb
  mov [di+0eh],si
  mov [di+5eh],bp
  or al,8
  mov [di+6fh],al
  sub cl,3
  loop a
