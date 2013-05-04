//
//  Game.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;

@protocol GameDelegate <NSObject>

- (void)gameWaitingForClientsReady:(Game *)game;  // server only
- (void)gameWaitingForServerReady:(Game *)game;   // clients only

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;

@end


@interface Game : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <GameDelegate> delegate;
@property (nonatomic, assign) BOOL isServer;

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

- (void)quitGameWithReason:(QuitReason)reason;

@end
