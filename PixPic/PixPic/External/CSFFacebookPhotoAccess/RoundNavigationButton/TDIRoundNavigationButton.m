//
//  TDIRoundNavigationButton.m
//
//  Created by Konstantin Safronov on 9/18/15.
//  Copyright (c) 2015 yalantis. All rights reserved.
//

#import "TDIRoundNavigationButton.h"

static const CGFloat RotateAnimationDuration = 0.3f;

@interface TDIRoundNavigationButton ()

@property (nonatomic,weak) IBOutlet UIButton *button;

@end

@implementation TDIRoundNavigationButton

-(void)setImageName:(NSString *)imageName{
    
    _imageName = imageName;
    [self.button setImage:[UIImage imageNamed:_imageName] forState:UIControlStateNormal];
}

-(IBAction)buttonHandle:(id)sender{
    
    if(self.navigationButtonCallBack){
        self.navigationButtonCallBack();
    }
}

-(void)rotateToOpenState{

    [UIView animateWithDuration:RotateAnimationDuration
                     animations:^{
        self.button.transform = CGAffineTransformMakeRotation(M_PI_2);
    }];
    
}


-(void)rotateToCloseState{
    
    [UIView animateWithDuration:RotateAnimationDuration
                     animations:^{
                         self.button.transform = CGAffineTransformMakeRotation(0.f);
                     }];
}


@end
