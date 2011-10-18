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

@protocol RequestHandlerDelegate

- (void) checkingRequestAnswerReceived: (NSDictionary *) response;

@end

@interface RequestHandler : NSObject <CLLocationManagerDelegate, ASIHTTPRequestDelegate> {
    
    //Request Delegate
    id<RequestHandlerDelegate> delegate;
    
    //WebService's URL
    NSString *checkingURL;
    
    //Flag to set if the delegate needs the request answer or not
    BOOL answerRequired;
    
    //GPS manager to add lat and lng to requests
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    //Data Handler for storing requests when needed
    DataHandler *dataHandler;
}

@property (nonatomic, retain) id<RequestHandlerDelegate> delegate;

@property (nonatomic, retain) NSString *checkingURL;
@property (nonatomic, assign) BOOL answerRequired;

@end
