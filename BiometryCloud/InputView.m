//
//  InputView.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView.h"


@implementation InputView

@synthesize delegate, inputFormat=_inputFormat;

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        //Set default input format (passport number)
        _inputFormat = @"NNNNNNNNN";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Actions

- (IBAction) cancelButtonPressed
{
    
    [self hideAnimated:TRUE];

    [delegate legalIdCancelled];
}

- (IBAction) confirmButtonPressed
{

    [self hideAnimated:TRUE];
    
    [delegate legalIdAccepted:_inputLabel.text];
}

- (void) showAnimated:(BOOL) animated
{
    //Clear input
    _inputLabel.text = @"";
    
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    //Move Input SubView down
    [_inputSubView setFrame:CGRectMake(_inputSubView.frame.origin.x, _inputSubView.frame.origin.y + _inputSubView.frame.size.height, _inputSubView.frame.size.width, _inputSubView.frame.size.height)];
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}

- (void) hideAnimated:(BOOL) animated
{
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    //Move Input SubView up
    [_inputSubView setFrame:CGRectMake(_inputSubView.frame.origin.x, _inputSubView.frame.origin.y - _inputSubView.frame.size.height, _inputSubView.frame.size.width, _inputSubView.frame.size.height)];
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}

#pragma mark - Input Methods

- (void) inputReceived:(NSString *) string {

    //Backspace
    if ([string isEqualToString:@""]) {
        
        if ([_inputLabel.text length]) {
            
            [_inputLabel setText:[_inputLabel.text substringToIndex:[_inputLabel.text length]-1]];
            
        }
    }
    //Anything else
    else {
    
        [_inputLabel setText:[_inputLabel.text stringByAppendingString:string]];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Handle the input
    [self inputReceived:string];
    
    //Keep it always with something to catch backspace
    _dummyField.text = @"n";
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    return NO;
}


@end
