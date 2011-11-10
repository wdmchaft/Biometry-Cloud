//
//  PassportValidator.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PassportFormatter.h"


@implementation PassportFormatter

- (BOOL) isInputValid:(NSString *)input {

    return [[NSString stringWithFormat:@"%d",[input intValue] ] length] == 9;
}

- (NSString *) getInputFormat {
    
    return @"NNNNNNNNN";
}

- (NSString *) getInputName {
    
    return NSLocalizedString(@"passport", @"Passport String");
}

@end
