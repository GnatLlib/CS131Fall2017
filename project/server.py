import asyncio
import datetime
import time
import sys
import logging
import urllib
import json, ssl, re

#api key AIzaSyBCzK9XtC4DSwVduelGH1F4-qDjHopxFys

########################## GLOBAL SETUP ####################################
#get the server we are currently running
if len(sys.argv) != 2:
    print("Incorrect Usage")
    exit()
server_name = sys.argv[1]

#dictionary that maintains the place information held on this server
#for each client, we save the most recent location and the most recent timestamp,
#and the time difference of the server response to the IAMAT message
location_data = {}

#set the hardcoded port number for this server and the hardcoded server ports
#that each server is allowed to communicate with
if server_name == 'Alford':
    port_num = 18575
    neighbor_ports = [18577, 18578]
    log_file = 'alford.log'
elif server_name == 'Ball':
    port_num = 18576
    neighbor_ports = [18578, 18579]
    log_file = 'ball.log'
elif server_name == 'Hamilton':
    port_num = 18577 
    neighbor_ports = [18575, 18579]
    log_file = 'hamilton.log'
elif server_name == 'Holiday':
    port_num = 18578
    neighbor_ports = [18576, 18577]
    log_file = 'holiday.log'
elif server_name == 'Welsh':
    port_num = 18579
    neighbor_ports = [18575, 18576]
    log_file = 'welsh.log'
else:
    print("Invalid Server Name")
    exit()

#set up logger
logging.basicConfig(filename = log_file, level=logging.INFO, filemode='w')
logger = logging.getLogger(__name__)

#set up google places api info
API_KEY = 'AIzaSyBCzK9XtC4DSwVduelGH1F4-qDjHopxFys'
API_PORT = 443
API_HOST = 'maps.googleapis.com'
################### ASYNCHRONOUS HTTP REQUEST HELPERS #######################

#Helper function that retrieves the json response from google places api
async def query_api(location, radius, num_results):

    #establish ssl connection with google places api
    context = ssl.create_default_context()
    reader,writer = await asyncio.open_connection(API_HOST, API_PORT, loop=asyncio.get_event_loop(), ssl=context)

    data = bytearray()

    #format api query 
    uri = '/maps/api/place/nearbysearch/json?location={}&radius={}&key={}'.format(location, radius, API_KEY)
    message = 'GET {} HTTP/1.1\r\nHost: {}\r\n\r\n'.format(uri, API_HOST)
    
    addr = writer.get_extra_info('peername')
   
    logger.info("{} Sending message: {} to {}".format(time.ctime(), message, addr))

    writer.write(message.encode())
    
    #first we read until we hit the end of the http header, then we discard the first read
    #and read one more time until we hit the end of the message. 
    i=2
    while i>0:
        data = await reader.readuntil(b'\r\n\r\n')
        if not data:
            print("Packet Failure")
            break
        i = i-1
    
    
    response = data.decode()
    logger.info("{} Received message {} from {}".format(time.ctime(), response, addr))
    writer.close()

    #parse response from api and return the first num_results results
    response = response[response.find('{'):response.rfind('}')+1]
    response = re.sub(r'\n+', '\n', response)
    json_response  = json.loads(response, strict=False)
    json_response["results"] = json_response["results"][:int(num_results)]
    response = json.dumps(json_response, indent=4, separators=(',',': '))

    return response

###################### MESSAGE HANDLER HELPERS #############################
#helper function to handle error messages
async def handle_error(message_list, writer):

    ret_message = ret_message = "? {}".format(" ".join(message_list))

    addr = writer.get_extra_info('peername')
    logger.info("{} Sending message: {} to {}".format(time.ctime(), ret_message, addr))
    data = ret_message.encode()
    writer.write(data)
    await writer.drain()
    writer.close()

#helper function to handle IAMAT messages
async def handle_iamat(message_list, writer):

    #get the current time and calculate time difference
    rec_time = time.time()
    diff_time = rec_time - float(message_list[3])

    #store new location information in 'database' only if it is the most recent
    if message_list[1] in location_data:
        if location_data[message_list[1]][1] < message_list[3]:
            location_data[message_list[1]] = [message_list[2], message_list[3], diff_time]
            most_recent = True
        else:
            most_recent = False
    else:
        location_data[message_list[1]] = [message_list[2], message_list[3], diff_time]
        most_recent = True

    #generate and send back the appropriate AT message to the client
    addr = writer.get_extra_info('peername')
    
    ret_message = "AT {} +{:.9f} {} {} {}".format(server_name, diff_time , message_list[1], message_list[2], message_list[3])

    logger.info("{} Sending message: {} to {}".format(time.ctime(), ret_message, addr))
    data = ret_message.encode()
    writer.write(data)
    await writer.drain()
    writer.close()
    

    #If the location data we just received was the most recent 
    #for each neighboring server, attempt to establish a connection and send a custom AT flood message
    #if connection fails, simply skip, since we were told that that there is no need to propagate
    #old information to disconnected servers
    if most_recent:
        for port in neighbor_ports:
            try: 
                (reader, writer) = await asyncio.open_connection('127.0.0.1', port, loop=asyncio.get_event_loop())
                flood_message = "{} {}".format(ret_message, port_num)
                logger.info("{} Sending message: {} to 127.0.0.1 on port {}".format(time.ctime(), flood_message, port))
                data = flood_message.encode()
                writer.write(data)
                await writer.drain()
                writer.close()
            except OSError:
                logger.error("{} Connection to 127.0.0.1 {} failed".format(time.ctime(), port))
                continue

#helper function to handle AT messages
async def handle_at(message_list):

    #store new location information in 'database' only if it is the most recent
    if message_list[3] in location_data:
        if location_data[message_list[3]][1] < message_list[5]:
            location_data[message_list[3]] = [message_list[4], message_list[5], message_list[2] ]
            most_recent = True
        else:
            most_recent = False
    else:
        location_data[message_list[3]] = [message_list[4], message_list[5], message_list[2]]
        most_recent = True

    #each of my flood AT messages is terminated by a list of nodes that this message has already 
    #been propogated to
    already_flooded = message_list[6:]
    flood_message = " ".join(message_list)

    #if the data we just received is the most recent, try to propagate
    if most_recent:
        for port in neighbor_ports:
            #if the message has already been flooded to a neighbor port, no need to propagate
            #again 
            if str(port) not in already_flooded:
                try:
                    (reader, writer) = await asyncio.open_connection('127.0.0.1', port,loop=asyncio.get_event_loop())
                    flood_message = "{} {}".format(flood_message, port_num)
                    logger.info("{} Sending message: {} to 127.0.0.1 on port {}".format(time.ctime(), flood_message, port))
                    data = flood_message.encode()
                    writer.write(data)
                    await writer.drain()
                    writer.close()
                except OSError:
                    logger.error("{} Connection to 127.0.0.1 {} failed".format(time.ctime(), port))
                    continue


#helper function to handle WHATSAT messages
async def handle_whatsat(message_list, writer):

    #if the request client is valid and parameters and within bounds 
    if (message_list[1] in location_data) and (int(message_list[2])<=50) and (int(message_list[3])<=20):
        #get the location info for the requested client
        location = location_data[message_list[1]][0]

        #get the time difference stored in location data
        diff_time = location_data[message_list[1]][2]

        #get the time the client sent the IAMAT message
        client_time = location_data[message_list[1]][1]

        #convert location to format used by google api
        for i in range(1, len(location)):
            if (location[i] == '+') or (location[i] == '-'):
                api_location = location[:i]+','+location[i:]
        
        #query the google places api for the json data we want
        response = await query_api(api_location, int(message_list[2])*1000, message_list[3])

        #generate and send back the appropriate AT message to the client
        ret_message = "AT {} +{:.9f} {} {} {}\n{}\n\n".format(server_name, float(diff_time) , message_list[1], location, client_time,response)
        addr = writer.get_extra_info('peername')
        logger.info("{} Sending message: {} to {}".format(time.ctime(), ret_message, addr))
        data = ret_message.encode()
        writer.write(data)
        await writer.drain()
        writer.close()
    else:
        await handle_error(message_list, writer)

    

################### MAIN CODE TO INITIATE SERVER LOOP #####################
#coroutine to handle a new incoming connection 
async def handle_message(reader, writer):
    addr = writer.get_extra_info('peername')

    logger.info("{} Connection with {} initiated".format(time.ctime(), addr))
    while True:
        data = await reader.read(256)
        
        if not data:
            
            logger.info("{} Connection with {} terminated".format(time.ctime(), addr))
            writer.close()
            break

        message = data.decode()
        message_list = message.split()
        message_type = message_list[0]
        
       
        logger.info("{} Received message {} from {}".format(time.ctime(), message, addr))

        #call the appropriate helper function to handle each type of message
        if message_type == "IAMAT":
            await handle_iamat(message_list, writer)
        elif message_type == "AT":
            await handle_at(message_list)
        elif message_type == 'WHATSAT':
            await handle_whatsat(message_list, writer)
        else:
            await handle_error(message_list, writer)



loop = asyncio.get_event_loop()
coro = asyncio.start_server(handle_message, '127.0.0.1', port_num, loop=loop)
server = loop.run_until_complete(coro)

# Serve requests until Ctrl+C is pressed
print('Serving on {}'.format(server.sockets[0].getsockname()))
logger.info('Serving on {}'.format(server.sockets[0].getsockname()))
try:
    #loop.create_task(display_date(loop))
    loop.run_forever()
except KeyboardInterrupt:
    pass

# Close the server
server.close()
loop.run_until_complete(server.wait_closed())
loop.close()