//
//  PostRequest.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CFNetwork/CFNetwork.h>

@interface PostRequest : NSObject {
    
    NSMutableURLRequest *request;
    
    NSMutableArray *postFiles;
    NSMutableArray *postData;
    
    SEL didFinishSelector;
    SEL didFailSelector;
    
    id __unsafe_unretained delegate;
    
    NSMutableData *responseData;
}

@property (assign) SEL didFinishSelector;
@property (assign) SEL didStartSelector;
@property (assign) SEL didFailSelector;

@property (nonatomic, unsafe_unretained) id delegate;

@property (nonatomic, strong) NSData *responseData;

- (void) setURL: (NSString *) url;
- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;
- (void) addPostValue:(id <NSObject>)value forKey:(NSString *)key;
- (void) start;
- (id) initWithURL:(NSString *) url;
- (NSString *) responseString;

@end
