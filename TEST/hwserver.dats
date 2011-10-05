(*
  Hello World server
  Binds REP socket to tcp://*:5555
  Expects "Hello" from client, replies with "World"
*)
staload "contrib/libzmq/SATS/libzmq.sats"

%{^
#include <stdio.h>
#include <unistd.h>
#include <string.h>
%}

%{
void cmain (void* context)
{
    //  Socket to talk to clients
    void *responder = zmq_socket (context, ZMQ_REP);
    zmq_bind (responder, "tcp://*:5555");

    while (1) {
        //  Wait for next request from client
        zmq_msg_t request;
        zmq_msg_init (&request);
        zmq_recv (responder, &request, 0);
        printf ("Received Hello\n");
        zmq_msg_close (&request);

        //  Do some 'work'
        sleep (1);

        //  Send reply back to client
        zmq_msg_t reply;
        zmq_msg_init_size (&reply, 5);
        memcpy (zmq_msg_data (&reply), "World", 5);
        zmq_send (responder, &reply, 0);
        zmq_msg_close (&reply);
    }
    //  We never get here but if we did, this would be how we end
    zmq_close (responder);
}
%}
extern fun cmain {l:agz} (context: !zmqcontext l) : void = "mac#cmain"

implement main () = {
  val context = zmq_init (1)
  val () = assert_errmsg(~context, "zmq_init failed")
  val () = cmain (context)
  val _ = zmq_term (context)
}

