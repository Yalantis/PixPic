//
//  CSFFacebookAlbumsListTableViewController.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSFFacebookAlbumsListViewController : UITableViewController

@property (nonatomic, copy) void (^successfulCropWithImageView)(UIImageView * imageView);
@property (nonatomic, copy) void (^fbAlbumsNeedsToDissmiss)();

@end
