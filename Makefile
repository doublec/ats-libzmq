#
# API for zeromq in ATS
#
# Author: Chris Double (chris DOT double AT double DOT co DOT nz)
# Time: October, 2011
#

######

ATSHOMEQ="$(ATSHOME)"
ATSCC=$(ATSHOMEQ)/bin/atscc -Wall
JANSSONCFLAGS=`pkg-config libzmq --cflags`

######

all: atsctrb_libzmq.o clean

######

atsctrb_libzmq.o: libzmq_dats.o
	ld -r -o $@ $<

######

libzmq_dats.o: DATS/libzmq.dats
	$(ATSCC) $(XRCFLAGS) -o $@ -c $<

######

clean::
	rm -f *_?ats.c *_?ats.o

cleanall: clean
	rm -f atsctrb_libzmq.o

###### end of [Makefile] ######
