//
//  RequestHandler.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestHandler.h"
#import "BiometryCloudConfiguration.h"

#import "CheckingRequest.h"
#import "SBJsonParser.h"

@implementation RequestHandler

@synthesize checkingURL, answerRequired;
@synthesize delegate;

#pragma mark - Object Lifecycle

- (id) init {

    if (self = [super init]) {
        
        //GPS Initialization
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        locationManager.delegate = self;
        
        currentLocation = [[CLLocation alloc] init];
        
        //Data Handler initialization
        dataHandler = [[DataHandler alloc] init];
        
        //Default URL
        checkingURL = @"http://www.biometrycloud.com:80/srv/face/getFaceId/";
    }
    
    return self;
}

- (void) dealloc {

    [locationManager release];
    [currentLocation release];
    [dataHandler release];
    
    [super dealloc];
}

#pragma mark - Checking Request

- (NSDictionary *) parseJSONCheckingData:(NSData *) data {
    
	NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSError *error;
	SBJsonParser *json = [[SBJsonParser new] autorelease];
	NSDictionary *dataDict = [json objectWithString:responseString error:&error];
	[responseString release];	
	
	if (dataDict == nil) {
		
		NSLog(@"JSON parsing failed");
	}
    
    return dataDict;
}

-(void) sendCheckingRequestWithFace: (UIImage *) face legalId: (NSString *) legal_id atTimeStamp: (NSString *) time
{	
	CheckingRequest  *request = [[CheckingRequest alloc] initWithURL:[NSURL URLWithString:checkingURL]];
    
	[request setDidFinishSelector:@selector(checkingRequestFinished:)];
	[request setDidFailSelector:@selector(checkingRequestFailed:)];
    [request setDidStartSelector:@selector(checkingRequestStarted:)];
    
    request.legal_id = legal_id;
    request.face = [UIImage imageWithCGImage:[face CGImage]];
    request.lat = currentLocation.coordinate.latitude;
    request.lng = currentLocation.coordinate.longitude;
    request.time = time;
    
    if (!answerRequired) {
        
        [dataHandler storeCheckingRequest:request];
    }
    
	[request setData:[NSData dataWithData:UIImageJPEGRepresentation(face, 0.9)]
		withFileName:@"photo.jpg"
	  andContentType:@"image/jpeg"
			  forKey:@"face"];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device"];
    [request setPostValue:[NSNumber numberWithDouble:request.lat] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:request.lng] forKey:@"lng"];
    [request setPostValue:[NSString stringWithString:request.time] forKey:@"time"];
    [request setPostValue:[NSString stringWithString:request.legal_id] forKey:@"legal_id"];
    
	[request setRequestMethod:@"POST"];
	[request setDelegate:self];
    
    [request startAsynchronous];
    
    //debugLog(@"Checking request #%d created", ++count);
}

-(void) sendStoredCheckingRequest:(CheckingRequest *) request
{	
    [request setURL:[NSURL URLWithString:checkingURL]];
    
	[request setDidFinishSelector:@selector(checkingRequestFinished:)];
	[request setDidFailSelector:@selector(checkingRequestFailed:)];
    [request setDidStartSelector:@selector(checkingRequestStarted:)];
    
	[request setData:[NSData dataWithData:UIImageJPEGRepresentation(request.face, 0.9)]
		withFileName:@"photo.jpg"
	  andContentType:@"image/jpeg"
			  forKey:@"face"];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device"];
    [request setPostValue:[NSNumber numberWithDouble:request.lat] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:request.lng] forKey:@"lng"];
    [request setPostValue:[NSString stringWithString:request.time] forKey:@"time"];
    [request setPostValue:[NSString stringWithString:request.legal_id] forKey:@"legal_id"];
    
	[request setRequestMethod:@"POST"];
	[request setDelegate:self];
    
    [request startAsynchronous];
    
    debugLog(@"Stored checking request created");
}

- (void) checkingRequestStarted:(CheckingRequest *)request {
    
    debugLog(@"Starting checking request");
}

- (void) checkingRequestFinished:(CheckingRequest *)request {
	
	NSString *response = [request responseString];
    
    debugLog(@"Checking reply received: %@", response);
    
    if (answerRequired) {
        
        NSDictionary *answerDict = [self parseJSONCheckingData:[request responseData]];
        
        [delegate checkingRequestAnswerReceived:answerDict];
    }
    else {
        
        [dataHandler deleteCheckingRequest:request];
    }
    
    [request release];
}

- (void) checkingRequestFailed:(CheckingRequest *)request {
	
    if (answerRequired) {
        
        NSDictionary *answer = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:@"2"] forKeys:[NSArray arrayWithObject:@"status"]];
        
        [delegate checkingRequestAnswerReceived:answer];
    }
    /*
    else if([clockwiseAppDelegate networkAvailable]) { // --> ARREGLAR ESTE CASO
        
        CheckingRequest *request2 = [[CheckingRequest alloc] initWithURL:[NSURL URLWithString:[clockwiseAppDelegate checkingURL]]];
        
        request2.face = request.face;
        request2.time = request.time;
        request2.lat = request.lat;
        request2.lng = request.lng;
        
        [self performSelector:@selector(sendStoredCheckingRequest:) withObject:request2];
    }
    */
    else if ([request isCancelled]) {
        
        NSLog(@"Checking request cancelled");
    }
    else {
        
        NSLog(@"Checking request failed");
    }
    
    [request release];
}

- (void) resendCheckingRequests:(NSNotification *) notification {
    
    if ([dataHandler areCheckingRequestsQueued]) {
        
        NSMutableArray *array = [dataHandler getCheckingRequests];
        
        NSLog(@"%d stored checking requests", [array count]);
        
        for (CheckingRequest *request in array) {
            
            /*
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendStoredCheckingRequest:) object:request];
            
            [[clockwiseAppDelegate threadQueue] addOperation:operation];
            
            [operation release];
             */
        }
    }
    else {
        
        NSLog(@"No stored checking requests to send");
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
}

@end
