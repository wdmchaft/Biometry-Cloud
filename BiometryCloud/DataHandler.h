//
//  DatabaseHandler.h
//  ControlApplication
//
//  Created by Maria Ignacia Hevia Salinas on 05-01-11.
//  Copyright 2011 Clockwise. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "/usr/include/sqlite3.h"
#import "PositionRequest.h"
#import "CheckingRequest.h"

/*!
 @class
 @abstract
 @discussion
 */
@interface DataHandler : NSObject {

	// Documents variables
	NSString *databaseName;
	NSString *documentsPath;
	NSString *databasePath;
    
    NSString *propertyListName;
    NSString *propertyListPath;
	
	BOOL writing;
}

- (void) storeCheckingRequests:(NSArray *) array;
- (void) storeCheckingRequest:(CheckingRequest *) request;
- (NSMutableArray *) getCheckingRequests;
- (BOOL) areCheckingRequestsQueued;
- (void) deleteCheckingRequest:(CheckingRequest *) request;

- (void) storePositionRequests:(NSArray *) array;
- (void) storePositionRequest:(PositionRequest *) request;
- (NSMutableArray *) getPositionRequests;
- (BOOL) arePositionRequestsQueued;
- (void) deletePositionRequest:(PositionRequest *) request;

-(void)checkAndCreateDatabase;

-(void) storeConfig:(NSDictionary *) params;
-(NSDictionary*)loadConfig;

@end
