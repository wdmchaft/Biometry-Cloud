//
//  AudioHandler.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioHandler.h"

#import <AudioToolbox/AudioToolbox.h>


@implementation AudioHandler

-(void)playCameraSound
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"camera_shot" ofType:@"wav"];
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    
    AudioServicesPlaySystemSound(soundID);
    
	
}

-(void)playPassOrDenySound:(BOOL) access 
{
    NSString *path=@"";
    if (access) {
        path=@"access_granted";
    }
    else {
        path=@"access_denied";
    }
    /*if recognized, then use access_granted, else use access_denied. For now, all accesses are granted*/
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"wav"];
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    
    AudioServicesPlaySystemSound(soundID);
    
}

@end
