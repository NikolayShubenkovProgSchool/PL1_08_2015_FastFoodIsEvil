//
//  PL1FastFoodGameScene.m
//  FastFoodIsEvil
//
//  Created by Nikolay Shubenkov on 23/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "PL1FastFoodGameScene.h"

typedef NS_ENUM(NSInteger, PL1FastFoodGameState) {
    PL1FastFoodGameStateInitial,
    PL1FastFoodGameStateReadyToThrow
};

@interface PL1FastFoodGameScene ()

@property (nonatomic) BOOL didInitContent;
@property (nonatomic) PL1FastFoodGameState state;
@property (nonatomic, weak) SKPhysicsBody *bodyToThrow;
@property (nonatomic, weak) SKNode *nodeToThrow;

@end

@implementation PL1FastFoodGameScene

#pragma mark - Setup

- (void)didMoveToView:(SKView *)view
{
    if (self.didInitContent == NO){
        [self initContent];
    }
}

- (void)initContent
{
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody = border;
    [self runAction:[SKAction waitForDuration:1] completion:^{
        self.didInitContent = YES;
        [self updateState];
    }];
}

#pragma mark - UpdateState

- (void)updateState
{
    switch (self.state) {
        case PL1FastFoodGameStateInitial:{
            [self putNodeToBallPosition:[self nextObjectToThrow]];
        
        }break;
        case PL1FastFoodGameStateReadyToThrow:
            
            break;
        default:
            NSParameterAssert(NO);
            break;
    }
}

#pragma mark - Game Mechanics

- (void)putNodeToBallPosition:(SKNode *)aNode
{
    self.nodeToThrow  = aNode;
    self.bodyToThrow  = aNode.physicsBody;
    aNode.physicsBody = nil;
    [aNode runAction:[SKAction moveTo:CGPointMake(150, 200) duration:0.25] completion:^{
        self.state = PL1FastFoodGameStateReadyToThrow;
    }];
}

- (SKNode *)nextObjectToThrow
{
    SKNode *meatBall = [self childNodeWithName:@"meatball"];
    NSAssert(meatBall,@"Not found object to throw");

    return meatBall;
}

@end
