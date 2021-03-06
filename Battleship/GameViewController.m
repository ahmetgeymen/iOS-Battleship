//
//  GameViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()
{
    CGPoint panStartPoint;
    CGPoint panEndPoint;
}

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self targetGridView] setDelegate:self];
    [[self targetGridView] setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:[self targetGridView] action:@selector(doTap:)]];
    [[self targetGridView] addGestureRecognizer:[[self targetGridView] tapGestureRecognizer]];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - *** Game Data Modelling ***

- (void)saveSegmentsForShip:(ShipView *)shipView
{
    BOOL isShipRotated = NO;
    
    if ([shipView frame].size.width < [shipView frame].size.height) {
        isShipRotated = YES;
    }
    
    NSInteger xIndex = [shipView frame].origin.x / CELLSIZE;
    NSInteger yIndex = [shipView frame].origin.y / CELLSIZE;
    
    NSInteger firstSegment = yIndex * 10 + xIndex;
    
    // Carrier
    if ([shipView isEqual:[self carrierShipView]]) {
        
        BOOL doesContainCarrier = NO;
        Ship *carrierShip = nil;
        
        for (Ship *ship in [[[self game] player] ships]) {
            if ([ship type] == ShipTypeCarrier) {
                doesContainCarrier = YES;
                carrierShip = ship;
                break;
            }
        }
        
        // Modify ship segments
        if (doesContainCarrier) {
            
            [[carrierShip segments] removeAllObjects];
            
            for (int i = 0; i < [carrierShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[carrierShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[carrierShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
        }
        
        // Add ship for first time
        else {

            carrierShip = [Ship shipWithType:ShipTypeCarrier];
            for (int i = 0; i < [carrierShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[carrierShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[carrierShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
            
            [[[[self game] player] ships] addObject:carrierShip];
        }
    }
    
    // Battleship
    if ([shipView isEqual:[self battleshipShipView]]) {

        BOOL doesContainBattleship = NO;
        Ship *battleshipShip = nil;
        
        for (Ship *ship in [[[self game] player] ships]) {
            if ([ship type] == ShipTypeBattleship) {
                doesContainBattleship = YES;
                battleshipShip = ship;
                break;
            }
        }
        
        // Modify ship segments
        if (doesContainBattleship) {
            
            [[battleshipShip segments] removeAllObjects];
            
            for (int i = 0; i < [battleshipShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[battleshipShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[battleshipShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
        }
        
        // Add ship for first time
        else {
            
            battleshipShip = [Ship shipWithType:ShipTypeBattleship];
            for (int i = 0; i < [battleshipShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[battleshipShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[battleshipShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
            
            [[[[self game] player] ships] addObject:battleshipShip];
        }
    }
    
    // Cruiser
    if ([shipView isEqual:[self cruiserShipView]]) {

        BOOL doesContainCruiser = NO;
        Ship *cruiserShip = nil;
        
        for (Ship *ship in [[[self game] player] ships]) {
            if ([ship type] == ShipTypeCruiser) {
                doesContainCruiser = YES;
                cruiserShip = ship;
                break;
            }
        }
        
        // Modify ship segments
        if (doesContainCruiser) {
            
            [[cruiserShip segments] removeAllObjects];
            
            for (int i = 0; i < [cruiserShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[cruiserShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[cruiserShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
        }
        
        // Add ship for first time
        else {
            
            cruiserShip = [Ship shipWithType:ShipTypeCruiser];
            for (int i = 0; i < [cruiserShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[cruiserShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[cruiserShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
            
            [[[[self game] player] ships] addObject:cruiserShip];
        }
    }
    
    // Submarine
    if ([shipView isEqual:[self submarineShipView]]) {

        BOOL doesContainSubmarine = NO;
        Ship *submarineShip = nil;
        
        for (Ship *ship in [[[self game] player] ships]) {
            if ([ship type] == ShipTypeSubmarine) {
                doesContainSubmarine = YES;
                submarineShip = ship;
                break;
            }
        }
        
        // Modify ship segments
        if (doesContainSubmarine) {
            
            [[submarineShip segments] removeAllObjects];
            
            for (int i = 0; i < [submarineShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[submarineShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[submarineShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
        }
        
        // Add ship for first time
        else {
            
            submarineShip = [Ship shipWithType:ShipTypeSubmarine];
            for (int i = 0; i < [submarineShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[submarineShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[submarineShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
            
            [[[[self game] player] ships] addObject:submarineShip];
        }
    }
    
    // Patrol Boat
    if ([shipView isEqual:[self patrolBoatShipView]]) {

        BOOL doesContainPatrolBoat = NO;
        Ship *patrolBoatShip = nil;
        
        for (Ship *ship in [[[self game] player] ships]) {
            if ([ship type] == ShipTypePatrolBoat) {
                doesContainPatrolBoat = YES;
                patrolBoatShip = ship;
                break;
            }
        }
        
        // Modify ship segments
        if (doesContainPatrolBoat) {
            
            [[patrolBoatShip segments] removeAllObjects];
            
            for (int i = 0; i < [patrolBoatShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[patrolBoatShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[patrolBoatShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
        }
        
        // Add ship for first time
        else {
            
            patrolBoatShip = [Ship shipWithType:ShipTypePatrolBoat];
            for (int i = 0; i < [patrolBoatShip lenght]; i++) {
                
                // Add vertical segments
                if (isShipRotated) {
                    [[patrolBoatShip segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
                }
                // Add horizontal segments
                else {
                    [[patrolBoatShip segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
                }
            }
            
            [[[[self game] player] ships] addObject:patrolBoatShip];
        }
    }
    
    // Make ready to start
    if ([[[[self game] player] ships] count] == 5) {
        [[self readyButton] setEnabled:YES];
        [[self readyButton] setTitle:@"Ready" forState:UIControlStateNormal];
    }
}


#pragma mark - *** View Customizations ***

- (BOOL)panShipView:(UIView *)shipView toPoint:(CGPoint)endPoint
{
    // If the ship is not positioned on the grid before
    if (![[[self myGridView] subviews] containsObject:shipView]) {

        CGPoint relativeEndPoint = [[self myGridView] convertPoint:endPoint fromView:[shipView superview]];
        CGRect relativeFrame = [[self myGridView] convertRect:[shipView frame] fromView:[shipView superview]];
        
        if (CGRectContainsPoint([[self myGridView] bounds], relativeEndPoint)) {
            
            // Check if overlap with another ship
            BOOL isOverlapping = NO;
            for (UIView *subView in [[self myGridView] subviews]) {
                if (![subView isEqual:shipView]) {
                    if (CGRectIntersectsRect(relativeFrame, [subView frame])) {
                        isOverlapping = YES;
                    }
                }
            }
            
            if (isOverlapping) {
                return NO;
            }
                        
            //***************************
            
            // If ship size is odd or even
            BOOL odd;
            
            // Ship is not rotated
            if (shipView.bounds.size.width > shipView.bounds.size.height) {
                odd = fmod(shipView.bounds.size.width / CELLSIZE, 2) == 1;
            } else {
                odd = fmod(shipView.bounds.size.height / CELLSIZE, 2) == 1;
            }
            
            BOOL rotated = NO;
            if (shipView.frame.size.width < shipView.frame.size.height) {
                rotated = YES;
            }
            
            CGPoint newPoint = [self nearestPoint:relativeEndPoint isOdd:odd andRotated:rotated];
            
            //***************************
            
            // Check if ship overflow from grid
            CGPoint translation = CGPointMake((newPoint.x - relativeEndPoint.x), (newPoint.y - relativeEndPoint.y));
            CGRect checkFrame = CGRectMake(relativeFrame.origin.x + translation.x, relativeFrame.origin.y + translation.y, relativeFrame.size.width, relativeFrame.size.height);
            
            CGRect myGridFrame = [[self myGridView] bounds];
            
            if (!CGRectContainsRect(myGridFrame, checkFrame)) {
                return NO;
            }

            //***************************            
            
            [[self myGridView] addSubview:shipView];
            [shipView setFrame:relativeFrame];
            
            //***************************

            // Snap ship
            [UIView animateWithDuration:0.5f animations:^{
                [shipView setCenter:CGPointMake(newPoint.x, newPoint.y)];
            }];

            //***************************
            
            return YES;
        }
    }

    // If the ship is positioned on the grid before
    else {
        
        if (CGRectContainsPoint([[self myGridView] bounds], endPoint)) {
            
            // If ship size is odd or even
            BOOL odd;
            
            // Ship is not rotated
            if (shipView.bounds.size.width > shipView.bounds.size.height) {
                odd = fmod(shipView.bounds.size.width / CELLSIZE, 2) == 1;
            } else {
                odd = fmod(shipView.bounds.size.height / CELLSIZE, 2) == 1;
            }
            
            BOOL rotated = NO;
            if (shipView.frame.size.width < shipView.frame.size.height) {
                rotated = YES;
            }
            
            CGPoint newPoint = [self nearestPoint:endPoint isOdd:odd andRotated:rotated];
            
            // Check if overlap with another ship
            BOOL isOverlapping = NO;
            for (UIView *subView in [[self myGridView] subviews]) {
                if (![subView isEqual:shipView]) {
                    if (CGRectIntersectsRect([shipView frame], [subView frame])) {
                        isOverlapping = YES;
                    }
                }
            }
            
            if (isOverlapping) {
                return NO;
            }
            
            //********************
            
            // Check if ship overflow from grid
            CGPoint translation = CGPointMake((newPoint.x - endPoint.x), (newPoint.y - endPoint.y));
            CGRect frameRect = [shipView frame];
            CGRect checkFrame = CGRectMake(frameRect.origin.x + translation.x, frameRect.origin.y + translation.y, frameRect.size.width, frameRect.size.height);
            
            CGRect myGridFrame = [[self myGridView] bounds];
            
            if (!CGRectContainsRect(myGridFrame, checkFrame)) {
                return NO;
            }
            
            //********************

            // Snap ship
            [UIView animateWithDuration:0.5f animations:^{
                [shipView setCenter:CGPointMake(newPoint.x, newPoint.y)];
            }];
            
            return YES;
        }
    }
    
    return NO;
}

- (CGPoint)nearestPoint:(CGPoint)point isOdd:(BOOL)odd andRotated:(BOOL)rotated;
{    
    CGPoint newPoint;
    
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;

    if (!rotated)
    {
        if (odd) {
            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);
            
        } else {
            
            // x coordinate
            if (point.x - (xIndex * CELLSIZE) < (CELLSIZE / 2.0)) {
                newPoint.x = xIndex * CELLSIZE;
            } else {
                newPoint.x = (xIndex + 1) * CELLSIZE;
            }
            
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);
        }

    } else {
        if (odd) {
            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);

        } else {

            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            
            // y coordinate
            if (point.y - (yIndex * CELLSIZE) < (CELLSIZE / 2.0)) {
                newPoint.y = yIndex * CELLSIZE;
            } else {
                newPoint.y = (yIndex + 1) * CELLSIZE;
            }
        }
    }

    return newPoint;
}


#pragma mark - *** IBActions ***

- (IBAction)pressReadyButton:(id)sender {

    if ([[self game] gameState] == GameStatePlacing) {
        [[self game] endShipPlacement];
    }
    
    if ([[self game] gameState] == GameStatePlaying) {
        NSString *textValue = [[self targetCoordLabel] text];
        
        [[self game] endShipTargetting:textValue];
    }
}

- (IBAction)pressQuitButton:(id)sender {
    
    if (![self game]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    [[self game] quitGameWithReason:QuitReasonUserQuit];
}


#pragma mark - *** UIGestureRecogizer Actions ***

- (IBAction)shipGesturePan:(UIPanGestureRecognizer *)recognizer
{
    ShipView *shipView = (ShipView *)[recognizer view];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        panStartPoint = [shipView center];
        
        // Bring ship in front of all other ships
        if ([[shipView superview] isEqual:[self view]]) {
            [[self view] bringSubviewToFront:shipView];
        } else {
            [[self myGridView] bringSubviewToFront:shipView];
        }
    }
    
    // Get the translation of the gesture
    CGPoint translation = [recognizer translationInView:[shipView superview]];
    CGPoint effectiveTranslation = CGPointApplyAffineTransform(translation, CGAffineTransformIdentity);
    
    int newX = shipView.center.x + effectiveTranslation.x;
    int newY = shipView.center.y + effectiveTranslation.y;

    shipView.center = (CGPoint){newX, newY};

    [recognizer setTranslation:CGPointZero inView:shipView];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {

        panEndPoint = shipView.center;

        if (![self panShipView:shipView toPoint:panEndPoint]) {
            [UIView animateWithDuration:0.5 animations:^{
                [shipView setCenter:panStartPoint];
            }];
        }
        
        // Save the ships segments as data model
        else {
            [self saveSegmentsForShip:shipView];
        }
    }
}

- (IBAction)shipGestureLongPress:(UILongPressGestureRecognizer *)recognizer
{
    ShipView *shipView = (ShipView *)[recognizer view];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        panStartPoint = [shipView center];
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        
        // Rotate ship with animation
        [UIView animateWithDuration:0.5 animations:^{

            CGAffineTransform transform = [shipView transform];
            
            if (![shipView isRotated]) {
                transform = CGAffineTransformRotate(transform, M_PI_2);
            } else {
                transform = CGAffineTransformIdentity;
            }
            
            [shipView setTransform:transform];            
            [shipView setIsRotated:![shipView isRotated]];
        }];
        
        // Also bring ship in front of all other ships
        if ([[shipView superview] isEqual:[self view]]) {
            [shipView setCenter:[recognizer locationInView:[self view]]];
            [[self view] bringSubviewToFront:shipView];
        } else {
            [shipView setCenter:[recognizer locationInView:[self myGridView]]];
            [[self myGridView] bringSubviewToFront:shipView];
        }
    }
    
    if ([recognizer state] == UIGestureRecognizerStateChanged) {
        
        // Get the translation of the gesture
        if ([[shipView superview] isEqual:[self view]]) {
            CGPoint point = [recognizer locationInView:[self view]];
            shipView.center = point;
            
        } else {
            CGPoint point = [recognizer locationInView:[self myGridView]];
            shipView.center = point;
        }
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        
        panEndPoint = shipView.center;
        
        // If panning on to end point is not successful
        if (![self panShipView:shipView toPoint:panEndPoint]) {
            
            [UIView animateWithDuration:0.5 animations:^{
            
                CGAffineTransform transform = [shipView transform];

                if (![shipView isRotated]) {
                    transform = CGAffineTransformRotate(transform, M_PI_2);
                } else {
                    transform = CGAffineTransformIdentity;
                }

                [shipView setTransform:transform];
                [shipView setIsRotated:![shipView isRotated]];
                
                [shipView setCenter:panStartPoint];
            }];
        }
        
        // Save the ships segments as data model
        else {
            [self saveSegmentsForShip:shipView];
        }
    }
}


#pragma mark - *** GridViewDelegate ***

- (void)selectTargetAtPoint:(CGPoint)point
{
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;
    
    NSString *letters = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *lettersArray = [letters componentsSeparatedByString:@" "];

    NSString *targetCoordString = [lettersArray objectAtIndex:yIndex];
    targetCoordString = [targetCoordString stringByAppendingString:[NSString stringWithFormat:@"%d", xIndex + 1]];

    [[self turnInfoLabel] setText:@""];
    [[self targetCoordLabel] setText:targetCoordString];
    [[self readyButton] setTitle:@"SHOOT!" forState:UIControlStateNormal];
}


#pragma mark - *** GameDelegate ***

- (void)gameWaitingForClientsReady:(Game *)game
{
	self.waitViewLabel.text = NSLocalizedString(@"Waiting for syncing with guest", @"Status text: waiting for client");
    [[self view] addSubview:[self waitView]];
    [[self view] bringSubviewToFront:[self waitView]];
}

- (void)gameWaitingForServerReady:(Game *)game
{
	self.waitViewLabel.text = NSLocalizedString(@"Waiting for host to start the game", @"Status text: waiting for server");
    [[self view] addSubview:[self waitView]];
    [[self view] bringSubviewToFront:[self waitView]];
}

#pragma mark -

- (void)gameShipPlacementDidBegin
{
    self.centerLabel.text = NSLocalizedString(@"Place your ships", @"Status text: placement began");
    [[self turnInfoLabel] setText:@""];

    [[self waitView] removeFromSuperview];
}

- (void)gameShipPlacementDidEnd
{
    self.centerLabel.text = NSLocalizedString(@"Waiting for opponent to be ready", @"Status text: placement ended");

    [[self readyButton] setEnabled:NO];
    [[self readyButton] setTitle:@"Wait" forState:UIControlStateNormal];
    
    // Make all ships disabled for pan
    [[self carrierShipView]     removeGestureRecognizer:[[[self carrierShipView]    gestureRecognizers] objectAtIndex:0]];
    [[self battleshipShipView]  removeGestureRecognizer:[[[self battleshipShipView] gestureRecognizers] objectAtIndex:0]];
    [[self cruiserShipView]     removeGestureRecognizer:[[[self cruiserShipView]    gestureRecognizers] objectAtIndex:0]];
    [[self submarineShipView]   removeGestureRecognizer:[[[self submarineShipView]  gestureRecognizers] objectAtIndex:0]];
    [[self patrolBoatShipView]  removeGestureRecognizer:[[[self patrolBoatShipView] gestureRecognizers] objectAtIndex:0]];
}

- (void)gameShipPlacementOpponentReady
{
    [[self turnInfoLabel] setText:@"Opponent is ready"];
    [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
}

#pragma mark -

- (void)gameShipTargetingDidBegin
{
    // Make game grid enabled for targeting
    NSLog(@"ship targeting began");
    
    self.centerLabel.text = NSLocalizedString(@"Choose a target coordinate", @"Status text: targeting began");    
    [[self targetCoordLabel] setText:@""];
    
    [[self readyButton] setEnabled:YES];
    [[self readyButton] setTitle:@"Choose" forState:UIControlStateNormal];
    
    [[self targetGridView] setUserInteractionEnabled:YES];
}

- (void)gameShipTargetingDidEnd
{
    // Make game grid disabled for targeting
    NSLog(@"ship targeting ended");

    [[self targetGridView] setUserInteractionEnabled:NO];
}

#pragma mark -

- (void)gameWaitForShipTargeting
{
    [[self targetCoordLabel] setText:@""];
    
    if ([[[self turnInfoLabel] text] isEqualToString:@"Turn Info Label"]) {
        [[self turnInfoLabel] setText:@""];
    }
    
    [[self readyButton] setEnabled:NO];
    [[self readyButton] setTitle:@"Wait" forState:UIControlStateNormal];
    
    self.centerLabel.text = NSLocalizedString(@"Waiting for opponent to shoot", @"Status text: waiting for shooting");
}

#pragma mark -

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
	[self.delegate gameViewController:self didQuitWithReason:reason];
}

#pragma mark -

- (void)gameShipProcessResultCode:(ResultCode)resultCode WithSegmentNumber:(NSNumber *)targetSegmentNumber
{
    NSInteger xIndex = [targetSegmentNumber integerValue] % 10;
    NSInteger yIndex = [targetSegmentNumber integerValue] / 10;
    
    if (resultCode == ResultCodeMiss) {
        [[self turnInfoLabel] setText:@"Opponent missed"];
        [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
        
        UIView *missView = [[UIView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
        [missView setBackgroundColor:[UIColor cyanColor]];
        
        [[self myGridView] addSubview:missView];
    }
    
    if (resultCode >= ResultCodeHit && resultCode != ResultCodeSankAllShips) {

        UIImageView *hitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
        [hitImageView setImage:[UIImage imageNamed:@"icon-cross"]];
        
        [[self myGridView] addSubview:hitImageView];
        
        //********************************
        
        [[self turnInfoLabel] setTextColor:[UIColor redColor]];
        
        if (resultCode == ResultCodeHit) {
            [[self turnInfoLabel] setText:@"Your ship has been hit"];
        }
        else {
            switch (resultCode) {
                case ResultCodeCarrierSank:
                    [[self turnInfoLabel] setText:@"Your carrier has been sunk"];
                    break;
                    
                case ResultCodeBattleshipSank:
                    [[self turnInfoLabel] setText:@"Your battleship has been sunk"];
                    break;
                    
                case ResultCodeCruiserSank:
                    [[self turnInfoLabel] setText:@"Your crusier has been sunk"];
                    break;
                    
                case ResultCodeSubmarineSank:
                    [[self turnInfoLabel] setText:@"Your submarine has been sunk"];
                    break;
                    
                case ResultCodePatrolBoatSank:
                    [[self turnInfoLabel] setText:@"Your patrol boat has been sunk"];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    // End game because all ships have sunk. You lost the game
    if (resultCode == ResultCodeSankAllShips) {
        [[self game] endGame];
    }
}

- (void)gameShipProcessResultCode:(ResultCode)resultCode
{
    UIView *segmentCellView = [[self targetGridView] viewWithTag:3];
    
    switch (resultCode) {
        case ResultCodeMiss:
            
            [[self turnInfoLabel] setText:@"You missed"];
            [[self turnInfoLabel] setTextColor:[UIColor orangeColor]];
            
            [segmentCellView setBackgroundColor:[UIColor lightGrayColor]];
            [segmentCellView setTag:1];
            break;
            
        case ResultCodeHit:
            [[self turnInfoLabel] setText:@"You hit"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        case ResultCodeCarrierSank:
            [[self turnInfoLabel] setText:@"Opponent carrier sunk"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        case ResultCodeBattleshipSank:
            [[self turnInfoLabel] setText:@"Opponent battleship sunk"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        case ResultCodeCruiserSank:
            [[self turnInfoLabel] setText:@"Opponent cruiser sunk"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        case ResultCodeSubmarineSank:
            [[self turnInfoLabel] setText:@"Opponent submarine sunk"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        case ResultCodePatrolBoatSank:
            [[self turnInfoLabel] setText:@"Opponent patrol boat sunk"];
            [[self turnInfoLabel] setTextColor:[UIColor greenColor]];
            
            [segmentCellView setBackgroundColor:[UIColor redColor]];
            [segmentCellView setTag:2];
            break;
            
        default:
            break;
    }
}

// End Game Display
- (void)gameShipEndGameDidWin:(BOOL)result
{
    UIAlertView *alertView;
    
    if (result) {
        alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Game Ended, You Won", @"Client disconnected alert title")
                                  message:NSLocalizedString(@"Connection will close.", @"Client disconnected alert message")
                                  delegate:[self delegate]
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                                  otherButtonTitles:nil];

    } else {
        alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Game Ended, You Lost", @"Client disconnected alert title")
                                  message:NSLocalizedString(@"Connection will close.", @"Client disconnected alert message")
                                  delegate:[self delegate]
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                                  otherButtonTitles:nil];

    }
    
	[alertView show];
}

@end
