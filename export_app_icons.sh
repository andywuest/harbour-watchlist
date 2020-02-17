!/bin/bash

for x in 86 108 128 172
do
  inkscape --export-png icons/${x}x${x}/harbour-watchlist_original.png -w ${x} mediasrc/harbour-watchlist.svg
  pngcrush -brute icons/${x}x${x}/harbour-watchlist_original.png icons/${x}x${x}/harbour-watchlist.png
done
