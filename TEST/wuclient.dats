(*
  Weather update client
  Connects SUB socket to tcp://localhost:5556
  Collects weather updates and finds avg temp in zipcode
*)
staload "contrib/libzmq/SATS/libzmq.sats"

extern castfn ptr_of_string (x: string):<> [l:agz] ptr l

implement main (argc, argv) = {
  val context = zmq_init (1)
  val () = assert_errmsg (~context, "zmq_init failed")

  (* Socket to talk to server *)
  val () = print_string ("Collecting updates from weather server...\n")
  val subscriber = zmq_socket (context, ZMQ_SUB)
  val () = assert_errmsg (~subscriber, #LOCATION)
  val _ = zmq_connect (subscriber, "tcp://localhost:5556")

  (* Subscribe to zipcode, default is NYC, 10001 *)
  val filter = if argc > 1 then argv.[1] else "10001 "
  val r = zmq_setsockopt (subscriber, ZMQ_SUBSCRIBE, ptr_of_string (filter), string_length (filter)) 

  (* Process 100 updates *)
  val update_nbr = 100

  fun loop {l:agz} {n,m:nat | m >= n} .< m - n >. (s: !zmqsocket l, n: int n, max: int m, total: int): int = 
    if n = max then
      total
    else let
      val str = s_recv (s)
      var zipcode: int?
      var temperature: int?
      var relhumidity: int?

      val _ = sscanf (str, "%d %d %d", zipcode, temperature, relhumidity) where {
        extern fun sscanf {l:agz} (s: !strptr l, format: string,
                                   zipcode: &int? >> int, temperature: &int? >> int, relhumidity: &int? >> int):int = "mac#sscanf"
      }

      val () = printf("Request: %d zip: %d temperature: %d humidity: %d\n", @(n, zipcode, temperature, relhumidity))
      val () = strptr_free (str)
    in
      loop (s, n + 1, max, total + temperature)
    end

  val total_temp = loop (subscriber, 0, update_nbr, 0)

  val average = total_temp / update_nbr
  val () =  printf ("Average temperature for zipcode '%s' was %dF\n", @(filter, average))

  val _ =  zmq_close (subscriber)
  val _ =  zmq_term (context)
}