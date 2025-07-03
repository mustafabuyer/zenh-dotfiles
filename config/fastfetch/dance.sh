#!/bin/bash

for i in {1..5}; do
  clear
  cat ~/.config/fastfetch/frames/frame1.txt
  sleep 0.3
  clear
  cat ~/.config/fastfetch/frames/frame2.txt
  sleep 0.3
done
