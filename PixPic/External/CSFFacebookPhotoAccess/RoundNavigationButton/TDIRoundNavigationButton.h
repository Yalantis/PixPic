//
//  TDIRoundNavigationButton.h
//
//  Created by Konstantin Safronov on 9/18/15.
//  Copyright (c) 2015 yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDIRoundNavigationButton : UIView

@property (nonatomic,strong) NSString *imageName;
@property (nonatomic, copy) void (^navigationButtonCallBack)();

-(void)rotateToOpenState;
-(void)rotateToCloseState;


@end
