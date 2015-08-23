//
//  SKAction+SoundFilePlay.m
//  FastFoodIsEvil
//
//  Created by Nikolay Shubenkov on 23/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "SKAction+SoundFilePlay.h"

@import SpriteKit;

@import AVFoundation;

@implementation SKAction (SoundFilePlay)

+(SKAction*)pl1_playSoundFileNamed:(NSString*)fileName atVolume:(CGFloat)volume waitForCompletion:(BOOL)wait{
    // setup audio
    NSString*   nameOnly = [fileName stringByDeletingPathExtension];
    NSString*   extension = [fileName pathExtension];
    NSURL *soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:nameOnly ofType:extension]];
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
    [player setVolume:volume];
    [player prepareToPlay];
    
    SKAction*   playAction = [SKAction runBlock:^{
        [player play];
    }];
    if(wait == YES){
        SKAction*   waitAction = [SKAction waitForDuration:player.duration];
        SKAction* groupActions = [SKAction group:@[playAction, waitAction]];
        return groupActions;
    }
    return playAction;
}

@end
