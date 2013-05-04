//
//  GameViewController.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"


@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end


@interface GameViewController : UIViewController <GameDelegate>

@property (nonatomic, weak) IBOutlet UILabel *centerLabel;

@property (nonatomic, weak) id <GameViewControllerDelegate> delegate;
@property (nonatomic, strong) Game *game;

@end
