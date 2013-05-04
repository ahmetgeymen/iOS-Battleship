//
//  Packet.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/2/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "Packet.h"

@implementation Packet

+ (id)packetWithData:(NSData *)data
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    Packet *packet;
    PacketType packetType = [[dictionary objectForKey:@"PacketType"] integerValue];
    
    //TODO: Switch with packetType
    packet.packetType = packetType;

    [packet setPacketNumber:[[dictionary objectForKey:@"PacketNumber"] intValue]];
    return packet;
}

+ (id)packetWithType:(PacketType)packetType
{
    return [[[self class] alloc] initWithType:packetType];
}

- (id)initWithType:(PacketType)packetType
{
    if ((self = [super init]))
	{
		self.packetNumber = -1;
		self.packetType = packetType;
		self.sendReliably = YES;
	}
	return self;
}

- (NSData *)data
{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    
    [mutableDictionary setObject:[NSNumber numberWithInt:[self packetNumber]]   forKey:@"PacketNumber"];
    [mutableDictionary setObject:[NSNumber numberWithInteger:[self packetType]] forKey:@"PacketType"];
    [mutableDictionary setObject:[NSNumber numberWithBool:[self sendReliably]]  forKey:@"SendReliably"];
    
    return [NSKeyedArchiver archivedDataWithRootObject:mutableDictionary];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@, type=%d", [super description], self.packetType];
}

@end
