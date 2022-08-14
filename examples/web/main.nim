import
  std/asyncdispatch,
  std/asynchttpserver,
  std/httpclient,
  ./controller

proc main {.async.} =
  var server = newAsyncHttpServer()
  proc cb(req: Request) {.async.} =
    if req.url.path == "/":
      let headers = {"Content-type": "text/html; charset=utf-8"}
      await req.respond(Http200, index().await, headers.newHttpHeaders())
    elif req.url.path == "/jsmain.js":
      let headers = {"Content-type": "application/javascript; charset=utf-8"}
      await req.respond(Http200, readFile("./jsmain.js"), headers.newHttpHeaders())
    else:
      await req.respond(Http404, "")


  server.listen(Port(9000)) # or Port(8080) to hardcode the standard HTTP port.
  let port = server.getPort
  echo "test this with: curl localhost:" & $port.uint16 & "/"
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      await sleepAsync(500)

waitFor main()