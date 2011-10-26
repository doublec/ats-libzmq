######

ATSHOMEQ="$(ATSHOME)"
ATSCC=$(ATSHOMEQ)/bin/atscc
ATSCTRB=\
  $(ATSHOMEQ)/contrib/libzmq/atsctrb_libzmq.o
CFLAGS=`pkg-config libzmq --cflags`
LIBS=`pkg-config libzmq --libs`
######

checkall: compall cleanall

######

compall: \
  hwserver \
  hwclient \
  version \
  wuserver \
  wuclient \
  taskvent \
  taskwork \
  tasksink \
  msreader \
  mspoller

######

hwserver: hwserver.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

hwclient: hwclient.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

version: version.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

wuserver: wuserver.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

wuclient: wuclient.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

taskvent: taskvent.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

taskwork: taskwork.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

tasksink: tasksink.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

msreader: msreader.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

mspoller: mspoller.dats
	$(ATSCC) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

######

clean:
	rm -f *_?ats.c *.o *~

cleanall: clean
	rm -f hwserver
	rm -f hwclient
	rm -f version
	rm -f wuserver
	rm -f wuclient
	rm -f taskvent
	rm -f taskwork
	rm -f tasksink
	rm -f msreader
	rm -f mspoller

###### end of [Makefile] ######
