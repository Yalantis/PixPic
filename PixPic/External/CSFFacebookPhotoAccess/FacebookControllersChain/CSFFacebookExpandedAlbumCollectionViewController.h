//
//  CSFFacebookExpandedAlbumCollectionViewController.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSFFacebookExpandedAlbumCollectionViewController : UICollectionViewController

@property (nonatomic,strong) NSString *albumId;
@property (nonatomic,strong) NSString *albumName;
@property (nonatomic,assign) BOOL photosOfMe;
@property (nonatomic, copy) void (^successfulCropWithImageView)(UIImageView * imageView);

@end
