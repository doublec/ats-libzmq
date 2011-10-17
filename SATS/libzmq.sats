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

abst@ype zmq_msg_t = $extype "zmq_msg_t"

(* Proof returned by zmq_msg_init functions to ensure that zmq_close is called on an
   initialized message

   zmq_msg_v has the size, 'n', and the internal data pointer, 'data' as parameters.
   The former is used to ensure that access to the internal data is correctly bounded
   by the size. The latter is 'null' until 'zmq_msg_data' is called. In this case it
   is the address of the internal data. It is reset back to 'null' when the internal data
   pointer is no longer needed. The ensures that dangling references to the data pointer
   aren't kept around when zmq functions that can free the data are called (zmq_send,
   zmq_recv, etc).
*)

absview zmq_msg_v (l:addr, n:int, data:addr) 

(*
TODO: get this and zmq_init_data working
typedef zmq_free_fn = {l:agz} {l2:addr} (data: ptr l, hint: ptr l2) -> void
*)

fun zmq_msg_init {l:agz} (pf_msg: !zmq_msg_t? @ l >> zmq_msg_v (l, 0, null) | msg: ptr l): [r:zmqresult] int r = "mac#zmq_msg_init"
fun zmq_msg_init_size {n:nat} {l:agz} (pf_msg: !zmq_msg_t? @ l >> zmq_msg_v (l, n, null) | msg: ptr l, size: size_t n): [r:zmqresult] int r = "mac#zmq_msg_init_size"

(*
TODO: 
ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
    size_t size, zmq_free_fn *ffn, void *hint);
*)

fun zmq_msg_close {n:nat} {l:agz} (pf_msg: !zmq_msg_v (l, n, null) >> zmq_msg_t? @ l | msg: ptr l): [r:zmqresult] int r = "mac#zmq_msg_close"

fun zmq_msg_move {n,n2:nat} {l,l2:agz} (pf_dest: !zmq_msg_v (l, n, null) >> zmq_msg_v (l, n2, null),
                                        pf_src: !zmq_msg_v (l2, n2, null) >> zmq_msg_v (l2, 0, null)
                                      | dest: ptr l, src: ptr l2): [r:zmqresult] int r = "mac#zmq_msg_move"

(* TODO: How to express the constraint from http://api.zeromq.org/2-1:zmq-msg-copy:
         "Avoid modifying message content after a message has been copied with zmq_msg_copy(), doing so can result in undefined behaviour. "
*)
fun zmq_msg_copy {n,n2:nat} {l,l2:agz} (pf_dest: !zmq_msg_v (l, n, null) >> zmq_msg_v (l, n2, null),
                                        pf_src: !zmq_msg_v (l2, n2, null)
                                      | dest: ptr l, src: ptr l2): [r:zmqresult] int r = "mac#zmq_msg_copy"

(* The returned pointer is internal to the 'msg' object. The returned proof function takes
   'pf_msg' as a parameter to ensure that it cannot be destroyed while the data pointer
   is still active.
*)
fun zmq_msg_data {n:nat} {l:agz} (pf_msg: !zmq_msg_v (l, n, null) >> zmq_msg_v (l, n, l2) | msg: ptr l): 
                                #[l2:agz] (bytes n @ l2, (bytes n @ l2, !zmq_msg_v (l, n, l2) >> zmq_msg_v (l, n, null)) -<lin,prf> void | ptr l2) = "mac#zmq_msg_data"

(*
TODO: msg_data call for when we've already got an active zmq_msg_data result. Not sure how to combine this and zmq_msg_data
fun zmq_msg_data_notnull {n:nat} {l:addr | l <> null} (msg: &zmq_msg_t (n,l) >> zmq_msg_t (n,l)): (bytes n @ l, (bytes n @ l, zmq_msg_t (n,l)) -<lin,prf> void | ptr l) = "mac#zmq_msg_data"
*)

fun zmq_msg_size {n:nat} {l:agz} {l2:addr} (pf_msg: !zmq_msg_v (l, n,l2) >> zmq_msg_v (l, n2,l2) | msg: ptr l): #[n2:nat] size_t n2 = "mac#zmq_msg_size"

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

fun zmq_send {l,l2:agz} {n:nat} (pf_msg: !zmq_msg_v (l2, n, null) >> zmq_msg_v (l2, 0, null)
                               | socket: !zmqsocket l, msg: ptr l2, flags: int): [r:zmqresult] int r = "mac#zmq_send"

(* TODO: Another use of 'opt' being problematic. On failure the type returned by 'opt' is uninitialized, whereas it needs to
         be the original type to allow retrying. *)
fun zmq_recv {l,l2:agz} {n:nat} (pf_msg: !zmq_msg_v (l2, n, null) >> zmq_msg_v (l2, n2, null)
                               | socket: !zmqsocket l, msg: ptr l2, flags: int): #[n2:nat] [r:zmqresult] int r = "mac#zmq_recv"

(* Higher level helper functions *)
castfn bytes_of_string {n:nat} (x: string n):<> [l:agz] (bytes (n) @ l, bytes (n) @ l -<lin,prf> void | ptr l)

fun s_send {l:agz} (socket: !zmqsocket l, s: string): int
fun s_recv {l:agz} (socket: !zmqsocket l): [l2:agz] strptr l2

