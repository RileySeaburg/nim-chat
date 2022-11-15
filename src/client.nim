import os, threadpool, asyncdispatch, asyncnet
import protocol

# Connect to the server
proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
  ## Connects the specified AsyncSocket to the specified address.
  ## Then receives messages from the server continuously.
  echo("Connecting to ", serverAddr)
  # Pause the execution of this procedure until the socket connects to
  # the specified server.
  await socket.connect(serverAddr, 7687.Port)
  echo("Connected!")

  while true:
    # Pause the execution of this procedure until a new message is received
    # from the server.
    let line = await socket.recvLine()
    # Parse the received message using ``parseMessage`` defined in the
    # protocol module.
    let parsed = parseMessage(line)
    # Display the message to the user.
    echo(parsed.username, " said ", parsed.message)


echo("Chat application started")
if paramCount() == 0:
  quit("Please specify the server address, e.g. ./client localhost")

let serverAddr = paramStr(1)
echo("Connecting to ", serverAddr)
while true:
  let message = spawn stdin.readLine()
  echo("Sending \"", ^message, "\"")