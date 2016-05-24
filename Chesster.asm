w equ word
d equ dword
  org 100h
  pusha
  rep stosb
  cwd
  xchg ax,di
  mov cl,20h
