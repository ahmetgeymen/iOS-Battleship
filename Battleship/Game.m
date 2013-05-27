//
//  Game.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "Game.h"
#import "Packet.h"
#import "Ship.h"


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
	for (NSString *peerID in clients)
	{
		Player *player = [[Player alloc] init];
		player.peerID = peerID;
        player.type = PlayerOpponent;
		[_players setObject:player forKey:player.peerID];        
	}
    
	Packet *packet = [Packet packetWithType:PacketTypeSignInRequest];
	[self sendPacketToAllClients:packet];
}

#pragma mark -

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

#pragma mark -

- (void)startShipTargeting
{
    [self.delegate gameShipTargetingDidBegin];
}

- (void)waitShipTargeting
{
    [self.delegate gameWaitForShipTargeting];
}

- (void)endShipTargetting:(NSString *)targetCoord
{
    Packet *packet;

    if (!targetCoord) {
        targetCoord = @"";
    }
    
    if (self.isServer) {
        packet = [Packet packetWithType:PacketTypeServerShootRequest];
        [[packet payload] setObject:targetCoord forKey:@"targetCoord"];
        [self sendPacketToAllClients:packet];
    } else {
        packet = [Packet packetWithType:PacketTypeClientShootRequest];
        [[packet payload] setObject:targetCoord forKey:@"targetCoord"];        
        [self sendPacketToServer:packet];
    }
    
    [self.delegate gameShipTargetingDidEnd];
}

#pragma mark -

- (void)shootRequestFromClientWithPayload:(NSDictionary *)payload
{
    NSString *targetCoord = [payload objectForKey:@"targetCoord"];
    
    NSLog(@"payload: %@", targetCoord);
    
    ResultCode resultCode = [self processShootRequestWithTargetCoordinate:targetCoord];
    
    Packet *packet = [Packet packetWithType:PacketTypeServerShootResponse];
    [[packet payload] setObject:[NSNumber numberWithInteger:resultCode] forKey:@"resultCode"];
    [self sendPacketToAllClients:packet];
}

- (void)shootResponseFromClientWithPayload:(NSDictionary *)payload
{
    ResultCode resultCode = [[payload objectForKey:@"resultCode"] integerValue];
    
    [[self delegate] gameShipProcessResultCode:resultCode];
    
    // Change game state to ready at the end
    _gameState = GameStateWaitingForReady;
}

#pragma mark -

- (void)shootRequestFromServerWithPayload:(NSDictionary *)payload
{
    NSString *targetCoord = [payload objectForKey:@"targetCoord"];
    
    NSLog(@"targetCoord: %@", targetCoord);
    
    ResultCode resultCode = [self processShootRequestWithTargetCoordinate:targetCoord];
    
    Packet *packet = [Packet packetWithType:PacketTypeClientShootResponse];
    [[packet payload] setObject:[NSNumber numberWithInteger:resultCode] forKey:@"resultCode"];
    [self sendPacketToServer:packet];
}

- (void)shootResponseFromServerWithPayload:(NSDictionary *)payload
{
    ResultCode resultCode = [[payload objectForKey:@"resultCode"] integerValue];
    
    [[self delegate] gameShipProcessResultCode:resultCode];
    
    // Change game state to ready at the end
    _gameState = GameStateWaitingForReady;
}

#pragma mark -

- (ResultCode)processShootRequestWithTargetCoordinate:(NSString *)targetCoord
{
    NSString *xCoord = [targetCoord substringFromIndex:1];
    NSString *yCoord = [targetCoord substringToIndex:1];
    
    NSInteger xIndex = [xCoord integerValue] - 1;
    
    NSString *letters = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *lettersArray = [letters componentsSeparatedByString:@" "];
    NSInteger yIndex = [lettersArray indexOfObject:yCoord];
    
    NSNumber *targetSegmentNumber = [NSNumber numberWithInteger:(yIndex * 10) + xIndex];
    
    //***************************
    
    ResultCode resultCode = ResultCodeMiss;
    
    for (Ship *ship in [[self player] ships])
    {
        for (NSNumber *segmentNumber in [ship segments]) {

            // Ship gets a hit
            if ([segmentNumber integerValue] == [targetSegmentNumber integerValue]) {

                [[ship hitSegments] addObject:targetSegmentNumber];
                resultCode = ResultCodeHit;
                
                // Ship also sinks
                if ([[ship hitSegments] count] == [ship lenght])
                {    
                    switch ([ship type]) {
                        case ShipTypeCarrier:
                            resultCode = ResultCodeCarrierSank;
                            break;
                            
                        case ShipTypeBattleship:
                            resultCode = ResultCodeBattleshipSank;
                            break;
                            
                        case ShipTypeCruiser:
                            resultCode = ResultCodeCruiserSank;
                            break;
                            
                        case ShipTypeSubmarine:
                            resultCode = ResultCodeSubmarineSank;
                            break;
                            
                        case ShipTypePatrolBoat:
                            resultCode = ResultCodePatrolBoatSank;
                            break;
                    }
                }
                
                break;
            }
        }
    }
    
    //*********************************
    
    
    // Check if all ships have sunk
    NSInteger totalHitSegment = 0;
    for (Ship *ship in [[self player] ships]) {
        totalHitSegment = totalHitSegment + [[ship hitSegments] count];
    }
    
    if (totalHitSegment == 17) {
        resultCode = ResultCodeSankAllShips;
    }
    
    //*********************************    
    
    // Update display if any ship get hit
    [[self delegate] gameShipProcessResultCode:resultCode WithSegmentNumber:targetSegmentNumber];


    return resultCode;
}

#pragma mark -

- (void)endGame
{
    // Sender of this message is the player who lost. So it sends its GameViewController to show a display about defeat.
    //Also sends signal to opponent to inform about victory.
    if (self.isServer) {
        Packet *packet = [Packet packetWithType:PacketTypeEndGame];
        [[self delegate] gameShipEndGameDidWin:NO];
        [self sendPacketToAllClients:packet];
    } else {
        Packet *packet = [Packet packetWithType:PacketTypeEndGame];
        [[self delegate] gameShipEndGameDidWin:NO];        
        [self sendPacketToServer:packet];
    }
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
                
                // Just show that client is ready to begin
                [[self delegate] gameShipPlacementOpponentReady];
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
            [self shootRequestFromClientWithPayload:[packet payload]];
            break;
            
        case PacketTypeClientShootResponse:
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
                _gameState = GameStatePlaying;
                
                // Start choosing target
                [self startShipTargeting];
            }
            if ([[[packet payload] objectForKey:@"activePlayer"] isEqualToString:@"guest"]) {
                
                //TODO: Just show the turn is on the host player
            }
            break;
            
        case PacketTypeEndGame:
            _gameState = GameStateGameOver;
            [[self delegate] gameShipEndGameDidWin:YES];
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
                // Just show that server is ready to begin
                [[self delegate] gameShipPlacementOpponentReady];                
            }
            if (_gameState == GameStateWaitingForReady) {
                Packet *packet = [Packet packetWithType:PacketTypeClientPlacementReady];
                [self sendPacketToServer:packet];
            }
            break;
                        
        case PacketTypeServerShootRequest:
            [self shootRequestFromServerWithPayload:[packet payload]];
            break;
            
        case PacketTypeServerShootResponse:
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
                
                // Start choosing target
                [self startShipTargeting];
            }
            break;
            
        case PacketTypeEndGame:
            _gameState = GameStateGameOver;
            [[self delegate] gameShipEndGameDidWin:YES];
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
