(*
  Reading from multiple sockets
  This version uses zmq_poll()
*)
staload "libzmq/SATS/libzmq.sats"

fun check_revents (item: &zmq_pollitem_t, flag: int16): bool = let
  val r = uint_of_int (int_of_int16 (item.revents))
  val f = uint_of_int (int_of_int16 (flag))
in
  (r land f) <> uint_of_int (0)
end

implement main () = {
  var context = zmq_init (1)
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

  val zero = int16_of_int 0
  var !p_items = @[zmq_pollitem_t](@{socket= ptr_of_zmqsocket (receiver),   fd= 0, events= ZMQ_POLLIN, revents= zero},
                                   @{socket= ptr_of_zmqsocket (subscriber), fd= 0, events= ZMQ_POLLIN, revents= zero})
  val () = loop (!p_items) where {
             fun loop (items: &(@[zmq_pollitem_t][2])): void = {
               val r = zmq_poll (view@ items  | &items, 2, lint_of_int (~1))
               val () = assertloc (r >= 0)

               val () = let
                         fun check_poll (item: &zmq_pollitem_t, func: () -> void): void = {
                            val () = if check_revents (item, ZMQ_POLLIN) then {
                              var message: zmq_msg_t
                              val r = zmq_msg_init (message)
                              val () = assertloc (r = 0)

                              val (pff_s | s) = zmqsocket_of_ptr (item.socket)
                              val () = assertloc (~s)
                              val r = zmq_recv (s, message, 0)
                              val () = assertloc (r = 0)
                              prval () = pff_s (s)

                              val () = func ()
                              val r = zmq_msg_close (message)
                              val () = assertloc (r = 0)
                            }
                          }
                         in
                          check_poll (items.[0], lam () => print_string ("Process task\n"));
                          check_poll (items.[1], lam () => print_string ("Process weather update\n"))
                         end

               val () = loop (items)
             }
           }

  (*  We never get here *)
  val r = zmq_close (receiver)
  val () = assertloc (r = 0)

  val r = zmq_close (subscriber)
  val () = assertloc (r = 0)

  val r = zmq_term (context)
  val () = assertloc (r = 0)
}
