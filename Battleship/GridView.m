//
//  GridView.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/24/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "GridView.h"
#import "GameViewController.h"

@implementation GridView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)]];
//        [self addGestureRecognizer:[self tapGestureRecognizer]];
//    }
//    return self;
//}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [[UIColor blueColor] setStroke];
    
    NSInteger cellWidth = CELLSIZE;
    NSInteger cellHeight = CELLSIZE;
    
    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
        NSInteger xPos = i * cellWidth;
        [bezierPath moveToPoint:CGPointMake(xPos, rect.origin.y)];
        [bezierPath addLineToPoint:CGPointMake(xPos, rect.size.height)];
        [bezierPath stroke];
        [bezierPath removeAllPoints];
    }
    
    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
        NSInteger yPos = i * cellHeight;
        [bezierPath moveToPoint:CGPointMake(rect.origin.x, yPos)];
        [bezierPath addLineToPoint:CGPointMake(rect.size.width, yPos)];
        [bezierPath stroke];
        [bezierPath removeAllPoints];
    }
    
    CGContextRestoreGState(contextRef);
}


#pragma mark - *** UIGestureRecognizer Target Action ***

- (void)doTap:(UITapGestureRecognizer *)gestureRecognizer
{    
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    NSLog(@"tapPoint: %@", NSStringFromCGPoint(tapPoint));
    
    if ([[[self delegate] game] gameState] == GameStatePlaying) {
        [self addTargetViewAtPoint:tapPoint];
    }
}

#pragma mark -

- (void)addTargetViewAtPoint:(CGPoint)point
{
    // Clean current targetView
    [[self viewWithTag:3] removeFromSuperview];
    
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;
    
    UIView *targetView = [[UIView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
    [targetView setBackgroundColor:[UIColor orangeColor]];

    // Identifying the target view with tag 0
    [targetView setTag:3];
    
    [self insertSubview:targetView atIndex:0];
    
    [(GameViewController *)[self delegate] selectTargetAtPoint:point];
}

@end
