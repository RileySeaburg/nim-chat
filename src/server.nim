import asyncdispatch, asyncnet

type
  Client = ref object     # Define client as reference type
    socket: AsyncSocket   # Socket for client
    netAddr: string       # Network address of client
    id: int               # Unique ID of client
    connected: bool       # Is client connected?

  Server = ref object     # Define server as reference type
    socket: AsyncSocket   # Socket for server
    clients: seq[Client]  # List of clients

proc newServer(): Server = Server(socket: newAsyncSocket(), clients: @[])

proc `$`(client: Client): string =
  ## Converts a ``Client``'s information into a string.
  $client.id & "(" & client.netAddr & ")"


proc processMessages(server: Server, client: Client) {.async.} = # Async procedure
  ## Loops while ``client`` is connected to this server, and checks
  ## whether as message has been received from ``client``.
  while true:                                                    # Start loop
    let line = await client.socket.recvLine()                    # Receive line
    if line.len == 0:                                            # If line is empty
      echo(client, " disconnected")                              # Print message
      client.connected = false                                   # Set connected to false
      client.socket.close()                                      # Close socket
      return                                                     # Return from procedure
    
    echo(client, " sent: ", line)                                # Print message
    for c in server.clients:                                     # Loop through clients
      if c.id != client.id and c.connected:
        await c.socket.send(line & "\c\L")                      # Send message to client

proc loop(server: Server, port = 7688) {.async.} =
  ## Loops forever and checks for new connections.
  # Bind the port number specified by ``port``.
  server.socket.bindAddr(port.Port)                 # Bind to port
  # Ready the server socket for new connections.
  server.socket.listen()                            # Listen for connections
  echo("Listening on localhost:", port)             # Echo listening message
  while true:                                       # Loop forever
  # Pause execution of this procedure until a new connection is accepted.
    let (netAddr, clientSocket) =  await server.socket.acceptAddr() # Accept connection
    echo("Accepted connection from: ", netAddr)                     # Print address
    # Create a new instance of Client.
    let client = Client(
      socket: clientSocket,
      netAddr: netAddr,
      id: server.clients.len,
      connected: true
    )
    server.clients.add(client)                                      # Add client to list
    asyncCheck processMessages(server, client)                      # Start processing messages

# Check whether this module has been imported as a dependency to another
# module, or whether this module is the main module.
when isMainModule:
  # Initialise a new server.
  var server = newServer()
  echo("Server initialised!")
  # Execute the ``loop`` procedure. The ``waitFor`` procedure will run the
  # asyncdispatch event loop until the ``loop`` procedure finishes executing.
  waitFor loop(server)