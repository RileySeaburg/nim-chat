import json
# Message to send to the server
type
  Message* = object
    username*: string
    message*: string
  # Cerate Error message
  MessageParsingError* = object of Exception
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

when isMainModule:
  block:
    let data = """{"username": "John", "message": "Hi!"}"""     
    let parsed = parseMessage(data)                             
    doAssert parsed.username == "John"                          
    doAssert parsed.message == "Hi!"  

    # Test Failure
  block:
    try:
      let parsed = parseMessage("John")
    except MessageParsingError:
      doAssert true
    except:
      doAssert false
      