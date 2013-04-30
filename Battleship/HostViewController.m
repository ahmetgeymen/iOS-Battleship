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

- (void)viewWillDisappear:(BOOL)animated
{
    // Detecting back button
    if (![[[self navigationController] viewControllers] containsObject:self]) {
        _quitReason = QuitReasonUserQuit;
        [_matchmakingServer endSession];
//        [self.delegate hostViewControllerDidCancel:self];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - *** IBAction ***

- (IBAction)startAction:(id)sender
{
	if (_matchmakingServer != nil && [_matchmakingServer connectedClientCount] > 0)
	{
//		NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//		if ([name length] == 0)
		NSString *name = _matchmakingServer.session.displayName;
        
		[_matchmakingServer stopAcceptingConnections];
        
		[self.delegate hostViewController:self startGameWithSession:_matchmakingServer.session playerName:name clients:_matchmakingServer.connectedClients];
	}
}


#pragma mark - *** UITableViewDataSource ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_matchmakingServer != nil) {
        [[self startButton] setEnabled:YES];
        return [_matchmakingServer connectedClientCount];
    }
	else {
        [[self startButton] setEnabled:NO];
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"MyReuseIdentifier";
    
	UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (tableViewCell == nil)
		tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
	NSString *peerID = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];
	[[tableViewCell textLabel] setText:[_matchmakingServer displayNameForPeerID:peerID]];
    
	return tableViewCell;
}


#pragma mark - *** UITableViewDelegate ***

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}


#pragma mark - *** MatchmakingServerDelegate ***

- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server
{
	_matchmakingServer.delegate = nil;
	_matchmakingServer = nil;
	[self.tableView reloadData];
	[self.delegate hostViewController:self didEndSessionWithReason:_quitReason];
}

- (void)matchmakingServerNoNetwork:(MatchmakingServer *)session
{
	_quitReason = QuitReasonNoNetwork;
}

@end
