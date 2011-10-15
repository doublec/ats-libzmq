(*
  Task ventilator
  Binds PUSH socket to tcp://localhost:5557
  Sends batch of tasks to workers via that socket
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "libc/SATS/stdio.sats"
staload "libc/SATS/random.sats"
staload "libc/SATS/unistd.sats"
staload "prelude/SATS/unsafe.sats"

implement main () = {
  val context = zmq_init (1)
  val () = assert_errmsg (~context, #LOCATION)

  (*  Socket to send messages on *)
  val sender = zmq_socket (context, ZMQ_PUSH)
  val () = assert_errmsg (~sender, #LOCATION)
  val _ = zmq_bind (sender, "tcp://*:5557")

  (*  Socket to send start of batch message on *)
  val sink = zmq_socket (context, ZMQ_PUSH)
  val () = assert_errmsg (~sink, #LOCATION)
  val _ = zmq_connect (sink, "tcp://localhost:5558")

  val () = print_string ("Press Enter when the workers are ready: ")
  val _  = getchar ()
  val () = print_string ("Sending tasks to workers...\n")

  (*  The first message is "0" and signals start of batch *)
  val _ = s_send (sink, "0")

  (*  Initialize random number generator *)
  (*  srandom ((unsigned) time (NULL)); *)

  fun loop {l:agz} {n,m:nat | n <= m} .< m-n >. (sender: !zmqsocket l, n: int n, max: int m, total_msec: int): int = 
    if n = max then
      total_msec
    else let
      (*  Random workload from 1 to 100msecs *)
      val workload = randint (100) + 1
      val str = sprintf ("%d", @(workload))
      val _ = s_send (sender, castvwtp1 {string} (str))
      val () = strptr_free (str)
    in
      loop (sender, n + 1, max, total_msec + workload)
    end

  (*  Send 100 tasks *)
  val total_msec = loop (sender, 0, 100, 0)

  val () = printf ("Total expected cost: %d msec\n", @(total_msec))

  (*  Give 0MQ time to deliver *)
  val _ = sleep (1);

  val _ = zmq_close (sink)
  val _ = zmq_close (sender)
  val _ = zmq_term (context)
}
