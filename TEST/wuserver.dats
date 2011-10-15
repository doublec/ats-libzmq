(*
  Weather update server
  Binds PUB socket to tcp://*:5556
  Publishes random weather updates
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/random.sats"
staload "libc/SATS/string.sats"
staload "prelude/SATS/unsafe.sats"

extern castfn bytes_of_string {n:nat} (x: string n):<> [l:agz] (bytes (n) @ l, bytes (n) @ l -<lin,prf> void | ptr l)
 
fun s_send {l:agz} (socket: !zmqsocket l, s: string): int = let
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

implement main () = {
  (* Prepare our context and publisher *)
  val context = zmq_init (1)
  val () = assert_errmsg(~context, "zmq_init failed")

  val publisher = zmq_socket (context, ZMQ_PUB)
  val () = assert_errmsg(~publisher, "zmq_socket failed")

  val _ = zmq_bind (publisher, "tcp://*:5556")
  val _ = zmq_bind (publisher, "ipc://weather.ipc")

  (*  Initialize random number generator *)
  (* srandom ((unsigned) time (NULL)); *)

  fun loop {l:agz} (p: !zmqsocket l): void = let
    (*  Get values that will fool the boss *)
    val zipcode = randint (100000)
    val temperature = randint (215) - 80
    val relhumidity = randint (50) + 10

    (* Send message to all subscribers *)
    val update = sprintf ("%05d %d %d", @(zipcode, temperature, relhumidity));
    val r = s_send (p, castvwtp1 {string} (update));
    val () = strptr_free (update)
  in
    loop (p)
  end

  val () = loop (publisher)
  val _ = zmq_close (publisher)
  val _ = zmq_term (context)
}
