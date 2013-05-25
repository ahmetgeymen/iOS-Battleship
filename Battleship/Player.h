//
//  Player.h
//  Battleship
//
//  Created by Ahmet Geymen on 5/2/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	PlayerLocal,  // the local user
	PlayerOpponent,
}
PlayerType;

@interface Player : NSObject

@property (nonatomic, weak)     NSString *name;
@property (nonatomic, weak)     NSString *peerID;
@property (nonatomic, assign)   PlayerType type;

@property (nonatomic, strong)   NSMutableArray *ships;

@end
