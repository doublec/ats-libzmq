(*
  Weather update server
  Binds PUB socket to tcp://*:5556
  Publishes random weather updates
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/random.sats"
staload "prelude/SATS/unsafe.sats"

implement main () = {
  (* Prepare our context and publisher *)
  val context = zmq_init (1)
  val () = assertloc (~context)

  val publisher = zmq_socket (context, ZMQ_PUB)
  val () = assertloc (~publisher)

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
