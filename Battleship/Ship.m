//
//  Ship.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/24/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "Ship.h"

@implementation Ship

+ (id)shipWithType:(ShipType)shipType
{
    return [[[self class] alloc] initWithType:shipType];
}

- (id)initWithType:(ShipType)shipType
{
    if ((self = [super init]))
	{
        [self setType:shipType];
        
        switch (shipType) {
            case ShipTypePatrolBoat:
                [self setLenght:2];
                break;
                
            case ShipTypeSubmarine:
                [self setLenght:3];
                break;
                
            case ShipTypeCruiser:
                [self setLenght:3];
                break;
                
            case ShipTypeBattleship:
                [self setLenght:4];
                break;
                
            case ShipTypeCarrier:
                [self setLenght:5];
                break;
                
            default:
                break;
        }

        [self setSegments:[NSMutableArray array]];
    }
    
	return self;
}

@end
