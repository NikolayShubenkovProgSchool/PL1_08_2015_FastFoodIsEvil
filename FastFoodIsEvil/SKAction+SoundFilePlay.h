//
//  SKAction+SoundFilePlay.h
//  FastFoodIsEvil
//
//  Created by Nikolay Shubenkov on 23/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKAction (SoundFilePlay)

+(SKAction*)pl1_playSoundFileNamed:(NSString*)fileName atVolume:(CGFloat)volume waitForCompletion:(BOOL)wait;

@end
