#
# API for zeromq in ATS
#
# Author: Chris Double (chris DOT double AT double DOT co DOT nz)
# Time: October, 2011
#

######
REMOTE=http://github.com/doublec/ats-libzmq
ATSHOMEQ="$(ATSHOME)"
ATSCC=$(ATSHOMEQ)/bin/atscc -Wall
JANSSONCFLAGS=`pkg-config libzmq --cflags`

######

all: .git atsctrb_libzmq.o clean

######

.git:
	rm Makefile && git clone $(REMOTE) .

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

cleangit: .git
	rm -r * && git checkout Makefile && rm -rf .git .gitignore

###### end of [Makefile] ######
