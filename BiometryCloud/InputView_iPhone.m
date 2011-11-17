//
//  InputView_iPhone.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView_iPhone.h"


@implementation InputView_iPhone

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"InputView_iPhone" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        //Hide inputView
        [super hideAnimated:FALSE];
        
        //if (self.k == nil) {
        kButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        // Place the dot in the correct location on the keyboard.
        [kButton setFrame:CGRectMake(0, 163, 106, 53)];
        // Set the overlay graphics. (Use TransDecimalDown.png and TransDecimalUp.png for the Alert Style Keyboard.
        [kButton setImage:[UIImage imageNamed:@"kButtonUp.png"] forState:UIControlStateNormal];
        [kButton setImage:[UIImage imageNamed:@"kButtonDown.png"] forState:UIControlStateHighlighted];
        // Give the dot something to do when pressed.
        [kButton addTarget:self action:@selector(kButtonPressed:)  forControlEvents:UIControlEventTouchUpInside];
        [kButton addTarget:self action:@selector(kButtonSound:)  forControlEvents:UIControlEventTouchDown];
        
        kButton.hidden = TRUE;
    }
    return self;
}

#pragma mark - K button

- (void)showKButton {
    
    if ([kButton isHidden]) {
        
        kButton.hidden = false;
        
        // Step through Every Window currently being displayed and subviews of those Windows.
        for (UIWindow *tempWindow in [[UIApplication sharedApplication] windows]) for (UIView *keyboard in [tempWindow subviews]) {
            // Check and see if those subviews contain a view with the prefix of UIKeyboard (iPhone) or UIPeripheralHostView (iPad Simulator)
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES || [[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES) {
                
                // Make the kButton a subview of the view containing the keyboard.
                [keyboard addSubview:kButton];
                
                // Bring the dot to the front of the keyboard.
                [keyboard bringSubviewToFront:kButton];
            }
        }
    }
}

- (void)hideKButton {
    
    [kButton removeFromSuperview];
    
    kButton.hidden = TRUE;
}

- (void) kButtonPressed:(id) sender {
    
    [super inputReceived:@"k"];
}

- (void) kButtonSound:(id) sender {

    AudioServicesPlaySystemSound(0x450);
}

#pragma mark - Input Related Methods

- (void) nextCharacterType
{
    [super nextCharacterType];
    
    //Set keyboard according to defined format and given input
    NSString *next = [NSString stringWithFormat:@"%c",[_inputFormat characterAtIndex:[_input length]]];
    
    UIKeyboardType prevKeyboard = [_dummyField keyboardType];
    
    if ([next isEqualToString:@"N"]) {
        
        [_dummyField setKeyboardType:UIKeyboardTypeNumberPad];
        
        if (![kButton isHidden]) {
            
            [self hideKButton];
        }
    }
    else if ([next isEqualToString:@"L"]) {
        
        [_dummyField setKeyboardType:UIKeyboardTypeDefault];
    }
    else if ([next isEqualToString:@"K"]) {
        
        //RUT!
        [_dummyField setKeyboardType:UIKeyboardTypeNumberPad];
        [self showKButton];
    }
    
    if (prevKeyboard != [_dummyField keyboardType]) {
        
        [_dummyField resignFirstResponder];
        [_dummyField becomeFirstResponder];
    }
}

#pragma mark - Actions

- (void) showAnimated:(BOOL)animated {

    [super showAnimated:animated];
    
    [_dummyField becomeFirstResponder];
}

- (void) hideAnimated:(BOOL)animated {
    
    [super hideAnimated:animated];
    
    [_dummyField resignFirstResponder];
}

@end
