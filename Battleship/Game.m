//
//  Game.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "Game.h"
#import "Packet.h"


@implementation Game
{
	GKSession *_session;
	NSString *_serverPeerID;
	NSString *_localPlayerName;
    
    NSMutableDictionary *_players;

}

- (id)init
{
    if (self = [super init]) {
        _players = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}


#pragma mark - *** Game Logic ***

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
    self.isServer = NO;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_serverPeerID = peerID;
	_localPlayerName = name;
    
    Player *player = [[Player alloc] init];
	player.name = name;
	player.peerID = _session.peerID;
	player.type = PlayerLocal;
    [self setPlayer:player];
    
	_gameState = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForServerReady:self];
}

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
    self.isServer = YES;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_gameState = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForClientsReady:self];
    
	// Create the Player object for the server.
	Player *player = [[Player alloc] init];
	player.name = name;
	player.peerID = _session.peerID;
	player.type = PlayerLocal;
	[_players setObject:player forKey:player.peerID];
    [self setPlayer:player];
    
	// Add a Player object for each client.
//	int index = 0;
	for (NSString *peerID in clients)
	{
		Player *player = [[Player alloc] init];
		player.peerID = peerID;
        player.type = PlayerOpponent;
		[_players setObject:player forKey:player.peerID];
        
//		if (index == 0)
//			player.position = ([clients count] == 1) ? PlayerPositionTop : PlayerPositionLeft;
//		else if (index == 1)
//			player.position = PlayerPositionTop;
//		else
//			player.position = PlayerPositionRight;
//        
//		index++;
	}
    
	Packet *packet = [Packet packetWithType:PacketTypeSignInRequest];
	[self sendPacketToAllClients:packet];
}

- (void)startShipPlacement
{
    [self.delegate gameShipPlacementDidBegin];
}

- (void)endShipPlacement
{
    _gameState = GameStateWaitingForReady;
    
    Packet *packet;
    if (self.isServer) {
        packet = [Packet packetWithType:PacketTypeServerPlacementReady];
        [self sendPacketToAllClients:packet];
    } else {
        packet = [Packet packetWithType:PacketTypeClientPlacementReady];
        [self sendPacketToServer:packet];
    }
    
    [self.delegate gameShipPlacementDidEnd];
}

- (void)startShipTargeting
{
    [self.delegate gameShipTargetingDidBegin];
}

- (void)waitShipTargeting
{
    [self.delegate gameWaitForShipTargeting];
}

//TODO: Should make request with a payload
- (void)endShipTargetting:(NSString *)string
{
    Packet *packet;

    if (!string) {
        string = @"";
    }
    
    if (self.isServer) {
        packet = [Packet packetWithType:PacketTypeServerShootRequest];
        [[packet payload] setObject:string forKey:@"payload"];
        [self sendPacketToAllClients:packet];
    } else {
        packet = [Packet packetWithType:PacketTypeClientShootRequest];
        [[packet payload] setObject:string forKey:@"payload"];        
        [self sendPacketToServer:packet];
    }
    
    [self.delegate gameShipTargetingDidEnd];
}

- (void)shootRequestFromClientWithPayload:(NSDictionary *)payload
{
    NSString *string = [payload objectForKey:@"payload"];
    
    NSLog(@"payload: %@", string);
    
    Packet *packet = [Packet packetWithType:PacketTypeServerShootResponse];
    [[packet payload] setObject:@"OK - FromServer" forKey:@"payload"];
    [self sendPacketToAllClients:packet];
}

- (void)shootResponseFromClientWithPayload:(NSDictionary *)payload
{
    // Change game state to ready at the end
    _gameState = GameStateWaitingForReady;
}

- (void)shootRequestFromServerWithPayload:(NSDictionary *)payload
{
    NSString *string = [payload objectForKey:@"payload"];
    
    NSLog(@"payload: %@", string);
    
    Packet *packet = [Packet packetWithType:PacketTypeClientShootResponse];
    [[packet payload] setObject:@"OK - FromClient" forKey:@"payload"];
    [self sendPacketToServer:packet];
}

- (void)shootResponseFromServerWithPayload:(NSDictionary *)payload
{
    // Change game state to ready at the end
    _gameState = GameStateWaitingForReady;
}

- (void)quitGameWithReason:(QuitReason)reason
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	_gameState = GameStateQuitting;
    
	if (reason == QuitReasonUserQuit)
	{
		if (self.isServer)
		{
			Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
			[self sendPacketToAllClients:packet];
		}
		else
		{
			Packet *packet = [Packet packetWithType:PacketTypeClientQuit];
			[self sendPacketToServer:packet];
		}
	}
    
	[_session disconnectFromAllPeers];
	_session.delegate = nil;
	_session = nil;
    
	[self.delegate game:self didQuitWithReason:reason];
}


#pragma mark - Networking

- (void)sendPacketToAllClients:(Packet *)packet
{
//	if ([self isSinglePlayerGame])
//		return;
    
	// If packet numbering is enabled, each packet that we send out gets a
	// unique number that keeps increasing. This is used to ignore packets
	// that arrive out-of-order.
//	if (packet.packetNumber != -1)
//		packet.packetNumber = _sendPacketNumber++;
    
//	[_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
//     {
//         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
//     }];
    
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
    
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}
}

- (void)sendPacketToServer:(Packet *)packet
{
//	NSAssert(![self isSinglePlayerGame], @"Should not send packets in single player mode");
    
//	if (packet.packetNumber != -1)
//		packet.packetNumber = _sendPacketNumber++;
    
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
    
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to server: %@", error);
	}
}

- (Player *)playerWithPeerID:(NSString *)peerID
{
	return [_players objectForKey:peerID];
}

#pragma mark - *** GKSessionDelegate ***

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    #ifdef DEBUG
	NSLog(@"Game: peer %@ changed state %d", peerID, state);
    #endif
	
	if (state == GKPeerStateDisconnected)
	{
		if (self.isServer)
		{
//			[self clientDidDisconnect:peerID redistributedCards:nil];
		}
		else if ([peerID isEqualToString:_serverPeerID])
		{
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    #ifdef DEBUG
	NSLog(@"Game: connection request from peer %@", peerID);
    #endif
    
	[session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    #ifdef DEBUG
	NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
    #endif
    
	// Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    #ifdef DEBUG
	NSLog(@"Game: session failed %@", error);
    #endif
    
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if (_gameState != GameStateQuitting)
		{
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}


#pragma mark - *** GKSession Data Receive Handler ***

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
//	NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
//	NSLog(@"Game: receive data from peer: %@, length: %d", peerID, [data length]);
#endif
    
	Packet *packet = [Packet packetWithData:data];
	if (packet == nil)
	{
		NSLog(@"Invalid packet: %@", data);
		return;
	}
    
#ifdef DEBUG
	NSLog(@"Game: receive data from peer: %@, packetType: %u, length: %d", peerID, packet.packetType, [data length]);
#endif
    
	Player *player = [self playerWithPeerID:peerID];
//	if (player != nil)
//	{
//		if (packet.packetNumber != -1 && packet.packetNumber <= player.lastPacketNumberReceived)
//		{
//			NSLog(@"Out-of-order packet!");
//			return;
//		}
//        
//		player.lastPacketNumberReceived = packet.packetNumber;
//		player.receivedResponse = YES;
//	}
    
	if (self.isServer)
		[self serverReceivedPacket:packet fromPlayer:player];
	else
		[self clientReceivedPacket:packet];
}

- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
    //TODO:
    switch (packet.packetType)
    {
        case PacketTypeSignInResponse:
            if (_gameState == GameStateWaitingForSignIn) {
                _gameState = GameStateWaitingForReady;
                
                Packet *packet = [Packet packetWithType:PacketTypeServerReady];
                [self sendPacketToAllClients:packet];
            }
            
            break;
            
        case PacketTypeClientReady:
            if (_gameState == GameStateWaitingForReady) {
                _gameState = GameStatePlacing;
                
                Packet *packet = [Packet packetWithType:PacketTypeStartPlacement];
                [self sendPacketToAllClients:packet];
                
                [self startShipPlacement];
            }
            
            break;
            
        case PacketTypeClientPlacementReady:
            if (_gameState == GameStatePlacing) {
                
                //TODO: Just show that client is ready to begin
            }
            
            if (_gameState == GameStateWaitingForReady) {
                _gameState = GameStatePlaying;
                
                [self startShipTargeting];
                
                Packet *packet = [Packet packetWithType:PacketTypeActivatePlayer];
                [[packet payload] setObject:@"host" forKey:@"activePlayer"];
                
                [self sendPacketToAllClients:packet];
            }
            
            break;
            
        case PacketTypeClientShootRequest:
            //TODO: Take payload and give result in response
            [self shootRequestFromClientWithPayload:[packet payload]];
            
            break;
            
        case PacketTypeClientShootResponse:
            //TODO: Take payload and give result in response
            [self shootResponseFromClientWithPayload:[packet payload]];
            
            [self waitShipTargeting];
            
            if (_gameState == GameStateWaitingForReady) {
                Packet *packet = [Packet packetWithType:PacketTypeActivatePlayer];
                [[packet payload] setObject:@"guest" forKey:@"activePlayer"];
                
                [self sendPacketToAllClients:packet];
            }
            
            break;
            
        case PacketTypeActivatePlayer:
            if ([[[packet payload] objectForKey:@"activePlayer"] isEqualToString:@"host"]) {
                _gameState =GameStatePlaying;
                
                //TODO: Start choosing target
                [self startShipTargeting];
            }
            
            if ([[[packet payload] objectForKey:@"activePlayer"] isEqualToString:@"guest"]) {
                
                //TODO: Just show the turn is on the host player
            }
            break;
            
        case PacketTypeClientQuit:
            [self quitGameWithReason:QuitReasonUserQuit];
            break;
            
        default:
            NSLog(@"Server received unexpected packet: %@", packet);
            break;
    }
}

- (void)clientReceivedPacket:(Packet *)packet
{
    switch (packet.packetType)
    {
        case PacketTypeSignInRequest:
            if (_gameState == GameStateWaitingForSignIn) {
				_gameState = GameStateWaitingForReady;
                
				Packet *packet = [Packet packetWithType:PacketTypeSignInResponse];
				[self sendPacketToServer:packet];
			}
            break;
            
        case PacketTypeServerReady:
            if (_gameState == GameStateWaitingForReady) {

                Packet *packet = [Packet packetWithType:PacketTypeClientReady];
                [self sendPacketToServer:packet];
            }
            
            break;
            
        case PacketTypeStartPlacement:
            if (_gameState == GameStateWaitingForReady) {
                _gameState = GameStatePlacing;
                
                [self startShipPlacement];
            }
            
            break;
            
        case PacketTypeServerPlacementReady:
            if (_gameState == GameStatePlacing) {
                
                //TODO: Just show that server is ready to begin
            }
            
            if (_gameState == GameStateWaitingForReady) {
                
                Packet *packet = [Packet packetWithType:PacketTypeClientPlacementReady];
                [self sendPacketToServer:packet];
            }
            
            break;
                        
        case PacketTypeServerShootRequest:
            
            //TODO: Take payload and give result in response
            [self shootRequestFromServerWithPayload:[packet payload]];
            
            break;
            
        case PacketTypeServerShootResponse:
            //TODO: Take payload and give result in response
            [self shootResponseFromServerWithPayload:[packet payload]];
            
            [self waitShipTargeting];
            
            if (_gameState == GameStateWaitingForReady) {
                Packet *packet = [Packet packetWithType:PacketTypeActivatePlayer];
                [[packet payload] setObject:@"host" forKey:@"activePlayer"];
                
                [self sendPacketToServer:packet];
            }
            
            break;
            
        case PacketTypeActivatePlayer:
            if ([[[packet payload] objectForKey:@"activePlayer"] isEqualToString:@"host"]) {
                //TODO: Just show the turn is on the host player
                
                [self waitShipTargeting];
            }
            
            if ([[[packet payload] objectForKey:@"activePlayer"] isEqualToString:@"guest"]) {
                _gameState = GameStatePlaying;
                
                //TODO: Start choosing target
                [self startShipTargeting];
            }
            
            break;            
            
        case PacketTypeServerQuit:
            [self quitGameWithReason:QuitReasonServerQuit];
            break;
            
        default:
            NSLog(@"Client received unexpected packet: %@", packet);
            break;
    }
}

@end
