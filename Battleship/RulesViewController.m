//
//  RulesViewController.m
//  Battleship
//
//  Created by Ahmet Geymen on 5/28/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Rules" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
