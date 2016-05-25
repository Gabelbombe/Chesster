# Chesster: An ASM minimalist 256b chess game

##### "You don't need eyes to see, you need vision." - Faithless

## About

This is a sizecoding / code gulf exercise to code a playable chess engine in 256 bytes. The proof of concept is extremely experimental and bears several shortcomings when compared with any other real FIDE existing chess game engine _you have been warned._ It plays like a fish as the AI is reduced to a half-ply max solely. Also, bear in mind that it has no end-game detection, so pawns will move only a single square, you will not be able to castle or promote - let alone en-passant. It takes about a hundred seconds to play. Currently this only will work on Microsoft Windows XP SP3 (so use Vagrant!). Like the minimalist Edlin line editor Chesster focuses on a single console line. Whites start at the bottom of the virtual chess board but SAN notation order is inverse ranks:

```
   A B C D E F G H
1  r n b q k b n r
2  p p p p p p p p
3
4
5
6
7  P P P P P P P P
8  R N B Q K B N R
```

So in order to test Chesster one can uudecode below binaries to input first algebraic notation "h7h6" characters starting game by moving the White pawn on H file from seventh rank to sixth rank. A longer example string sequence of gameplay is __"h7h6h2h3g8f6h3h4f6g4h4h5g4h2g1h3h2f1h3g5"__.

## Note

Remember if your keyboard input is not legal chess then Chesster will silently expect you to enter _again_ a conforming four ascii character string just to proceed. Thus, if only a single faulty character was entered you will need to fill-in with three more "dummy" characters before re-typing a desired algebraic notation for validation only occurs every four-chars exactly. All bugs are ofc mine.
