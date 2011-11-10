//
//  InputView.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InputFormatterDelegate.h"

@protocol InputViewDelegate

- (void) legalIdAccepted:(NSString *) legal_id;
- (void) legalIdCancelled;

@end

@interface InputView : UIView <UITextFieldDelegate> {
    
    IBOutlet id<InputViewDelegate> delegate;
    
    //Validator delegate
    id<InputFormatterDelegate> _formatterDelegate;
    
    //String to give format to input
    NSMutableString *_inputFormat;
    //Fixed symbols in input
    NSMutableString *_fixedSymbols;
    //Raw input (without symbols)
    NSMutableString *_input;
    
    //IBOutlets
    IBOutlet UIButton *_cancelButton;
    IBOutlet UIButton *_confirmButton;
    IBOutlet UIView *_inputSubView;
    IBOutlet UILabel *_textLabel;
    IBOutlet UILabel *_inputLabel;
    IBOutlet UITextField *_dummyField;
}

@property (nonatomic, assign) id<InputViewDelegate> delegate;
@property (nonatomic, retain) id<InputFormatterDelegate> formatterDelegate;

- (void) showAnimated:(BOOL) animated;
- (void) hideAnimated:(BOOL) animated;

@end
