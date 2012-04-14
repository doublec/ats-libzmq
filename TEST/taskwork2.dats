(*
  Task worker - design 2
  Adds pub-sub flow to receive and respond to kill signal
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/unistd.sats"
staload "libc/SATS/stdio.sats"
staload "prelude/SATS/unsafe.sats"

fun check_revents (item: &zmq_pollitem_t, flag: int16): bool = let
  val r = uint_of_int (int_of_int16 (item.revents))
  val f = uint_of_int (int_of_int16 (flag))
in
  (r land f) <> uint_of_int (0)
end

implement main () = {
  val context = zmq_init (1)
  val () = assertloc (~context)

  (*  Socket to receive messages on *)
  val receiver = zmq_socket (context, ZMQ_PULL)
  val () = assertloc (~receiver)

  val r = zmq_connect (receiver, "tcp://localhost:5557")
  val () = assertloc (r = 0)

  (*  Socket to send messages to *)
  val sender = zmq_socket (context, ZMQ_PUSH)
  val () = assertloc (~sender)

  val r = zmq_connect (sender, "tcp://localhost:5558")
  val () = assertloc (r = 0)

  (*  Socket for control input *)
  val controller = zmq_socket (context, ZMQ_SUB)
  val () = assertloc (~controller)

  val r = zmq_connect (controller, "tcp://localhost:5559")
  val () = assertloc (r = 0)

  val filter = ""
  val r = zmq_setsockopt_string (controller, ZMQ_SUBSCRIBE, filter, string_length (filter))
  val () = assertloc (r = 0)

  (*  Process messages from receiver and controller *)
  val zero = int16_of_int 0
  var !p_items = @[zmq_pollitem_t](@{socket= ptr_of_zmqsocket (receiver),   fd= 0, events= ZMQ_POLLIN, revents= zero},
                                   @{socket= ptr_of_zmqsocket (controller), fd= 0, events= ZMQ_POLLIN, revents= zero})
 
  (*  Process messages from both sockets *)
  val () = loop (sender, !p_items) where {
            fun loop {l:agz} (sender: !zmqsocket l, items: &(@[zmq_pollitem_t][2])): void = {
              val r = zmq_poll (view@ items  | &items, 2, lint_of_int (~1))
              val () = assertloc (r >= 0)
       
              val () = if check_revents (items.[0], ZMQ_POLLIN) then {
                         val (pff_s | s) = zmqsocket_of_ptr (items.[0].socket)
                         val () = assertloc (~s)

                         val str = s_recv (s)
                         prval () = pff_s (s)

                         (*  Do the work *)
                         val ms = int1_of (castvwtp1 {string} (str)) * 1000
                         val ms = max(0, min(MILLION, ms))
                         val _  = usleep (ms)
                         val () = strptr_free (str)

                         (* Send results to sink *)
                         val r = s_send (sender, "")
                         val () = assertloc (r = 0)

                         (*  Simple progress indicator for the viewer *)
                         val () = print (".")
                         val () = fflush_stdout ()
                       }

              (*  Any waiting controller command acts as 'KILL' *)
              val () = if check_revents (items.[1], ZMQ_POLLIN) then () else loop (sender, items)
            }
          }

  (*  Finished *)
  val r = zmq_close (receiver)
  val () = assertloc (r = 0)

  val r = zmq_close (sender)
  val () = assertloc (r = 0)
 
  val r = zmq_close (controller)
  val () = assertloc (r = 0)

  val r = zmq_term (context)
  val () = assertloc (r = 0)
}
