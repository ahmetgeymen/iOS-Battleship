//
//  JoinViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/25/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController ()
{
    MatchmakingClient *_matchmakingClient;
	QuitReason _quitReason;    
}

@end

@implementation JoinViewController

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
    
    [[self view] sendSubviewToBack:[self waitView]];
    
    if (_matchmakingClient == nil) {
        
        _quitReason = QuitReasonConnectionDropped;
        
        _matchmakingClient = [[MatchmakingClient alloc] init];
        [_matchmakingClient setDelegate:self];
		[_matchmakingClient startSearchingForServersWithSessionID:SESSION_ID];
        
		[[self tableView] reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Detecting back button
    if (![[[self navigationController] viewControllers] containsObject:self]) {
        _quitReason = QuitReasonUserQuit;
        [_matchmakingClient disconnectFromServer];
//        [self.delegate joinViewControllerDidCancel:self];
    }
    
    [super viewWillDisappear:animated];
}


#pragma mark - *** UITableViewDataSource ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_matchmakingClient != nil) {
        return  [_matchmakingClient availableServerCount];
    } else {
        return 0;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:[indexPath row]];
    NSString *peerDisplayName = [_matchmakingClient displayNameForPeerID:peerID];
    [[tableViewCell textLabel] setText:peerDisplayName];
    
    return tableViewCell;
}


#pragma mark - *** UITableViewDelegate ***

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (_matchmakingClient != nil)
	{
		[[self view] addSubview:[self waitView]];
        [[self view] bringSubviewToFront:[self waitView]];
        
		NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
		[_matchmakingClient connectToServerWithPeerID:peerID];
	}

}

#pragma mark - *** MatchmakingClientDelegate ***

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client didConnectToServer:(NSString *)peerID
{
    NSString *name = _matchmakingClient.session.displayName;
    
	[self.delegate joinViewController:self startGameWithSession:_matchmakingClient.session playerName:name server:peerID];
}

- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID
{
	_matchmakingClient.delegate = nil;
	_matchmakingClient = nil;
	[self.tableView reloadData];
	[self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}

- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client
{
	_quitReason = QuitReasonNoNetwork;
}


@end
