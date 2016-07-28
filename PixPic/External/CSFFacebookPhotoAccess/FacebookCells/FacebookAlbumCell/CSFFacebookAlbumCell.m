//
//  CSFFacebookAlbumCell.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookAlbumCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImageView+WebCache.h"

@interface CSFFacebookAlbumCell ()

@property (nonatomic,strong) IBOutlet UIImageView *albumCoverImageView;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *subTitleLabel;

@end

@implementation CSFFacebookAlbumCell

-(void)setAlbum:(CSFFacebookAlbum *)album{
    
    [self.imageView setImage:nil];
    _album = album;
    [self.titleLabel setText:_album.name];
    
    NSString *photoCountString;
    if([_album.count intValue] > 1){
        photoCountString = NSLocalizedString(@"photos", nil);
    }else{
        photoCountString = NSLocalizedString(@"photo", nil);
    }
    [self.subTitleLabel setText:[NSString stringWithFormat:@"%i %@",[_album.count intValue],photoCountString]];
    [self.albumCoverImageView sd_setImageWithURL:[NSURL URLWithString:_album.coverPhotoUrl] placeholderImage:[UIImage imageNamed:@"placeholder_photo"]];
}

@end
