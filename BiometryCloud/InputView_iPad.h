//
//  InputView_iPad.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView.h"

@interface InputView_iPad : InputView {
    
    IBOutlet UIView *customKeyboard;
    BOOL showCustomKeyboard;
    
    IBOutlet UIButton *kButton;
    
    IBOutlet UIView *inputExt;
}

@end
