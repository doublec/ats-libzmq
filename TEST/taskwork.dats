(*
  Task worker
  Connects PULL socket to tcp://localhost:5557
  Collects workloads from ventilator via that socket
  Connects PUSH socket to tcp://localhost:5558
  Sends results to sink via that socket
*)
staload "libzmq/SATS/libzmq.sats"
staload "libc/SATS/unistd.sats"
staload "libc/SATS/stdio.sats"
staload "prelude/SATS/unsafe.sats"

implement main () = {
  val context = zmq_init (1)
  val () = assertloc (~context)

  (*  Socket to receive messages on *)
  val receiver = zmq_socket (context, ZMQ_PULL)
  val () = assertloc (~receiver)
  val _ = zmq_connect (receiver, "tcp://localhost:5557")

  (*  Socket to send messages to *)
  val sender = zmq_socket (context, ZMQ_PUSH)
  val () = assertloc (~sender)
  val _ = zmq_connect (sender, "tcp://localhost:5558")

  (*  Process tasks forever *)
  fun loop {l,l2:agz} (receiver: !zmqsocket l, sender: !zmqsocket l2): void = let
    val str = s_recv (receiver)

    (*  Simple progress indicator for the viewer *)
    val () = fflush_stdout ()
    val () = print (str)
    val () = print (".")

    (*  Do the work *)
    val ms = int1_of (castvwtp1 {string} (str)) * 1000
    val ms = max(0, min(MILLION, ms))
    val _ =  usleep (ms)
    val () = strptr_free (str)

    (*  Send results to sink *)
    val _  = s_send (sender, "")
  in
    loop (receiver, sender)
  end

  val () = loop (receiver, sender)
    
  val _ = zmq_close (receiver)
  val _ = zmq_close (sender)
  val _ = zmq_term (context)
}
