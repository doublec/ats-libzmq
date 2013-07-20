(*
  Report 0MQ version
*)
staload "libzmq/SATS/libzmq.sats"

implement main () = {
  var major: int?
  var minor: int?
  var patch: int?

  val () = zmq_version (major, minor, patch)
  val () = printf("Current 0MQ version is %d.%d.%d\n", @(major, minor, patch))
}
