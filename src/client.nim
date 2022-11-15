import os
import threadpool
echo("Chat application started")
if paramCount() == 0:
  quit("Please specify the server address, e.g. ./client localhost")

let serverAddr = paramStr(1)
echo("Connecting to ", serverAddr)
while true:
  const message = spawn readLine(stdin)
  if message == "quit":
    quit("Bye!")
  else:
    spawn send(serverAddr, message)
  echo("Sending \"", ^message, "\"")