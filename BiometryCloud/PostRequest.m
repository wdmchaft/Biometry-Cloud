//
//  PostRequest.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostRequest.h"

#import "BiometryCloudConfiguration.h"

@implementation PostRequest

@synthesize didFailSelector, didStartSelector, didFinishSelector, delegate, responseData;

#pragma mark - Lifecycle

- (id) initWithURL:(NSString *) url {

    self = [super init];
    
    if (self) {
        
        //create the URL
        NSURL *URL = [NSURL URLWithString:url];
        request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        
        postData = [[NSMutableArray alloc] init];
        postFiles = [[NSMutableArray alloc] init];
        
        responseData = [[NSMutableData alloc] init];
    }
    
    return self;
}


#pragma mark - Post Methods

- (void) setURL: (NSString *) url {

    //create the URL
    NSURL *URL = [NSURL URLWithString:url];
    
    if (request) {
        
        [request setURL:URL];
    }
    else {
    
        request = [[NSMutableURLRequest alloc] initWithURL:URL];
    }
    [request setHTTPMethod:@"POST"];
}

- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key
{
	if (!contentType) {
		contentType = @"application/octet-stream";
	}
	
	NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", contentType, @"contentType", fileName, @"fileName", key, @"key", nil];
	[postFiles addObject:fileInfo];
}

- (void) addPostValue:(id <NSObject>)value forKey:(NSString *)key
{
    
	[postData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[value description],@"value",key,@"key",nil]];
}

- (void) start
{
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	
	// Set your own boundary string only if really obsessive. We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
	
	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary];
	//NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [[NSMutableData alloc] init];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Adds post data
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    NSUInteger i=0;
    //add values from the postData object
    for (NSDictionary *val in postData) {
        
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",[val objectForKey:@"key"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@",[val objectForKey:@"value"]] dataUsingEncoding:NSUTF8StringEncoding]];
        
        i++;
		if (i != [postData count] || [postFiles count] > 0) { //Only add the boundary if this is not the last item in the post body
			[postBody appendData:[endItemBoundary dataUsingEncoding:NSUTF8StringEncoding]];
		}
    }
    
   
    i = 0;
    for (NSDictionary *val in postFiles) {
        
        //add data field and file data
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [val objectForKey:@"key"], [val objectForKey:@"fileName"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [val objectForKey:@"contentType"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[NSData dataWithData:[val objectForKey:@"data"]]];
        
        i++;
		// Only add the boundary if this is not the last item in the post body
		if (i != [postFiles count]) { 
            
			[postBody appendData:[endItemBoundary dataUsingEncoding:NSUTF8StringEncoding]];
		}
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding] ];
	
	//add the body to the post
	[request setHTTPBody:postBody];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSString *) responseString {

    return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

#pragma mark - NSURLConnection delegate

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    [delegate performSelector:didFailSelector];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    [delegate performSelector:didFinishSelector withObject:self];
}

@end
