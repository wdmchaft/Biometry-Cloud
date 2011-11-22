//
//  RutVerificator.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RutFormatter.h"


@implementation RutFormatter

- (BOOL) isInputValid:(NSString *)input {

    int rut = [[input substringToIndex:[input length] - 2] intValue];
    NSString *valid = [input substringFromIndex:[input length] - 1];
    
    int digit;
    int ncount;
    int mult;
    int accum;
    NSString *realValid;
    
    ncount = 2;
    accum = 0;
    
    while (rut != 0)
    {
        mult = (rut % 10) * ncount;
        accum = accum + mult;
        rut = rut/10;
        ncount = ncount + 1;
        if (ncount == 8)
        {
            ncount = 2;
        }
        
    }
    
    digit = 11 - (accum % 11);
    realValid = [NSString stringWithFormat:@"%d", digit];
    if (digit == 10 )
    {
        realValid = @"k";
    }
    if (digit == 11)
    {
        realValid = @"0";
    }
    
    return [realValid isEqualToString:valid];
}

- (NSString *) getInputFormat {

    return @"NNNNNNNK-K";
}

- (NSString *) getInputName {

    return @"rut";
}

@end
