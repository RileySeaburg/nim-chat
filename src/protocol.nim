import json
# Message to send to the server
type
  Message* = object
    username*: string
    message*: string
proc parseMessage*(data: string): Message = 
  # Parse JSON string to Nim object
  let dataJson = parseJson(data)
  result.username = dataJson["username"].getStr()
  result.message = dataJson["message"].getStr()

proc createMessage*(username, message: string): string =
  # $ converts the JsonNode by the % operator to a string
  result = $(%{
    "usernamme": %username,
    "message": %message
  }) & "\c\l"

block:
  let expected = """{"username":"test","message":"hello"}""" & "\c\l"
  doAssert createMessage("test", "hello") == expected