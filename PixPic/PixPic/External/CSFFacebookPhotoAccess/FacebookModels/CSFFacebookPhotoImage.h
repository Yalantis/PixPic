//
//  CSFFacebookPhotoImage.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSFFacebookPhotoImage : NSObject


@property(nonatomic,strong) NSString *width;
@property(nonatomic,strong) NSString *height;
@property(nonatomic,strong) NSString *source;


-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
