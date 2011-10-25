(*
  Reading from multiple sockets
  This version uses a simple recv loop
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/unistd.sats"

extern castfn ptr_of_string (x: string):<> [l:agz] ptr l

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
    val r = zmq_setsockopt (subscriber, ZMQ_SUBSCRIBE, ptr_of_string (filter), string_length (filter))
    val () = assertloc (r = 0)

    (*  Process messages from both sockets
        We prioritize traffic from the task ventilator *)
    val () = loop (receiver, subscriber) where {
               fun {l,l2:agz} loop (receiver: !zmqsocket l, subscriber: !zmqsocket l2):void = {
                 (*  Process any waiting tasks *)
                 val () = while_ok (receiver, 0) where {
                            fun while_ok {l:agz} {r:zmqresult} (receiver: !zmqsocket l, r: int r): void = 
                              if r = 0 then {
                                var task: zmq_msg_t
                                val r = zmq_msg_init (task)
                                val () = assertloc (r = 0)
                              
                                val rc = zmq_recv (receiver, task, zmqsendrecvflag_to_int (ZMQ_NOBLOCK))
                                val () = if rc = 0 then printf("process task\n", @())
                              
                                val r = zmq_msg_close (task)
                                val () = assertloc (r = 0)

                                val () = while_ok (receiver, rc)
                              }
                              else ()
                          }

                 (*  Process any waiting weather updates *)
                 val () = while_ok (subscriber, 0) where {
                            fun while_ok {l:agz} {r:zmqresult} (subscriber: !zmqsocket l, r: int r): void = 
                              if r = 0 then {
                                var update: zmq_msg_t
                                val r = zmq_msg_init (update)
                                val () = assertloc (r = 0)
                              
                                val rc = zmq_recv (subscriber, update, zmqsendrecvflag_to_int (ZMQ_NOBLOCK))
                                val () = if rc = 0 then printf("process weather update\n", @())
                              
                                val r = zmq_msg_close (update)
                                val () = assertloc (r = 0)

                                val () = while_ok (subscriber, rc)
                              }
                              else ()
                          }

                 (*  No activity, so sleep for 1 msec *)
                 val ms = int1_of (1)
                 val ms = max(0, min(MILLION, ms))
                 val () = usleep (ms)


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
