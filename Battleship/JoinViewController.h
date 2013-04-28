//
//  JoinViewController.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/25/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchmakingClient.h"

@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinViewController *)controller;
- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason;
- (void)joinViewController:(JoinViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

@end


@interface JoinViewController : UIViewController <NSNetServiceBrowserDelegate, UITableViewDataSource, UITableViewDelegate, MatchmakingClientDelegate>

@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
