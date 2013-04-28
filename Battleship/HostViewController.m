//
//  HostViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/20/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "HostViewController.h"

#import "AppDelegate.h"

@interface HostViewController ()
{
    MatchmakingServer *_matchmakingServer;
	QuitReason _quitReason;
}

@end

@implementation HostViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_matchmakingServer == nil) {
        _matchmakingServer = [[MatchmakingServer alloc] init];
        [_matchmakingServer setDelegate:self];
        [_matchmakingServer setMaxClients:1];
        [_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - *** MatchmakingServerDelegate ***

- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
//	[self.tableView reloadData];
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(NSString *)peerID
{
//	[self.tableView reloadData];
}

- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server
{
	_matchmakingServer.delegate = nil;
	_matchmakingServer = nil;
//	[self.tableView reloadData];
	[self.delegate hostViewController:self didEndSessionWithReason:_quitReason];
}

- (void)matchmakingServerNoNetwork:(MatchmakingServer *)session
{
	_quitReason = QuitReasonNoNetwork;
}

@end
