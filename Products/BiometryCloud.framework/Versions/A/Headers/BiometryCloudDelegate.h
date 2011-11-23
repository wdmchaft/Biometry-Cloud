//
//  BiometryCloudDelegate.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BiometryCloudDelegate

- (void) identificationProcessFinished:(NSDictionary *) answer;

- (void) faceCaptured:(UIImage *) face;

- (BOOL) isAnswerHandledByDelegate;

@end
