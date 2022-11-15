import os, threadpool, asyncdispatch, asyncnet
import protocol

# Connect to the server
proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
  ## Connects the specified AsyncSocket to the specified address.
  ## Then receives messages from the server continuously.
  echo("Connecting to ", serverAddr)
  # Pause the execution of this procedure until the socket connects to
  # the specified server.
  await socket.connect(serverAddr, 7688.Port)
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
if paramCount() < 2:
  quit("Please specify the server address, e.g. ./client localhost username")


# Retrieve the first command line argument.
let serverAddr = paramStr(1)
# Retrieve the second command line argument.
let username = paramStr(2)
# Initialise a new asynchronous socket.
var socket = newAsyncSocket()

asyncCheck connect(socket, serverAddr) 
## Read from standard input asynchronously.
var messageFlowVar = spawn stdin.readLine()
while true:
  if messageFlowVar.isReady():
    # If the user has typed a message, send it to the server.
    
    asyncCheck socket.send(createMessage(username, ^messageFlowVar))
    messageFlowVar = spawn stdin.readLine()
    # Start reading from standard input again.
  # Execute the asyncdispatch event loop, to continue the execution of
  # asynchronous procedures.
  asyncdispatch.poll()