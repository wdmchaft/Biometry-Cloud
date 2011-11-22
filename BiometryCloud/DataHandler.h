//
//  DatabaseHandler.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 05-01-11.
//  Copyright 2011 Clockwise. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "CheckingRequest.h"

/*!
 @class
 @abstract
 @discussion
 */
@interface DataHandler : NSObject {

	//Database variables
	NSString *databaseName;
	NSString *databasePath;
	
    //Flag to lock the database
	BOOL writing;
}

- (void) storeCheckingRequest:(CheckingRequest *) request;
- (NSMutableArray *) getAllCheckingRequests;
- (NSMutableArray *) getNCheckingRequests:(int) n;
- (int) areCheckingRequestsQueued;
- (void) deleteCheckingRequest:(CheckingRequest *) request;

-(void)checkAndCreateDatabase;

@end
