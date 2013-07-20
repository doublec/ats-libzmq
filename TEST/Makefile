######

ATSHOMEQ="$(ATSHOME)"
ATSCC=$(ATSHOMEQ)/bin/atscc
ATSCCLIB=$(shell pwd)/../..
ATSCTRB=\
  $(ATSCCLIB)/libzmq/atsctrb_libzmq.o
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
  mspoller \
  taskwork2 \
  tasksink2

######

hwserver: hwserver.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

hwclient: hwclient.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

version: version.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

wuserver: wuserver.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

wuclient: wuclient.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

taskvent: taskvent.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

taskwork: taskwork.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

tasksink: tasksink.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

msreader: msreader.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

mspoller: mspoller.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

taskwork2: taskwork2.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

tasksink2: tasksink2.dats
	$(ATSCC) -I$(ATSCCLIB) -IATS$(ATSCCLIB) $(CFLAGS) -o $@ $< $(ATSCTRB) $(LIBS)

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
	rm -f taskwork2
	rm -f tasksink2

###### end of [Makefile] ######
