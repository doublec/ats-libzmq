(*
  Reading from multiple sockets
  This version uses zmq_poll()
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "prelude/SATS/array.sats"
staload "prelude/DATS/array.dats"

%{^
int check_revents(zmq_pollitem_t* pi, int flag) {
  return pi->revents & flag;
}
%}

extern fun check_revents {l:agz} (pf_item: !zmq_pollitem_t @ l | p_item: ptr l, flag: int): bool = "mac#check_revents"

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

  var !p_items with pf_items = @[zmq_pollitem_t?][2]()
  prval (pf_car, pf_cdr) = array_v_uncons {zmq_pollitem_t?} (pf_items)
  val () = zmq_pollitem_init (pf_car | p_items, receiver, 0, ZMQ_POLLIN)

  prval (pf_cadr, pf_cddr) = array_v_uncons {zmq_pollitem_t?} (pf_cdr)
  val () = zmq_pollitem_init (pf_cadr | p_items + sizeof<zmq_pollitem_t?>, subscriber, 0, ZMQ_POLLIN)

  prval () = array_v_unnil {zmq_pollitem_t?} (pf_cddr)
  prval () = pf_cddr := array_v_nil {zmq_pollitem_t} ()

  prval () = pf_items := array_v_cons (pf_car, array_v_cons (pf_cadr, pf_cddr))
 
  val () = loop (pf_items | p_items) where {
             fun loop {l:agz} (pf_items: !array_v (zmq_pollitem_t, 2, l) | p_items: ptr l): void = {
               val r = zmq_poll (pf_items  | p_items, 2, lint_of_int (~1))
               val () = assertloc (r >= 0)

               prval (pf_car, pf_cdr) = array_v_uncons {zmq_pollitem_t} (pf_items)
               val () = if :(pf_car: zmq_pollitem_t @ l) => check_revents (pf_car | p_items, ZMQ_POLLIN) then {
                          var message: zmq_msg_t
                          val r = zmq_msg_init (message)
                          val () = assertloc (r = 0)

                          val () = assertloc (~p_items->socket)
                          val r = zmq_recv (p_items->socket, message, 0)
                          val () = assertloc (r = 0)

                          val () = print_string ("Process task\n")
                          val r = zmq_msg_close (message)
                          val () = assertloc (r = 0)
                        }

               prval (pf_cadr, pf_cddr) = array_v_uncons {zmq_pollitem_t} (pf_cdr)
               val p_item2 = p_items + sizeof<zmq_pollitem_t>
               val () = if :(pf_cadr: zmq_pollitem_t @ (l + sizeof zmq_pollitem_t)) => check_revents (pf_cadr | p_item2, ZMQ_POLLIN) then {
                          var message: zmq_msg_t
                          val r = zmq_msg_init (message)
                          val () = assertloc (r = 0)
 
                           val () = assertloc (~p_item2->socket)
                          val r = zmq_recv (p_item2->socket, message, 0)
                          val () = assertloc (r = 0)

                          val () = print_string ("Process weather update\n")
                          val r = zmq_msg_close (message)
                          val () = assertloc (r = 0)
                        }
               prval () = pf_items := array_v_cons (pf_car, array_v_cons (pf_cadr, pf_cddr))
               val () = loop (pf_items | p_items)
             }
           }

  (*  We never get here *)
  prval (pf_car, pf_cdr) = array_v_uncons {zmq_pollitem_t} (pf_items)
  val () = assertloc (~p_items->socket)
  val r = zmq_close (p_items->socket)
  val () = assertloc (r = 0)

  prval (pf_cadr, pf_cddr) = array_v_uncons {zmq_pollitem_t} (pf_cdr)
  val () = assertloc (~(p_items+sizeof<zmq_pollitem_t>)->socket)
  val r = zmq_close ((p_items+sizeof<zmq_pollitem_t>)->socket)
  val () = assertloc (r = 0)

  prval () = array_v_unnil {zmq_pollitem_t} (pf_cddr)
  prval () = pf_cddr := array_v_nil {zmq_pollitem_t?} ()

  prval () = pf_items := array_v_cons (pf_car, array_v_cons (pf_cadr, pf_cddr))
 
  val r = zmq_term (context)
  val () = assertloc (r = 0)
}
