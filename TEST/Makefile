######

ATSHOMEQ="$(ATSHOME)"
ATSCC=$(ATSHOMEQ)/bin/atscc
ATSCTRB=\
  $(ATSHOMEQ)/contrib/libzmq/atsctrb_libzmq.o
LIBZMQCFLAGS=`pkg-config libzmq --cflags`
LIBZMQLIBS=`pkg-config libzmq --libs`
######

checkall: compall cleanall

######

compall: \
  hwserver \
  hwclient \
  version \
  wuserver

######

hwserver: hwserver.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

hwclient: hwclient.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

version: version.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

wuserver: wuserver.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)


######

clean:
	rm -f *_?ats.c *.o *~

cleanall: clean
	rm -f hwserver
	rm -f hwclient
	rm -f version
	rm -f wuserver


###### end of [Makefile] ######
