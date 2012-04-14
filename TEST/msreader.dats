(*
  Reading from multiple sockets
  This version uses a simple recv loop
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/unistd.sats"

implement main () = {
    (*  Prepare our context and sockets *)
    val context = zmq_init (1)
    val () = assertloc (~context)

    (*  Connect to task ventilator *)
    val receiver = zmq_socket (context, ZMQ_PULL)
    val () = assertloc (~receiver)

    val r = zmq_connect (receiver, "tcp://localhost:5557")
    val () = assertloc (r = 0)

    (*  Connect to weather server *)
    val subscriber = zmq_socket (context, ZMQ_SUB)
    val () = assertloc (~subscriber)

    val r = zmq_connect (subscriber, "tcp://localhost:5556")
    val () = assertloc (r = 0)

    val filter = "10001 "
    val r = zmq_setsockopt_string (subscriber, ZMQ_SUBSCRIBE, filter, string_length (filter))
    val () = assertloc (r = 0)

    (*  Process messages from both sockets
        We prioritize traffic from the task ventilator *)
    val () = loop (receiver, subscriber) where {
               typedef callback = {l:agz} {n:nat} (&zmq_msg_t (l, n)) -> void

               fun while_ok {l:agz} {r:zmqresult} (socket: !zmqsocket l, r: int r, f: callback): void = 
                 if r = 0 then {
                   var msg: zmq_msg_t
                   val r = zmq_msg_init (msg)
                   val () = assertloc (r = 0)
                              
                   val rc = zmq_recv (socket, msg, zmqsendrecvflag_to_int (ZMQ_NOBLOCK))
                   val () = if :(msg: [l:agz] [n:nat] zmq_msg_t (l, n)) => rc = 0 then f(msg) 
                              
                   val r = zmq_msg_close (msg)
                   val () = assertloc (r = 0)

                   val () = while_ok (socket, rc, f)
                 }
                 else ()

               fun loop {l,l2:agz} (receiver: !zmqsocket l, subscriber: !zmqsocket l2):void = {
               
                 (*  Process any waiting tasks *)
                 val () = while_ok (receiver, 0, lam (msg) => print_string ("process task\n"))

                 (*  Process any waiting weather updates *)
                 val () = while_ok (subscriber, 0, lam (msg) => print_string ("process_weather_update\n"))

                 (*  No activity, so sleep for 1 msec *)
                 val ms = max(0, min(MILLION, 1)) 
                 val _  = usleep (ms)


                 val () = loop (receiver, subscriber)
               }
             }

    (*  We never get here but clean up anyhow *)
    val r = zmq_close (receiver)
    val () = assertloc (r = 0)

    val r = zmq_close (subscriber)
    val () = assertloc (r = 0)

    val r = zmq_term (context)
    val () = assertloc (r = 0)
}
