import os
echo("Chat application started")
if paramCount() == 0:
    quit("Please specify the server address")

let serverAddr = paramStr(1)
echo("Connecting to ", serverAddr)
