//
//  CheckingRequest.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostRequest.h"

@interface CheckingRequest : PostRequest {
    
    UIImage *face;
    double lat;
    double lng;
    NSString *time;
    NSString *legal_id;
}



@property (nonatomic, strong) UIImage *face;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *legal_id;

@end
