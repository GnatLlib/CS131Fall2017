import asyncio
import time

async def mock_client(message, loop):
    
    #TEST 1 Send initial IAMAT message to Alford
    reader,writer = await asyncio.open_connection('127.0.0.1', 18575, loop=loop)

    print('Send: %r' % message)
    writer.write(message.encode())

    data = await reader.read(100)
    print('Received: %r' % data.decode())

    time.sleep(3)

    #TEST 2 SEND WHATSAT message to Hamilton
    reader,writer = await asyncio.open_connection('127.0.0.1', 18577, loop=loop)
    message = ("WHATSAT kiwi.cs.ucla.edu 10 5")
    print('Send: %r' % message)
    writer.write(message.encode())

    data = bytearray()
    while True:
        chunk = await reader.read(100)
        if not chunk:
            break
        data += chunk
    
    print('Received: {}'.format(data.decode()))

    time.sleep(3)

    #TEST 3 SEND updated IAMAT message to Ball
    reader,writer = await asyncio.open_connection('127.0.0.1', 18576, loop=loop)
    message = ("IAMAT kiwi.cs.ucla.edu +40.068930-110.445127 %.9f" % time.time())
    print('Send: %r' % message)
    writer.write(message.encode())

    data = await reader.read(100)
    print('Received: %r' % data.decode())

    time.sleep(3)

    #TEST 4 SEND WHATSAT message to Welsh
    reader,writer = await asyncio.open_connection('127.0.0.1', 18579, loop=loop)
    message = ("WHATSAT kiwi.cs.ucla.edu 10 5")
    print('Send: %r' % message)
    writer.write(message.encode())

    data = bytearray()
    while True:
        chunk = await reader.read(100)
        if not chunk:
            break
        data += chunk
    
    print('Received: {}'.format(data.decode()))

    time.sleep(3)
    #TEST 5 SEND INVALID message to Holiday
    reader,writer = await asyncio.open_connection('127.0.0.1', 18578, loop=loop)
    message = ("INVALID kiwi.cs.ucla.edu 10 5")
    print('Send: %r' % message)
    writer.write(message.encode())

    data = await reader.read(100)
    print('Received: %r' % data.decode())

    time.sleep(10)
    print('Closing socket')
    writer.close()

message = ("IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 %.9f" % time.time())
loop = asyncio.get_event_loop()
loop.run_until_complete(mock_client(message, loop))
loop.close()

