Overview
========

This is an [ATS](http://zguide.zeromq.org/page:all) wrapper for the
[0MQ library](http://zeromq.org). The wrapper is low level
in that it wraps the C API and can be used in the same way. It includes
ATS types to ensure that unsafe use of the library are compile time errors.

2013-07-21: Note that the latest version of ATS includes a wrapper for
libzmq in the 'contrib' directory. At some point I'll migrate my
libzmq using libraries to that and deprecate this library.

The [0MQ Guide](http://zguide.zeromq.org/page:all) has a number of
examples in C. Some of these are converted
to ATS in the TEST subdirectory. They have the same filename as the C 
versions but with '.dats' as the file extension. I'm working on converting
the remaining guide examples, and adjusting the API as I do it.

TODO
====

Some items that remain to be done or are worth looking into:

1. Blocking 0MQ calls can be interrupted by signals, returning an
   error with the errno set to EINTR. Can this be statically ensured
   that it is checked?
2. Add zmq_poll and friends.
3. Deal with threading safely.
4. Deal with clean exit issues: http://zguide.zeromq.org/page:all#Making-a-Clean-Exit
5. Get zmq_init_data working.
6. Can zmq_copy constraint be statically checked:
   "Avoid modifying message content after a message has been copied with
    zmq_msg_copy(), doing so can result in undefined behaviour."
7. Statically ensure return values of functions are checked. Related to (1).
8. Make zmq_poll related functions safer with regards to sharing the socket object.

Build
=====

The library is best used by cloning from under a parent directory that
is used to store ATS libraries. This directory can then be passed to
the 'atscc' command line using the '-I' and '-IATS' options to be
added to the include path. In the examples below this directory is
$ATSCCLIB.

    $ cd $ATSCCLIB
    $ git clone git://githib.com/double/ats-libzmq.git libzmq
    $ cd libzmq
    $ make
    $ cd TEST
    $ make

The 'make' in the TEST directory will build the tests and delete them. Run 'make' 
on the specific tests to get the binaries to try the examples:

    $ cd TEST
    $ make hwclient hwserver
    $ ./hwserver & 
    $ ./hwclient

License
=======

Copyright (C) 2011 Chris Double.

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
