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
  wuserver \
  wuclient \
  taskvent \
  taskwork \
  tasksink

######

hwserver: hwserver.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

hwclient: hwclient.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

version: version.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

wuserver: wuserver.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

wuclient: wuclient.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

taskvent: taskvent.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

taskwork: taskwork.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

tasksink: tasksink.dats
	$(ATSCC) $(LIBZMQCFLAGS) -o $@ $< $(ATSCTRB) $(LIBZMQLIBS)

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

###### end of [Makefile] ######
