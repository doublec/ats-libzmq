(*
  Hello World client
  Connects REQ socket to tcp://localhost:5555
  Sends "Hello" to server, expects "World" back
*)
staload "contrib/libzmq/SATS/libzmq.sats"

%{^
#include <string.h>
#include <stdio.h>
#include <unistd.h>
%}

%{
void cmain (void* requester)
{
    zmq_connect (requester, "tcp://localhost:5555");

    int request_nbr;
    for (request_nbr = 0; request_nbr != 10; request_nbr++) {
        zmq_msg_t request;
        zmq_msg_init_size (&request, 5);
        memcpy (zmq_msg_data (&request), "Hello", 5);
        printf ("Sending Hello %d...\n", request_nbr);
        zmq_send (requester, &request, 0);
        zmq_msg_close (&request);

        zmq_msg_t reply;
        zmq_msg_init (&reply);
        zmq_recv (requester, &reply, 0);
        printf ("Received World %d\n", request_nbr);
        zmq_msg_close (&reply);
    }
}
%}
extern fun cmain {l:agz} (requester: !zmqsocket l) : void = "mac#cmain"

implement main () = {
  val context = zmq_init (1)
  val () = assert_errmsg(~context, "zmq_init failed")

  (*  Socket to talk to server *)
  val () = print_string ("Connecting to hello world server...\n");
  val requester = zmq_socket(context, ZMQ_REQ)
  val () = assert_errmsg(~requester, "zmq_socket failed")

  val () = cmain (requester)

  val _ = zmq_close(requester)
  val _ = zmq_term (context)
}
