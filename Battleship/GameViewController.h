//
//  GameViewController.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "GridView.h"
#import "ShipView.h"


@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end


@interface GameViewController : UIViewController <GameDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UILabel        *centerLabel;
@property (nonatomic, weak) IBOutlet UILabel        *targetCoordLabel;
@property (nonatomic, weak) IBOutlet UIButton       *readyButton;

@property (nonatomic, weak) IBOutlet GridView       *myGridView;
@property (nonatomic, weak) IBOutlet GridView       *targetGridView;

@property (nonatomic, weak) IBOutlet ShipView       *patrolBoatShipView;
@property (nonatomic, weak) IBOutlet ShipView       *cruiserShipView;
@property (nonatomic, weak) IBOutlet ShipView       *submarineShipView;
@property (nonatomic, weak) IBOutlet ShipView       *battleshipShipView;
@property (nonatomic, weak) IBOutlet ShipView       *carrierShipView;


@property (nonatomic, weak) id <GameViewControllerDelegate> delegate;
@property (nonatomic, strong) Game *game;

- (IBAction)pressReadyButton:(id)sender;
- (IBAction)pressQuitButton:(id)sender;

- (IBAction)shipGesturePan:(id)sender;
- (IBAction)shipGestureRotate:(id)sender;

- (void)selectTargetAtPoint:(CGPoint)point;

@end
