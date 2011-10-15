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
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/string.sats"

#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time

extern castfn strptr_of_string {n:nat} (x: string n):<> [l:agz] strptr l

implement s_send (socket, s) = let
  var message: zmq_msg_t?
  val s = string1_of_string (s)
  val size = string1_length (s)
  val _ = zmq_msg_init_size (message, size)
  val (pf_data, fpf_data | p_data) = zmq_msg_data (message)
  val (pf_bytes, fpf_bytes | p_bytes) = bytes_of_string (s)
  val _ = memcpy (pf_data | p_data, !p_bytes, size)
  prval () = fpf_data (pf_data, message)
  prval () = fpf_bytes (pf_bytes)
  val r = zmq_send (socket, message, 0)
in
  r
end

implement s_recv (socket) = let
  var message: zmq_msg_t?
  val _ = zmq_msg_init (message)
  val r = zmq_recv (socket, message, 0)
  val () = assert_errmsg(r = 0, "zmq_recv failed")

  val size = zmq_msg_size (message)
  val (pf_data, fpf_data | p_data) = zmq_msg_data (message)

  val str = string_make_char (size, 'X')
  val str = string_of_strbuf (str)
  val (pf_bytes, fpf_bytes | p_bytes) = bytes_of_string (str)

  val _ = memcpy (pf_bytes | p_bytes, !p_data, size)

  prval () = fpf_data (pf_data, message)
  prval () = fpf_bytes (pf_bytes)

  val _ = zmq_msg_close (message)
in
  strptr_of_string (str) 
end


