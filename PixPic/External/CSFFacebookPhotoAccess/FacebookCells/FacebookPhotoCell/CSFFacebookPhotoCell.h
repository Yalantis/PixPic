//
//  CSFFacebookPhotoCell.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSFFacebookPhoto.h"

@interface CSFFacebookPhotoCell : UICollectionViewCell

@property (nonatomic,strong) CSFFacebookPhoto *photo;
@property (nonatomic,strong) IBOutlet UIImageView *photoImageView;

-(void)showProgress;
-(void)hideProgress;

@end
