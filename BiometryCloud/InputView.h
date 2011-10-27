//
//  InputView.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewDelegate

- (void) legalIdAccepted:(NSString *) legal_id;
- (void) legalIdCancelled;

@end

@interface InputView : UIView {
    
    id<InputViewDelegate> *delegate;
    
    //String to give format to input
    NSString *inputFormat;
}

@property (nonatomic, assign) id<InputViewDelegate> *delegate;

@end
