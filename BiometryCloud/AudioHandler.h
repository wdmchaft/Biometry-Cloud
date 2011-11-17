//
//  AudioHandler.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioHandler : NSObject {
    
}

-(void) playCameraSound;

-(void)playPassOrDenySound:(BOOL) access ;

@end
