//
//  RequestHandler.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DataHandler.h"
#import "Reachability.h"

@protocol RequestHandlerDelegate

- (void) checkingRequestAnswerReceived: (NSDictionary *) response;
- (BOOL) isRequestAnswerRequired;

@end

@interface RequestHandler : NSObject <CLLocationManagerDelegate> {
    
    //Request Delegate
    id<RequestHandlerDelegate> __unsafe_unretained delegate;
    
    //WebService's URL
    NSString *checkingURL;
    
    //GPS manager to add lat and lng to requests
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    //Data Handler for storing requests when needed
    DataHandler *dataHandler;
    
    //Flag to know if storing requests is needed
    BOOL _storeRequests;
    
    //Reachability to handle internet connection
    Reachability *reachability;
    BOOL isNetworkAvailable;
    
    BOOL connectionActive;
}

@property (nonatomic, unsafe_unretained) id<RequestHandlerDelegate> delegate;

@property (nonatomic, strong) NSString *checkingURL;
@property (nonatomic, assign) BOOL storeRequests;

- (void) sendCheckingRequestWithFace: (UIImage *) face legalId: (NSString *) legal_id atTimeStamp: (NSString *) time;

@end
