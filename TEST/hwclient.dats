(*
  Hello World client
  Connects REQ socket to tcp://localhost:5555
  Sends "Hello" to server, expects "World" back
*)
staload "contrib/libzmq/SATS/libzmq.sats"
staload "prelude/SATS/string.sats"
staload "libc/SATS/string.sats"

extern castfn bytes_of_string {n:nat} (x: string n):<> [l:agz] (bytes (n) @ l, bytes (n) @ l -<lin,prf> void | ptr l)

implement main () = {
  fun loop_requests {l:agz} {n,m:nat | m >= n} .< m-n >. (r: !zmqsocket l, n: int n, max: int m): void =
    if n = max then
      ()
    else let
      var request: zmq_msg_t?
      val s = string1_of_string ("Hello")
      val _ = zmq_msg_init_size (request, string1_length(s))
      val (pf_data, fpf_data | p_data) = zmq_msg_data (request)

      val (pf_bytes, fpf_bytes | p_bytes) = bytes_of_string (s)
      val _ = memcpy (pf_data | p_data, !p_bytes, string1_length(s))
      prval () = fpf_bytes(pf_bytes)
      prval () = fpf_data(pf_data, request)

      val () = printf("Sending Hello %d...\n", @(n))
      val _ = zmq_send (r, request, 0)

      var reply: zmq_msg_t?
      val _ = zmq_msg_init (reply)
      val _ = zmq_recv (r, reply, 0)

      val () = printf("Received World %d\n", @(n))
      val _ = zmq_msg_close (reply)
    in
      loop_requests (r, n + 1, max)
    end

  val context = zmq_init (1)
  val () = assert_errmsg(~context, "zmq_init failed")

  (*  Socket to talk to server *)
  val () = print_string ("Connecting to hello world server...\n");
  val requester = zmq_socket(context, ZMQ_REQ)
  val () = assert_errmsg(~requester, "zmq_socket failed")

  val _ = zmq_connect (requester, "tcp://localhost:5555")
  val () = loop_requests (requester, 0, 10)

  val _ = zmq_close(requester)
  val _ = zmq_term (context)
}
