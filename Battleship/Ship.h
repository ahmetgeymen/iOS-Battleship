//
//  Ship.h
//  Battleship
//
//  Created by Ahmet Geymen on 5/24/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ShipTypePatrolBoat,
    ShipTypeSubmarine,
    ShipTypeCruiser,
    ShipTypeBattleship,
    ShipTypeCarrier
}
ShipType;

@interface Ship : NSObject

@property (nonatomic, assign)   ShipType        type;
@property (nonatomic, assign)   NSInteger       lenght;
@property (nonatomic, strong)   NSMutableArray  *segments;
@property (nonatomic, strong)   NSMutableArray  *hitSegments;

@property (nonatomic, assign)   CGRect    initialFrame;

+ (id)shipWithType:(ShipType)shipType;

@end
