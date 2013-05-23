//
//  GameViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - *** IBActions ***

- (IBAction)pressReadyButton:(id)sender {

    if ([[self game] gameState] == GameStatePlacing) {
        [[self game] endShipPlacement];
    }
    
    if ([[self game] gameState] == GameStatePlaying) {
        NSString *textValue = [[self coordTextField] text];
        
        [[self game] endShipTargetting:textValue];
    }
}

- (IBAction)pressQuitButton:(id)sender {
    
    [[self game] quitGameWithReason:QuitReasonUserQuit];
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
    [[self coordTextField] setText:@""];
    [[self coordTextField] setEnabled:NO];
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
    
    [[self coordTextField] setEnabled:YES];
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
