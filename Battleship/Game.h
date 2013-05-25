//
//  Game.h
//  Battleship
//
//  Created by Ahmet Geymen on 4/30/13.
//  Copyright (c) 2013 Ahmet Geymen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@class Game;

@protocol GameDelegate <NSObject>

- (void)gameWaitingForClientsReady:(Game *)game;  // server only
- (void)gameWaitingForServerReady:(Game *)game;   // clients only

- (void)gameShipPlacementDidBegin;
- (void)gameShipPlacementDidEnd;

- (void)gameShipTargetingDidBegin;
- (void)gameShipTargetingDidEnd;

- (void)gameWaitForShipTargeting;

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;

@end


typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStatePlacing,
	GameStatePlaying,
	GameStateGameOver,
	GameStateQuitting,
}
GameState;

@interface Game : NSObject <GKSessionDelegate>

@property (nonatomic, weak)     id <GameDelegate> delegate;
@property (nonatomic, assign)   BOOL isServer;
@property (nonatomic, assign)   GameState gameState;
@property (nonatomic, strong)   Player *player;


- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

- (void)endShipPlacement;
- (void)endShipTargetting:(NSString *)string;

- (void)quitGameWithReason:(QuitReason)reason;

@end
