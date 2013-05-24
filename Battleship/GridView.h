//
//  GridView.h
//  Battleship
//
//  Created by Ahmet Geymen on 5/24/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView

@property (nonatomic, weak)   id                        delegate;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGestureRecognizer;

@end
