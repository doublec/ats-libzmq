(*
  Hello World server
  Binds REP socket to tcp://*:5555
  Expects "Hello" from client, replies with "World"
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/unistd.sats"
staload "prelude/SATS/string.sats"
staload "libc/SATS/string.sats"

extern castfn bytes_of_string {n:nat} (x: string n):<> [l:agz] (bytes (n) @ l, bytes (n) @ l -<lin,prf> void | ptr l)

implement main () = {
  val context = zmq_init (1)
  val () = assert_errmsg(~context, "zmq_init failed")

  (*  Socket to talk to clients *)
  val responder = zmq_socket (context, ZMQ_REP)
  val () = assert_errmsg(~responder, "zmq_socket failed")

  val _ = zmq_bind (responder, "tcp://*:5555")

  fun loop {l:agz} (r: !zmqsocket l): void = let
    (* Wait for next request from client *)
    var request: zmq_msg_t?
    val _ = zmq_msg_init (request)
    val _ = zmq_recv (r, request, 0)
    val () = print_string("Received Hello\n")
    val _ = zmq_msg_close (request)
 
    (* Do some work *)
    val _ = sleep(1)

    (* Send reply back to client *)
    var reply: zmq_msg_t?
    val s = string1_of_string ("World")
    val _ = zmq_msg_init_size (reply, string1_length (s))
    val (pf_data, fpf_data | p_data) = zmq_msg_data (reply)
    val (pf_bytes, fpf_bytes | p_bytes) = bytes_of_string (s)
    val _ = memcpy (pf_data | p_data, !p_bytes, string1_length(s))

    prval () = fpf_bytes(pf_bytes)
    prval () = fpf_data(pf_data, reply)

    val _ = zmq_send (r, reply, 0);
  in
    loop (r)
  end 

  val () = loop (responder)
  val _ = zmq_close (responder)
  val _ = zmq_term (context)
}

