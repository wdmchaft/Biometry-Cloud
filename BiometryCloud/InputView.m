//
//  InputView.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView.h"

#import "RutFormatter.h"

@implementation InputView

@synthesize delegate, formatterDelegate = _formatterDelegate;

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        //Init strings
        _inputFormat = [[NSMutableString alloc] init];
        _fixedSymbols = [[NSMutableString alloc] init];
        _input = [[NSMutableString alloc] init];
        
        //Assign default validator
        [self setFormatterDelegate:[[RutFormatter alloc] init]];
    }
    return self;
}

- (void)dealloc
{
    
    
    [super dealloc];
}

#pragma mark - Input Related Methods

- (void) inputReceived:(NSString *) string {
    
    //Backspace
    if ([string isEqualToString:@""]) {
        
        if ([_input length]) {
            
            [_input setString:[_input substringToIndex:[_input length]-1]];
            
        }
    }
    //Anything else --> don't restrict lenght for mail
    else if ([_input length] < [_inputFormat length] || [_inputFormat isEqualToString:@"MAIL"]) {
    
        //Avoid rut with double k
        if ([_input length]) {
            
            if (!([[_input substringFromIndex:[_input length]-1] isEqualToString:@"k"] && [[_formatterDelegate getInputName] isEqualToString:@"rut"])){
            
                [_input appendString:string];
            }
        }
        else {
        
            [_input appendString:string];
        }
    }
    
    //MAIL special case, direct input
    if ([_inputFormat isEqualToString:@"MAIL"]) {
        
        _inputLabel.text = _input;
    }
    else {
    
        //Clear input label
        _inputLabel.text = @"";
        
        //Aux string
        NSString *auxInput = _input;
        
        //Combine input with symbols
        NSString *regex = @"[\\s]";   
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        for (int i = 1; i <= [_fixedSymbols length]; i++) {
            
            NSString *next = [NSString stringWithFormat:@"%c",[_fixedSymbols characterAtIndex:[_fixedSymbols length] - i]];
            
            if ([test evaluateWithObject:next] && [auxInput length]) {
                
                _inputLabel.text = [[NSString stringWithFormat:@"%c",[auxInput characterAtIndex:[auxInput length] -1]] stringByAppendingString:_inputLabel.text];
                
                if ([auxInput length] > 1) {
                    
                    auxInput = [auxInput substringToIndex:[auxInput length]-1];
                }
                else {
                    
                    auxInput = @"";
                }
                
            }
            else {
                
                _inputLabel.text = [next stringByAppendingString:_inputLabel.text];
            }
        }

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

#pragma mark - Actions

- (IBAction) cancelButtonPressed
{
    
    [self hideAnimated:TRUE];
    
    [delegate legalIdCancelled];
}

- (IBAction) confirmButtonPressed
{
    if ([_formatterDelegate isInputValid:_inputLabel.text]) {
        
        [self hideAnimated:TRUE];
        
        [delegate legalIdAccepted:_inputLabel.text];
    }
    else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"El %@ ingresado es incorrecto", [_formatterDelegate getInputName]] delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void) showAnimated:(BOOL) animated
{
    //Reset input
    [_inputLabel setText:_fixedSymbols];
    [_input setString:@""];
    
    //Set textLabel
    _textLabel.text = [NSString stringWithFormat:@"%@ %@:", NSLocalizedString(@"input_text", @"Input Instruction"), [_formatterDelegate getInputName]];
    
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

#pragma mark - Getters and Setters

- (void) setInputFormat:(NSString *)inputFormat {

    if ([inputFormat isEqualToString:@"MAIL"]) {
        
        [_inputFormat setString:inputFormat];
        [_fixedSymbols  setString:@""];
    }
    else {
    
        [_inputFormat setString:@""];
        [_fixedSymbols  setString:@""];
        
        NSString *regex = @"[A-Z0-9a-z]";   
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        for (int i = 0; i < [inputFormat length]; i++) {
            
            NSString *next = [NSString stringWithFormat:@"%c",[inputFormat characterAtIndex:i]];
            
            if ([test evaluateWithObject:next]) {
                
                [_fixedSymbols appendString:@" "];
                [_inputFormat appendString:next];
            }
            else {
                
                [_fixedSymbols appendString:next];
            }
        }
    }
    
    [_inputLabel setText:_fixedSymbols];
}

- (void) setFormatterDelegate:(id<InputFormatterDelegate>)formatterDelegate {
    
    [self setInputFormat:[formatterDelegate getInputFormat]];
    
    _formatterDelegate = formatterDelegate;
}

@end
