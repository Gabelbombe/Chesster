# Chesstlin and ASM based Minimalistic Chess Game

##### "You don't need eyes to see, you need vision." - Faithless

## About

This is a sizecoding / code gulf exercise to code a playable chess engine in 256 bytes. The proof of concept is extremely experimental and bears several shortcomings when compared with any other real FIDE existing chess game engine _you have been warned._ It plays like a fish as the AI is reduced to a half-ply max solely. Also, bear in mind that it has no end-game detection, so pawns will move only a single square, you will not be able to castle or promote - let alone en-passant. It takes about a hundred seconds to play. Currently this only will work on Microsoft Windows XP SP3 (so use Vagrant!). Like the minimalist Edlin line editor Chesstlin focuses on a single console line.
