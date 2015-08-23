//
//  PL1FastFoodGameScene.m
//  FastFoodIsEvil
//
//  Created by Nikolay Shubenkov on 23/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "PL1FastFoodGameScene.h"
#import "SKAction+SoundFilePlay.h"

typedef NS_ENUM(NSInteger, PL1FastFoodGameState) {
    PL1FastFoodGameStateInitial,
    PL1FastFoodGameStateReadyToThrow,
    PL1FastFoodGameStateDragging,
    PL1FastFoodGameStateThrowing,
    PL1FastFoodGameStateWaitingForRest,//дождемся, когда состояние нода перейдет в состояние покоя
    PL1FastFoodGameStateRemovingLastThrownObject
};

typedef NS_ENUM(NSInteger, PL1ThrowObjectType) {
    PL1ThrowObjectTypeNothing,
    PL1ThrowObjectTypeMeatBall,
    PL1ThrowObjectTypeShake
};

@interface PL1FastFoodGameScene ()

@property (nonatomic) BOOL didInitContent;
@property (nonatomic) PL1FastFoodGameState state;
@property (nonatomic) PL1ThrowObjectType throwType;
@property (nonatomic, strong) SKPhysicsBody *bodyToThrow;
@property (nonatomic, weak) SKNode *nodeToThrow;
@property (nonatomic) CGPoint startDragPosition;

@end

@implementation PL1FastFoodGameScene

#pragma mark - Setup

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    if (self.didInitContent == NO){
        [self initContent];
    }
    [SKAction pl1_playSoundFileNamed:@"Aqua Teen Hunger Force.mp3"  atVolume:1
                   waitForCompletion:YES];
}

- (void)initContent
{
    SKSpriteNode *aNode = (SKSpriteNode *) [self childNodeWithName:@"background"];
    
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, aNode.size.width, aNode.size.height)];
    border.friction       = 0;
    border.linearDamping  = 0;
    border.angularDamping = 0;
    border.restitution    = 1;
    
//    self.physicsWorld.g
    
    aNode.physicsBody = border;
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

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    switch (self.state) {
        case PL1FastFoodGameStateReadyToThrow:{
            CGPoint touchCoordinate = [anyTouch locationInNode:self];
            //Проверим попали ли мы в наш обьект для метания
            if ([self nodeAtPoint:touchCoordinate] == self.nodeToThrow){
                self.startDragPosition = touchCoordinate;
                self.state = PL1FastFoodGameStateDragging;
            }
            break;
        case PL1FastFoodGameStateThrowing:{
            CGPoint touchCoordinate = [anyTouch locationInNode:self];
            if (self.throwType == PL1ThrowObjectTypeShake){
                CGVector direction = CGVectorMake(touchCoordinate.x - self.nodeToThrow.position.x,
                                                  touchCoordinate.y - self.nodeToThrow.position.y);
                [self throwMilkFromShaker:self.bodyToThrow.node
                              todirection:direction];
            }
        }
        }break;
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (self.state) {
        case PL1FastFoodGameStateDragging:{
            UITouch *anyTouch = [touches anyObject];
            CGPoint touchPosition = [anyTouch locationInNode:self];
            self.nodeToThrow.position = touchPosition;
        }break;
            
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (self.state) {
        case PL1FastFoodGameStateDragging:{
            CGVector result = CGVectorMake(self.startDragPosition.x - self.nodeToThrow.position.x ,self.startDragPosition.y - self.nodeToThrow.position.y);

            self.state = PL1FastFoodGameStateThrowing;
            [self throwNode:self.nodeToThrow withDirection:result];
        }
        break;
            
        default:
            break;
    }
}
#pragma mark - Super

- (void)didSimulatePhysics
{
    switch (self.state) {
            //
        case PL1FastFoodGameStateWaitingForRest:{
            if (fabs(self.nodeToThrow.physicsBody.velocity.dx) < 0.01 &&
                fabs(self.nodeToThrow.physicsBody.velocity.dy) < 0.01 &&
                fabs(self.nodeToThrow.physicsBody.angularVelocity) < 0.01 ){
                
                switch (self.throwType) {
                    case PL1ThrowObjectTypeMeatBall:{
                        //переходим в состояние, когда нам осталось убрать последний объект,
                        //который мы метали
                        self.state = PL1FastFoodGameStateRemovingLastThrownObject;
                        
                        SKAction *fadeOut = [SKAction fadeAlphaTo:0.4 duration:0.25];
                        SKAction *fadeIn  = [SKAction fadeAlphaTo:1 duration:0.25];
                        SKAction *wait    = [SKAction waitForDuration:0.2];
                        
                        SKAction *blinkAndDetonate = [SKAction sequence:@[fadeOut,fadeIn,wait,
                                                                          fadeOut,fadeIn,wait,
                                                                          fadeOut,fadeIn]];
                        [self.nodeToThrow runAction:blinkAndDetonate
                                         completion:^{
                                             [self detonateMeatBall:self.nodeToThrow];
                                         }];
                    }
                    break;
                        
                    default:
                        break;
                }
                
            }
        }break;
            
            
        default:
            break;
    }
}

#pragma mark - Game Mechanics

- (void)throwMilkFromShaker:(SKNode *)node todirection:(CGVector)direction
{
    SKEmitterNode *emitter = [self emitterNodeWithName:@"shake" emittingDuration:2];

    [self addChild:emitter];
    
    emitter.position = self.nodeToThrow.position;
    emitter.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
    emitter.physicsBody.contactTestBitMask = 0;
    emitter.physicsBody.categoryBitMask    = 1 << 1;
    emitter.physicsBody.collisionBitMask   = 0;
    emitter.physicsBody.affectedByGravity  = 0;
    
    CGFloat multilplyer = 0.004;
    direction = CGVectorMake(direction.dx * multilplyer, direction.dy * multilplyer);
    [emitter.physicsBody applyForce:CGVectorMake(0, -1)];
    [emitter.physicsBody applyImpulse:direction];
}

- (void)throwNode:(SKNode *)aNode withDirection:(CGVector)direction
{
    self.nodeToThrow.physicsBody = self.bodyToThrow;
    self.bodyToThrow = nil;
    CGFloat multilplyer = 0.4;
    direction = CGVectorMake(direction.dx * multilplyer, direction.dy * multilplyer);
    [self.nodeToThrow.physicsBody applyImpulse:direction];
    
    SKAction *action = [SKAction waitForDuration:2];
    self.state = PL1FastFoodGameStateThrowing;
    [self runAction:action
         completion:^{
             self.state = PL1FastFoodGameStateWaitingForRest;
         }];
}

- (void)detonateMeatBall:(SKNode *)ball
{
    SKEmitterNode *denotator = [self emitterNodeWithName:@"MeatBallDetonation" emittingDuration:0.1];
    denotator.position = ball.position;
    [self addChild:denotator];

    self.state = PL1FastFoodGameStateInitial;
    [ball runAction:[SKAction scaleBy:4 duration:0.5] completion:^{
        [self performSelector:@selector(updateState) withObject:nil afterDelay:0.5];
        [ball runAction:[SKAction removeFromParent]];
        }];
}

//duration - время извержения, до того, как частицы не закончат извергаться, после чего
//емиттер дождется их завершения извержения и удалится со сцены
- (SKEmitterNode *)emitterNodeWithName:(NSString *)name emittingDuration:(NSTimeInterval)duration
{
    SKEmitterNode *aNode = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:name
                                                                                                      ofType:@"sks"]];
    
    aNode.targetNode = self;
    
    aNode.numParticlesToEmit = duration * aNode.particleBirthRate;
    
    NSTimeInterval timeInterval = duration + aNode.particleLifetime + aNode.particleLifetimeRange / 2;
    
    [aNode runAction:[SKAction sequence:@[
                                          [SKAction waitForDuration:timeInterval],
                                          [SKAction removeFromParent]
                                          ]
                      ]];
    return aNode;
}

- (void)putNodeToBallPosition:(SKNode *)aNode
{
    self.nodeToThrow  = aNode;
    self.bodyToThrow  = aNode.physicsBody;

    NSParameterAssert(self.bodyToThrow);
    aNode.physicsBody = nil;
    [aNode runAction:[SKAction moveTo:CGPointMake(150, 200) duration:0.25] completion:^{
        self.state = PL1FastFoodGameStateReadyToThrow;
    }];
}

- (SKNode *)nextObjectToThrow
{
    SKNode *meatBall = nil;
//    meatBall =  [self childNodeWithName:@"meatball"];
//    self.throwType = PL1ThrowObjectTypeMeatBall;

    if (!meatBall){
        meatBall = [self childNodeWithName:@"shake"];
        meatBall.physicsBody.collisionBitMask = 1;
        self.throwType = PL1ThrowObjectTypeShake;
    }
    NSAssert(meatBall,@"Not found object to throw");
    
    return meatBall;
}

@end
