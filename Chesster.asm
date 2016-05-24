w equ word
d equ dword
  org 100h
  pusha
  rep stosb
  cwd
  xchg ax,di
  mov cl,20h
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
