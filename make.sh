#!/bin/sh
set -x
dmd -m64 frag.d
rm *.o
