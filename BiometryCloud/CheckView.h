//
//  CheckView.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckViewDelegate

- (void) checkViewDone;

@end

@interface CheckView : UIView {
    
    IBOutlet id<CheckViewDelegate> __unsafe_unretained delegate;
    
    IBOutlet UIImageView *iconImage;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIView *indicatorView;
    IBOutlet UIImageView *faceImage;
    
    UIColor *defaultColor;
}

@property (nonatomic, unsafe_unretained) id<CheckViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *faceImage;

- (void) showCheckViewForFace:(UIImage *) face inTimeStamp:(NSString *) time waitingForAnswer:(BOOL) wait;

- (void) answerReceived:(NSDictionary *) answer;

@end
