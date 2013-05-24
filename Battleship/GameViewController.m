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


#pragma mark - *** View Customizations ***

- (BOOL)panShipView:(UIView *)shipView fromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    if (![[[self myGridView] subviews] containsObject:shipView]) {

        CGPoint relativeEndPoint = [[self myGridView] convertPoint:endPoint fromView:[shipView superview]];
        CGRect relativeFrame = [[self myGridView] convertRect:[shipView frame] fromView:[[self myGridView] superview]];
        
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
            
            [[self myGridView] addSubview:shipView];
            [shipView setFrame:relativeFrame];
            
            //***************************
            
            // If ship size is odd or even
            BOOL odd;
            
            // Ship is not rotated
            if (shipView.bounds.size.width > shipView.bounds.size.height) {
                odd = fmod(shipView.bounds.size.width / 45, 2) == 1;
            } else {
                odd = fmod(shipView.bounds.size.height / 45, 2) == 1;
            }
            
            CGPoint newPoint = [self nearestPoint:relativeEndPoint isOdd:odd];

            // Snap ship
            [UIView animateWithDuration:0.5f animations:^{
                [shipView setCenter:CGPointMake(newPoint.x, newPoint.y)];
            }];

            //***************************
            
            return YES;
        }
    }

    else {
        
        if (CGRectContainsPoint([[self myGridView] bounds], endPoint)) {
            
            // If ship size is odd or even
            BOOL odd;
            
            // Ship is not rotated
            if (shipView.bounds.size.width > shipView.bounds.size.height) {
                odd = fmod(shipView.bounds.size.width / 45, 2) == 1;
            } else {
                odd = fmod(shipView.bounds.size.height / 45, 2) == 1;
            }
            
            CGPoint newPoint = [self nearestPoint:endPoint isOdd:odd];
            
            // Check if overlap with another ship
            BOOL isOverlapping = NO;
            for (UIView *subView in [[self myGridView] subviews]) {
                if (![subView isEqual:shipView]) {
                    if (CGRectIntersectsRect([shipView frame], [subView frame])) {
                        isOverlapping = YES;
                    }
                }
            }
            
            // Snap ship
            if (isOverlapping) {
                return NO;
            } else {
                [UIView animateWithDuration:0.5f animations:^{
                    [shipView setCenter:CGPointMake(newPoint.x, newPoint.y)];
                }];
            }
            
            return YES;
        }
    }
    
    return NO;
}

- (CGPoint)nearestPoint:(CGPoint)point isOdd:(BOOL)odd;
{    
    CGPoint newPoint;
    
    NSInteger xIndex = point.x / 45;
    NSInteger yIndex = point.y / 45;

    if (odd) {
        newPoint.x = xIndex * 45 + (45 / 2.0);
        newPoint.y = yIndex * 45 + (45 / 2.0);
        
    } else {

        // x coordinate
        if (point.x - (xIndex * 45) < (45 / 2.0)) {
            newPoint.x = xIndex * 45;
        } else {
            newPoint.x = (xIndex + 1) * 45;
        }
        
        newPoint.y = yIndex * 45 + (45 / 2.0);
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
    
    [[self game] quitGameWithReason:QuitReasonUserQuit];
}


#pragma mark - *** UIGestureRecogizer Actions ***

- (IBAction)shipGesturePan:(UIPanGestureRecognizer *)recognizer
{
    UIView *shipView = [recognizer view];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        panStartPoint = [shipView center];
    }
    
    // Get the translation of the gesture
    CGPoint translation = [recognizer translationInView:[shipView superview]];
    CGPoint effectiveTranslation = CGPointApplyAffineTransform(translation, [shipView transform]);
    
    int newX = shipView.center.x + effectiveTranslation.x;
    int newY = shipView.center.y + effectiveTranslation.y;

    shipView.center = (CGPoint){newX, newY};

    [recognizer setTranslation:CGPointZero inView:shipView];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {

        panEndPoint = shipView.center;

        if (![self panShipView:shipView fromPoint:panStartPoint toPoint:panEndPoint]) {
            [UIView animateWithDuration:0.5 animations:^{
                [shipView setCenter:panStartPoint];
            }];
        }
    }
}

- (IBAction)shipGestureRotate:(UIRotationGestureRecognizer *)recognizer
{
    NSLog(@"ship Rotate");    
}

#pragma mark - *** GridViewDelegate ***

- (void)selectTargetAtPoint:(CGPoint)point
{
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;
    
    NSString *letters = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *lettersArray = [letters componentsSeparatedByString:@" "];

    NSString *targetCoordString = [lettersArray objectAtIndex:xIndex];
    targetCoordString = [targetCoordString stringByAppendingString:[NSString stringWithFormat:@"%d", yIndex + 1]];

    [[self targetCoordLabel] setText:targetCoordString];
}


#pragma mark - *** GameDelegate ***

- (void)gameWaitingForClientsReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}

- (void)gameWaitingForServerReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

- (void)gameWaitForShipTargeting
{
    [[self targetCoordLabel] setText:@""];
    [[self readyButton] setEnabled:NO];
    
    self.centerLabel.text = NSLocalizedString(@"Waiting opponent for shooting", @"Status text: Empty field");
}

- (void)gameShipPlacementDidBegin
{
    self.centerLabel.text = NSLocalizedString(@"Place your ships", @"Status text: placement began");
}

- (void)gameShipPlacementDidEnd
{
    self.centerLabel.text = NSLocalizedString(@"Waiting for other player to be ready", @"Status text: placement ended");
}

- (void)gameShipTargetingDidBegin
{
    //TODO: Make game grid enabled for targeting
    
    NSLog(@"ship targeting began");
    
    [[self targetCoordLabel] setText:@""];
    [[self readyButton] setEnabled:YES];
    
    self.centerLabel.text = NSLocalizedString(@"Choose a target coordinate", @"Status text: targeting began");
}

- (void)gameShipTargetingDidEnd
{
    //TODO: Make game grid disabled for targeting
    NSLog(@"ship targeting ended");
}

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
	[self.delegate gameViewController:self didQuitWithReason:reason];
}

@end
