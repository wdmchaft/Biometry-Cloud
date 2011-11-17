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

@synthesize checkingURL, storeRequests = _storeRequests;
@synthesize delegate;

#pragma mark - Checking Request

- (NSDictionary *) parseJSONCheckingData:(NSData *) data {
    
	NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSError *error;
	SBJsonParser *json = [[SBJsonParser new] autorelease];
	NSDictionary *dataDict = [json objectWithString:responseString error:&error];
	[responseString release];	
	
	if (dataDict == nil) {
		
		debugLog(@"JSON parsing failed");
	}
    
    return dataDict;
}

- (void) setCheckingRequestParams: (CheckingRequest *) request {

    [request setURL:[NSURL URLWithString:checkingURL]];
    
	[request setDidFinishSelector:@selector(checkingRequestFinished:)];
	[request setDidFailSelector:@selector(checkingRequestFailed:)];
    [request setDidStartSelector:@selector(checkingRequestStarted:)];
    
	[request setData:[NSData dataWithData:UIImageJPEGRepresentation(request.face, 0.9)]
		withFileName:@"photo.jpg"
	  andContentType:@"image/jpeg"
			  forKey:@"data"];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device"];
    [request setPostValue:[NSNumber numberWithDouble:request.lat] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:request.lng] forKey:@"lng"];
    //--> ESTOS 2 PARAMETROS NO SON TOMADOS EN CUENTA POR BIOMETRYCLOUD
    [request setPostValue:[NSString stringWithString:request.time] forKey:@"time"];
    [request setPostValue:[NSString stringWithString:request.legal_id] forKey:@"legal_id"];
    
    //PARAMS
    [request setPostValue:@"1" forKey:@"distanceType"];
    [request setPostValue:@"LBP" forKey:@"algorithm"];
    [request setPostValue:@"DEMO" forKey:@"app"]; //--> DEMO POR MIENTRAS
    
	[request setRequestMethod:@"POST"];
	[request setDelegate:self];
}

- (void) sendCheckingRequestWithFace: (UIImage *) face legalId: (NSString *) legal_id atTimeStamp: (NSString *) time
{	
	CheckingRequest  *request = [[CheckingRequest alloc] initWithURL:nil];
    
    request.legal_id = legal_id;
    request.face = [UIImage imageWithCGImage:[face CGImage] scale:1.0 orientation:UIImageOrientationRight];
    request.lat = currentLocation.coordinate.latitude;
    request.lng = currentLocation.coordinate.longitude;
    request.time = time;
    
    if (_storeRequests) {
        
        [dataHandler storeCheckingRequest:request];
    }
    
	[self setCheckingRequestParams:request];
    
    [request startAsynchronous];
}

-(void) sendStoredCheckingRequest:(CheckingRequest *) request
{	
    [self setCheckingRequestParams:request];
    
    [request startAsynchronous];
    
    debugLog(@"Stored checking request created");
}

- (void) checkingRequestStarted:(CheckingRequest *)request {
    
    debugLog(@"Starting checking request");
}

- (void) checkingRequestFinished:(CheckingRequest *)request {
    
    debugLog(@"Checking reply received: %@", [request responseString]);
    
    NSDictionary *answerDict = [self parseJSONCheckingData:[request responseData]];
    
    if ([delegate isRequestAnswerRequired]) {
        
        [delegate checkingRequestAnswerReceived:answerDict];
    }
    else if (answerDict != nil && _storeRequests) {
        
        [dataHandler deleteCheckingRequest:request];
    }
    
    [request release];
}

- (void) checkingRequestFailed:(CheckingRequest *)request {
	
    if ([delegate isRequestAnswerRequired]) {
        
        NSDictionary *answer = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:@"2"] forKeys:[NSArray arrayWithObject:@"status"]];
        
        [delegate checkingRequestAnswerReceived:answer];
    }
    else if([reachability currentReachabilityStatus] != NotReachable) {
        
        CheckingRequest *request2 = [[CheckingRequest alloc] initWithURL:[NSURL URLWithString:checkingURL]];
        
        request2.face = request.face;
        request2.time = request.time;
        request2.lat = request.lat;
        request2.lng = request.lng;
        
        [self performSelector:@selector(sendStoredCheckingRequest:) withObject:request2];
    }
    //If no answer required and there's no internet connection, the request isn't deleted from database
    else if ([request isCancelled]) {
        
        debugLog(@"Checking request cancelled");
    }
    else {
        
        debugLog(@"Checking request failed");
    }
    
    [request release];
}

- (void) resendCheckingRequests {
    
    if ([dataHandler areCheckingRequestsQueued]) {
        
        NSMutableArray *array = [dataHandler getCheckingRequests];
        
        debugLog(@"%d stored checking requests", [array count]);
        
        for (CheckingRequest *request in array) {
            
            [self sendStoredCheckingRequest:request];
        }
        
        [array release];
    }
    else {
        
        debugLog(@"No stored checking requests to send");
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocation *aux = currentLocation;
    
    currentLocation = [newLocation copy];
    
    [aux release];
}

#pragma mark - Reachability Notification Handling

- (void)reachabilityChanged:(NSNotification *)note
{
    BOOL newNetworkStatus = [reachability currentReachabilityStatus] != NotReachable;
    
    //Do action if there's a change
    if (!isNetworkAvailable && newNetworkStatus && _storeRequests) {
        
        debugLog(@"Connection Found");
        
        //Resend stored checking requests
        [self resendCheckingRequests];
    }
    else if (isNetworkAvailable && !newNetworkStatus) {
        
        debugLog(@"Connection Lost");
    }
    
    isNetworkAvailable = newNetworkStatus;
}

#pragma mark - Object Lifecycle

- (id) init {
    
    self = [super init];
    if (self) {
        
        //GPS Initialization
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        locationManager.delegate = self;
        
        currentLocation = [[CLLocation alloc] init];
        
        //Data Handler initialization
        dataHandler = [[DataHandler alloc] init];
        
        //Reachability initialization
        reachability = [[Reachability reachabilityForInternetConnection] retain];
        [reachability startNotifier];
        
        //Register to reachability notifications 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //Default URL
        checkingURL = @"http://www.biometrycloud.com:80/srv/face/getFaceId/";
        
        if ([reachability currentReachabilityStatus] != NotReachable && _storeRequests) {
            
            [self resendCheckingRequests];
        }
    }
    
    return self;
}

- (void) dealloc {
    
    [locationManager release];
    [currentLocation release];
    [dataHandler release];
    [reachability release];
    
    [super dealloc];
}

@end
