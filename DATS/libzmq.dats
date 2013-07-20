(*
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
*)
staload "libzmq/SATS/libzmq.sats"
staload "libc/SATS/string.sats"

#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time

implement s_send (socket, s) = let
  var message: zmq_msg_t
  val s = string1_of_string (s)
  val size = string1_length (s)

  val r = zmq_msg_init_size (message, size)
  val () = assertloc (r = 0)

  val (pf_data, fpf_data | p_data) = zmq_msg_data (message)
  val (pf_bytes, fpf_bytes | p_bytes) = bytes_of_string (s)
  val _ = memcpy (pf_data | p_data, !p_bytes, size)
  prval () = fpf_data (pf_data, message)
  prval () = fpf_bytes (pf_bytes)

  val result = zmq_send (socket, message, 0)
  val r = zmq_msg_close (message)
  val () = assertloc (r = 0)
in
  result
end

implement s_recv (socket) = let
  var message: zmq_msg_t
  val r = zmq_msg_init (message)
  val () = assertloc (r = 0)

  val r = zmq_recv (socket, message, 0)
  val () = assertloc (r = 0)

  val size = zmq_msg_size (message)
  val (pf_data, fpf_data | p_data) = zmq_msg_data (message)

  val (pfgc, pf_bytes | p_bytes) = malloc_gc (size+1)
  prval pf_bytes = bytes_v_of_b0ytes_v (pf_bytes)
  val _ = memcpy (pf_bytes | p_bytes, !p_data, size)
  val () = bytes_strbuf_trans (pf_bytes | p_bytes, size)
  prval () = fpf_data (pf_data, message)

  val r = zmq_msg_close (message)
  val () = assertloc (r = 0)
in
  strptr_of_strbuf @(pfgc, pf_bytes | p_bytes)
end


