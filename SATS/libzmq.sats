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
%{#
#include "contrib/libzmq/CATS/libzmq.cats"
%}

#define ATS_STALOADFLAG 0 // no need for staloading at run-time

(* ZMQ functions return 0 on success, -1 on error *)
sortdef zmqresult = {a:int | a == 0 || a == ~1}

abst@ype zmqversiontype = $extype "int"
macdef ZMQ_VERSION_MAJOR = $extval (zmqversiontype, "ZMQ_VERSION_MAJOR")
macdef ZMQ_VERSION_MINOR = $extval (zmqversiontype, "ZMQ_VERSION_MINOR")
macdef ZMQ_VERSION_PATCH = $extval (zmqversiontype, "ZMQ_VERSION_PATCH")

fun zmq_version (major: &int? >> int, minor: &int? >> int, patch: &int? >> int): void = "mac#zmq_version"

#define ZMQ_MAX_VSM_SIZE 30

absviewtype zmq_msg_content_vt (l:addr, n:int)

viewtypedef zmq_msg_t (l:addr, n:int) = $extype_struct "zmq_msg_t" of {
  p_content= zmq_msg_content_vt(l, n),
  flags= uchar,
  vsm_size = char,
  vsm_data = @[uchar][ZMQ_MAX_VSM_SIZE]
}
viewtypedef zmq_msg_t = zmq_msg_t (null, 0)
(*
TODO: get this and zmq_init_data working
typedef zmq_free_fn = {l:agz} {l2:addr} (data: ptr l, hint: ptr l2) -> void
*)

fun zmq_msg_init (msg: &zmq_msg_t (null, 0)? >> zmq_msg_t (l, 0)): #[l:agz] [r:zmqresult] int r = "mac#zmq_msg_init"
fun zmq_msg_init_size {n:nat} (msg: &zmq_msg_t (null, 0)? >> zmq_msg_t (l, n), size: size_t n): #[l:agz] [r:zmqresult] int r = "mac#zmq_msg_init_size"

(*
TODO: 
ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
    size_t size, zmq_free_fn *ffn, void *hint);
*)

fun zmq_msg_close {n:nat} {l:agz} (msg: &zmq_msg_t (l, n) >> zmq_msg_t (null, 0)?): [r:zmqresult] int r = "mac#zmq_msg_close"
fun zmq_msg_move {n,n2:nat} {l,l2:agz} (dest: &zmq_msg_t (l, n) >> zmq_msg_t (l2, n2),
                                        src: &zmq_msg_t (l2, n2) >> zmq_msg_t (l3, 0)): #[l3:agz] [r:zmqresult] int r = "mac#zmq_msg_move"

(* TODO: How to express the constraint from http://api.zeromq.org/2-1:zmq-msg-copy:
         "Avoid modifying message content after a message has been copied with zmq_msg_copy(), doing so can result in undefined behaviour. "
*)
fun zmq_msg_copy {n,n2:nat} {l,l2:agz} (dest: &zmq_msg_t (l, n) >> zmq_msg_t (l2, n2),
                                        src: zmq_msg_t (l2, n2)): [r:zmqresult] int r = "mac#zmq_msg_copy"

(* The returned pointer is internal to the 'msg' object. The returned proof function takes the
   'msg' as a parameter to ensure that it cannot be destroyed while the data pointer is still active.
*)
fun zmq_msg_data {n:nat} {l:agz} (msg: &zmq_msg_t (l, n)): (bytes n @ l, (bytes n @ l, !zmq_msg_t (l, n)) -<lin,prf> void | ptr l) = "mac#zmq_msg_data" 

fun zmq_msg_size {n:nat} {l:agz} (msg: &zmq_msg_t (l, n) >> zmq_msg_t (l, n)): size_t n = "mac#zmq_msg_size"

abst@ype zmqsockettype = $extype "int"
macdef ZMQ_PAIR = $extval (zmqsockettype, "ZMQ_PAIR")
macdef ZMQ_PUB = $extval (zmqsockettype, "ZMQ_PUB")
macdef ZMQ_SUB = $extval (zmqsockettype, "ZMQ_SUB")
macdef ZMQ_REQ = $extval (zmqsockettype, "ZMQ_REQ")
macdef ZMQ_REP = $extval (zmqsockettype, "ZMQ_REP")
macdef ZMQ_DEALER = $extval (zmqsockettype, "ZMQ_DEALER")
macdef ZMQ_ROUTER = $extval (zmqsockettype, "ZMQ_ROUTER")
macdef ZMQ_PULL = $extval (zmqsockettype, "ZMQ_PULL")
macdef ZMQ_PUSH = $extval (zmqsockettype, "ZMQ_PUSH")
macdef ZMQ_XPUB = $extval (zmqsockettype, "ZMQ_XPUB")
macdef ZMQ_XSUB = $extval (zmqsockettype, "ZMQ_XSUB")

abst@ype zmqsocketoption = $extype "int"
macdef ZMQ_HWM = $extval (zmqsocketoption, "ZMQ_HWM")
macdef ZMQ_SWAP = $extval (zmqsocketoption, "ZMQ_SWAP")
macdef ZMQ_AFFINITY = $extval (zmqsocketoption, "ZMQ_AFFINITY")
macdef ZMQ_IDENTITY = $extval (zmqsocketoption, "ZMQ_IDENTITY")
macdef ZMQ_SUBSCRIBE = $extval (zmqsocketoption, "ZMQ_SUBSCRIBE")
macdef ZMQ_UNSUBSCRIBE = $extval (zmqsocketoption, "ZMQ_UNSUBSCRIBE")
macdef ZMQ_RATE = $extval (zmqsocketoption, "ZMQ_RATE")
macdef ZMQ_RECOVERY_IVL = $extval (zmqsocketoption, "ZMQ_RECOVERY_IVL")
macdef ZMQ_MCAST_LOOP = $extval (zmqsocketoption, "ZMQ_MCAST_LOOP")
macdef ZMQ_SNDBUF = $extval (zmqsocketoption, "ZMQ_SNDBUF")
macdef ZMQ_RCVBUF = $extval (zmqsocketoption, "ZMQ_RCVBUF")
macdef ZMQ_RCVMORE = $extval (zmqsocketoption, "ZMQ_RCVMORE")
macdef ZMQ_FD = $extval (zmqsocketoption, "ZMQ_FD")
macdef ZMQ_EVENTS = $extval (zmqsocketoption, "ZMQ_EVENTS")
macdef ZMQ_TYPE = $extval (zmqsocketoption, "ZMQ_TYPE")
macdef ZMQ_LINGER = $extval (zmqsocketoption, "ZMQ_LINGER")
macdef ZMQ_RECONNECT_IVL = $extval (zmqsocketoption, "ZMQ_RECONNECT_IVL")
macdef ZMQ_BACKLOG = $extval (zmqsocketoption, "ZMQ_BACKLOG")
macdef ZMQ_RECOVERY_IVL_MSEC = $extval (zmqsocketoption, "ZMQ_RECOVERY_IVL_MSEC")
macdef ZMQ_RECOVERY_IVL_MAX = $extval (zmqsocketoption, "ZMQ_RECOVERY_IVL_MAX")
 
abst@ype zmqsendrecvflag = $extype "int"
macdef ZMQ_NOBLOCK = $extval (zmqsendrecvflag, "ZMQ_NOBLOCK")
macdef ZMQ_SNDMORE = $extval (zmqsendrecvflag, "ZMQ_SNDMORE")

castfn zmqsendrecvflag_to_int (f: zmqsendrecvflag): int 

absviewtype zmqcontext (l:addr)
fun zmqcontext_null () :<> zmqcontext (null) = "mac#atspre_null_ptr"
fun zmqcontext_is_null {l:addr} (p: !zmqcontext l):<> bool (l==null) = "mac#atspre_ptr_is_null"
fun zmqcontext_isnot_null {l:addr} (p: !zmqcontext l):<> bool (l > null) = "mac#atspre_ptr_isnot_null"
castfn zmqcontext_free_null (p: zmqcontext null):<> ptr null
overload ~ with zmqcontext_isnot_null

fun zmq_init {n:nat} (io_threads: int n): [l:addr] zmqcontext l = "mac#zmq_init"

(* TODO: Is it possible to encode this constraint from the 0MQ programming guide:
   "...if you have any outgoing messages or connects waiting on a socket, 2.1 will
    by default wait forever trying to deliver these. You must set the LINGER socket
    option (e.g. to zero), on every socket which may still be busy, before calling zmq_term:

      int zero = 0;
      zmq_setsockopt (mysocket, ZMQ_LINGER, &zero, sizeof (zero));
   "
*)
fun zmq_term {l:agz} (context: zmqcontext l): int = "mac#zmq_term"

absviewtype zmqsocket (l:addr)
fun zmqsocket_null () :<> zmqsocket (null) = "mac#atspre_null_ptr"
fun zmqsocket_is_null {l:addr} (p: !zmqsocket l):<> bool (l==null) = "mac#atspre_ptr_is_null"
fun zmqsocket_isnot_null {l:addr} (p: !zmqsocket l):<> bool (l > null) = "mac#atspre_ptr_isnot_null"
castfn zmqsocket_free_null (p: zmqsocket null):<> ptr null
overload ~ with zmqsocket_isnot_null

fun zmq_socket {l:agz} (context: !zmqcontext l, type: zmqsockettype): [l2:addr] zmqsocket l2 = "mac#zmq_socket"
fun zmq_close {l:agz} (socket: zmqsocket l): int = "mac#zmq_close"
fun zmq_setsockopt {l:agz} {l2:addr} (socket: !zmqsocket l, option_name: zmqsocketoption, option_value: ptr l2, option_len: size_t): int = "mac#zmq_setsockopt"
fun zmq_getsockopt {l,l2:agz} {n:nat} (socket: !zmqsocket l, option_name: zmqsocketoption, option_value: ptr l2, option_len: size_t n): int = "mac#zmq_getsockopt"
fun zmq_bind {l:agz} (socket: !zmqsocket l, endpoint: string): int = "mac#zmq_bind"
fun zmq_connect {l:agz} (socket: !zmqsocket l, endpoint: string): int = "mac#zmq_connect"

fun zmq_send {l,l2:agz} {n:nat} (socket: !zmqsocket l, msg: &zmq_msg_t (l2, n) >> zmq_msg_t (l3, 0), flags: int): #[l3:agz] [r:zmqresult] int r = "mac#zmq_send"

fun zmq_recv {l,l2:agz} {n:nat} (socket: !zmqsocket l, msg: &zmq_msg_t (l2, n) >> zmq_msg_t (l3, n2), flags: int): #[l3:agz] #[n2:nat] [r:zmqresult] int r = "mac#zmq_recv"

(* Higher level helper functions *)
castfn bytes_of_string {n:nat} (x: string n):<> [l:agz] (bytes (n) @ l, bytes (n) @ l -<lin,prf> void | ptr l)

fun s_send {l:agz} (socket: !zmqsocket l, s: string): int
fun s_recv {l:agz} (socket: !zmqsocket l): [l2:agz] strptr l2

