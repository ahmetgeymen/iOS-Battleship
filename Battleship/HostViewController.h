//
//  HostViewController.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/20/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchmakingServer.h"

@class HostViewController;

@protocol HostViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(HostViewController *)controller;
- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason;
- (void)hostViewController:(HostViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;

@end


@interface HostViewController : UIViewController <MatchmakingServerDelegate>

@property (nonatomic, weak) id <HostViewControllerDelegate> delegate;

@end
