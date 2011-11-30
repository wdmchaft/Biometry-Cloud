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

    [request setURL:checkingURL];
    
	[request setDidFinishSelector:@selector(checkingRequestFinished:)];
	[request setDidFailSelector:@selector(checkingRequestFailed)];
    
	[request addData:[NSData dataWithData:UIImageJPEGRepresentation(request.face, 0.9)]
        withFileName:@"photo.jpg"
      andContentType:@"image/jpeg"
              forKey:@"data"];
    
    [request addPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device"];
    [request addPostValue:[NSNumber numberWithDouble:request.lat] forKey:@"lat"];
    [request addPostValue:[NSNumber numberWithDouble:request.lng] forKey:@"lng"];
    //--> ESTOS 2 PARAMETROS NO SON TOMADOS EN CUENTA POR BIOMETRYCLOUD
    [request addPostValue:[NSString stringWithString:request.time] forKey:@"time"];
    [request addPostValue:[NSString stringWithString:request.legal_id] forKey:@"legal_id"];
    
    //PARAMS
    [request addPostValue:@"1" forKey:@"distanceType"];
    [request addPostValue:@"LBP" forKey:@"algorithm"];
    [request addPostValue:@"DEMO" forKey:@"app"]; //--> DEMO POR MIENTRAS
    
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
    
    //Queue only if there are no queued requests
    if(!_storeRequests  || !connectionActive) {
    
        [self setCheckingRequestParams:request];
        
        [request performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        
        connectionActive = TRUE;
    }
    else {
    
        [request release];
    }
}

-(void) sendStoredCheckingRequest:(CheckingRequest *) request
{	
    [self setCheckingRequestParams:request];
    
    [request start];
    
    connectionActive = TRUE;
    
    debugLog(@"Stored checking request created");
}

- (void) checkingRequestStarted:(CheckingRequest *)request {
    
    debugLog(@"Starting checking request");
}

- (void) checkingRequestFinished:(CheckingRequest *)request {
    
    connectionActive = FALSE;
    
    NSString *resp = [request responseString];
    
    debugLog(@"Checking reply received: %@", resp);
    
    [resp release];
    
    NSDictionary *answerDict = [self parseJSONCheckingData:[request responseData]];
    
    if ([delegate isRequestAnswerRequired]) {
        
        [delegate checkingRequestAnswerReceived:answerDict];
    }
    else if (answerDict != nil && _storeRequests) {
        
        [dataHandler deleteCheckingRequest:request];
    }
    
    
    if (_storeRequests) {
        
        //Try to send stored requests
        [self performSelector:@selector(resendCheckingRequests) withObject:nil afterDelay:2];
    }
    
    [request release];
}

- (void) checkingRequestFailed {
	
    connectionActive = FALSE;
    
    if ([delegate isRequestAnswerRequired]) {
        
        NSDictionary *answer = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:@"FAIL"] forKeys:[NSArray arrayWithObject:@"debug"]];
        
        [delegate checkingRequestAnswerReceived:answer];
    }
    else if([reachability currentReachabilityStatus] != NotReachable && _storeRequests) {
        
        [self performSelector:@selector(resendCheckingRequests) withObject:nil afterDelay:2];
    }
    //If no answer required and there's no internet connection, the request isn't deleted from database
    else {
        
        debugLog(@"Checking request failed");
    }
}

- (void) resendCheckingRequests {
    
    int n = [dataHandler areCheckingRequestsQueued];
    
    //Queue next request only if there are no requests active
    if (n && !connectionActive) {
        
        NSMutableArray *array = [dataHandler getNCheckingRequests:1];
        
        debugLog(@"%d stored checking requests, sending next", n);
        
        for (CheckingRequest *request in array) {
            
            [self sendStoredCheckingRequest:request];
        }
        
        [array release];
    }
    else if (!n) {
        
        debugLog(@"No stored checking requests to send");
    }
    else {
    
        debugLog(@"%d stored checking requests, one active", n);
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
        if (_storeRequests) {
            
            [self resendCheckingRequests];
        }
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
        
        //Register to reachability notifications 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //Reachability initialization
        reachability = [[Reachability reachabilityForInternetConnection] retain];
        [reachability startNotifier];
        
        //Default URL
        checkingURL = @"http://www.biometrycloud.com:80/srv/face/getFaceId/";
        
        //Resend stored checking requests
        [self resendCheckingRequests];
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
