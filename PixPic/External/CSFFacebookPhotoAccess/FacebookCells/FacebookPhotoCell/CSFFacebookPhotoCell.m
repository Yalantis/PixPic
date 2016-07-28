//
//  CSFFacebookPhotoCell.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookPhotoCell.h"
#import "UIImageView+WebCache.h"

@interface CSFFacebookPhotoCell ()

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *progress;

@end


@implementation CSFFacebookPhotoCell


-(void)setPhoto:(CSFFacebookPhoto *)photo{
    
    _photo = photo;
    [self.photoImageView setImage:nil];
    [self.photoImageView sd_setImageWithURL:[_photo giveMePleaseUrlForSmallestImage]];
}

-(void)showProgress{
    
    [self.progress startAnimating];
}

-(void)hideProgress{
    
    [self.progress stopAnimating];
}

@end
