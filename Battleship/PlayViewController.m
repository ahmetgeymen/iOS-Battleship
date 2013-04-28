//
//  PlayViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/28/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushJoinViewController"])
    {
        JoinViewController *joinViewController = [segue destinationViewController];
        [joinViewController setDelegate:self];
    }
    
    if ([[segue identifier] isEqualToString:@"PushHostViewController"])
    {
        HostViewController *hostViewController = [segue destinationViewController];
        [hostViewController setDelegate:self];
    }
}


#pragma mark - *** Alerts ***

- (void)showNoNetworkAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

- (void)showDisconnectedAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}


#pragma mark - *** JoinViewControllerDelegate ***

- (void)joinViewControllerDidCancel:(JoinViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason
{
	// The "No Wi-Fi/Bluetooth" alert does not close the Join screen,
	// but the "Connection Dropped" disconnect does.
    
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
	else if (reason == QuitReasonConnectionDropped)
	{
		[self dismissViewControllerAnimated:NO completion:^
         {
             [self showDisconnectedAlert];
         }];
	}
}

//- (void)joinViewController:(JoinViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
//{
//	_performAnimations = NO;
//    
//	[self dismissViewControllerAnimated:NO completion:^
//     {
//         _performAnimations = YES;
//         
//         [self startGameWithBlock:^(Game *game)
//          {
//              [game startClientGameWithSession:session playerName:name server:peerID];
//          }];
//     }];
//}



#pragma mark - *** HostViewControllerDelegate ***

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
}

//- (void)hostViewController:(HostViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
//{
//	_performAnimations = NO;
//    
//	[self dismissViewControllerAnimated:NO completion:^
//     {
//         _performAnimations = YES;
//         
//         [self startGameWithBlock:^(Game *game)
//          {
//              [game startServerGameWithSession:session playerName:name clients:clients];
//          }];
//     }];
//}



@end
