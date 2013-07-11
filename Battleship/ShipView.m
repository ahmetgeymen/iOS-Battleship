//
//  ShipView.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/24/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "ShipView.h"

@implementation ShipView

- (void)awakeFromNib
{
    [[self layer] setMasksToBounds:YES];
    [[self layer] setCornerRadius:10];
    
    CGRect insetRect = CGRectInset([self frame], 0, 5);
    [[self layer] setFrame:insetRect];
    
    [self setIsRotated:NO];
}

@end
