//
//  Player.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/2/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "Player.h"

@implementation Player

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ peerID = %@, name = %@", [super description], self.peerID, self.name];
}

@end
