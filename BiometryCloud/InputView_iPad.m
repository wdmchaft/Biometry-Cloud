//
//  InputView_iPad.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView_iPad.h"


@implementation InputView_iPad

-(IBAction) buttonPressed: (id)sender
{
    
    NSString *key = [NSString stringWithFormat:@"%d", [(UIButton *)sender tag]];
    
    if ([key isEqualToString:@"11"]) {
        
        [self inputReceived:@""];
    }
    else if ([key isEqualToString:@"10"]) {
    
        [self inputReceived:@"k"];
    }
    else {
    
        [self inputReceived:key];
    }
    
    AudioServicesPlaySystemSound(0x450);
}

#pragma mark - Input Related Methods

- (void) setKeyboard {

    if ([_inputFormat isEqualToString:@"MAIL"]) {

        //Mail keyboard
        showCustomKeyboard = FALSE;
        [_dummyField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    else if ([_inputFormat rangeOfString:@"K"].location != NSNotFound) {
    
        //Rut
        showCustomKeyboard = TRUE;
        kButton.hidden = FALSE;
    }
    else if ([_inputFormat rangeOfString:@"L"].location == NSNotFound) {
    
        //Numbers
        showCustomKeyboard = TRUE;
        kButton.hidden = TRUE;
    }
    else {
    
        //Anything else
        showCustomKeyboard = FALSE;
        [_dummyField setKeyboardType:UIKeyboardTypeDefault];
    }
    
    //Set inputView
    inputExt.hidden = showCustomKeyboard;
}

#pragma mark - Actions

- (void) showAnimated:(BOOL)animated {
    
    [super showAnimated:animated];
    
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    if (showCustomKeyboard) {
        
        //Move keyBoard SubView up
        [customKeyboard setFrame:CGRectMake(customKeyboard.frame.origin.x, customKeyboard.frame.origin.y - customKeyboard.frame.size.height, customKeyboard.frame.size.width, customKeyboard.frame.size.height)];
    }
    else {
    
        [_dummyField becomeFirstResponder];
    }
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}

- (void) hideAnimated:(BOOL)animated {
    
    [super hideAnimated:animated];
    
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    if (showCustomKeyboard) {
        
        //Move keyBoard SubView down
        [customKeyboard setFrame:CGRectMake(customKeyboard.frame.origin.x, customKeyboard.frame.origin.y + customKeyboard.frame.size.height, customKeyboard.frame.size.width, customKeyboard.frame.size.height)];
    }
    else {
    
        [_dummyField resignFirstResponder];
    }
    
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}

#pragma mark - View life cycle

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"InputView_iPad" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        //Set input keyboard
        [self setKeyboard];
        
        //Hide inputView
        [self hideAnimated:FALSE];
        
        //Force keyboard hidding
        if (!showCustomKeyboard) {
            
            [customKeyboard setFrame:CGRectMake(customKeyboard.frame.origin.x, customKeyboard.frame.origin.y + customKeyboard.frame.size.height, customKeyboard.frame.size.width, customKeyboard.frame.size.height)];
        }
    }
    return self;
}

@end
