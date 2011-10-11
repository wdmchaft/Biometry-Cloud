//
//  CameraViewController_iPhone.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController_iPhone.h"


@implementation CameraViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startCapture 
{
    [super startCapture];
}

-(void) initCapture 
{
    [super initCapture];
    //CHANGE THIS TO SEE YOUR IMAGE BIGGER OR SMALLER ON THE SCREEN .. MIRROR EFFECT
    // con frameSize > viewSize / 2.5
    // 1.4 =  75cm en iPad
    // 1.6 =  90cm en iPad 
    // 1.7 = 105cm en iPad
    
    float scale = 1.3; //This var should be parametrisable
    
    previewLayer.transform = CATransform3DMakeScale(scale, scale, 0);
    
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    
    [cameraView.layer addSublayer:previewLayer];
    
	/*We start the capture*/
	[self startCapture];
	[cameraView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];

}

@end
