//
//  InputVerificatorDelegate.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol InputFormatterDelegate

@required

- (BOOL) isInputValid:(NSString *) input;
- (NSString *) getInputFormat;
- (NSString *) getInputName;

@end