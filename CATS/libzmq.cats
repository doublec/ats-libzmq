/*
** Copyright (C) 2011 Chris Double.
**
** Permission to use, copy, modify, and distribute this software for any
** purpose with or without fee is hereby granted, provided that the above
** copyright notice and this permission notice appear in all copies.
** 
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
** WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
** ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
** WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
** ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/
#ifndef ATSCTRB_LIBZMQ_CATS
#define ATSCTRB_LIBZMQ_CATS

#include <zmq.h>

// Helper function to make it easier to initialize zmq_pollitem_t objects from ATS.
// Exposed as zmq_pollitem_init to ATS code.
ATSinline()
void ats_pollitem_init (zmq_pollitem_t* pi, void* socket, int fd, int events) {
  pi->socket = socket;
  pi->fd = fd;
  pi->events = events;
  pi->revents = 0;
}

#endif


