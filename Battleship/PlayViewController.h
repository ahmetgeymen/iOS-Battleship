//
//  PlayViewController.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/28/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinViewController.h"
#import "HostViewController.h"
#import "GameViewController.h"

@interface PlayViewController : UIViewController <UIAlertViewDelegate, JoinViewControllerDelegate, HostViewControllerDelegate, GameViewControllerDelegate>

@end
