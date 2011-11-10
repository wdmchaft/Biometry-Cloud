//
//  MailValidator.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailFormatter.h"

@implementation MailFormatter

- (BOOL) isInputValid:(NSString *)input {

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}";   
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];   
    return [emailTest evaluateWithObject:input];
}

- (NSString *) getInputFormat {
    
    return @"MAIL";
}

- (NSString *) getInputName {
    
    return @"email";
}

@end
