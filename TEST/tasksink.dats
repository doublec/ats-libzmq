(*
  Task sink
  Binds PULL socket to tcp://localhost:5558
  Collects results from workers via that socket
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/sys/SATS/time.sats"
staload "libc/sys/SATS/types.sats"
staload "libc/SATS/stdio.sats"

fun s_clock (): double = let
  var tv: timeval?
  val r = gettimeofday (tv)
  val () = assertloc (r = 0)
  prval () = opt_unsome {timeval} (tv)
in
  double_of (lint_of (tv.tv_sec) * 1000L + lint_of(tv.tv_usec) / 1000L)
end

implement main () = { 
    (*  Prepare our context and socket *)
    val context = zmq_init (1)
    val () = assertloc (~context)

    val receiver = zmq_socket (context, ZMQ_PULL)
    val () = assertloc (~receiver)

    val _ = zmq_bind (receiver, "tcp://*:5558")

    (*  Wait for start of batch *)
    val str = s_recv (receiver)
    val () = strptr_free (str)

    (*  Start our clock now *)
    val start_time = s_clock ()

    (*  Process 100 confirmations *)
    val () = loop (receiver, 0, 100) where {
               fun loop {l:agz} {n,m:nat | n <= m} .< m-n >. (receiver: !zmqsocket l, n: int n, max: int m): void = 
                 if n = max then
                   ()
                 else let
                   val str = s_recv (receiver)
                   val () = strptr_free (str)

                   val () = print_string (if n mod 10 = 0 then ":" else ".")
                   val () = fflush_stdout ()
                 in 
                   loop (receiver, n + 1, max)
                 end 
             }

    (*  Calculate and report duration of batch *)
    val end_time = s_clock ()
    val () = printf ("Total elapsed time: %f msec\n", @(end_time - start_time));
    val _ = zmq_close (receiver)
    val _ = zmq_term (context)
}
