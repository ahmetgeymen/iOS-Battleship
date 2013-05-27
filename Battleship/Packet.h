//
//  Packet.h
//  Battleship
//
//  Created by Ahmet Geymen on 5/2/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	PacketTypeSignInRequest,            // server to client
	PacketTypeSignInResponse,           // client to server
    
	PacketTypeServerReady,              // server to client
	PacketTypeClientReady,              // client to server
    
    PacketTypeStartPlacement,           // server to client
	PacketTypeServerPlacementReady,     // server to client
	PacketTypeClientPlacementReady,     // client to server
    
	PacketTypeActivatePlayer,           // server to client & client to server
    
	PacketTypeServerShootRequest,       // server to client
	PacketTypeServerShootResponse,      // server to client
    
    PacketTypeClientShootRequest,       // client to server
	PacketTypeClientShootResponse,      // client to server
    
    PacketTypeEndGame,                  // server to client & client to server
    
	PacketTypeServerQuit,               // server to client
	PacketTypeClientQuit,               // client to server
}
PacketType;

@interface Packet : NSObject

@property (nonatomic, assign) int packetNumber;
@property (nonatomic, assign) PacketType packetType;
@property (nonatomic, assign) BOOL sendReliably;
@property (nonatomic, strong) NSMutableDictionary *payload;

+ (id)packetWithData:(NSData *)data;
+ (id)packetWithType:(PacketType)packetType;

- (id)initWithType:(PacketType)packetType;
- (void)addPayload:(NSDictionary *)payload;

- (NSData *)data;

@end
