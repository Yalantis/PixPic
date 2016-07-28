//
//  CSFFacebookPhoto.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSFFacebookPhoto : NSObject

@property(nonatomic,strong) NSString *photoId;
@property(nonatomic,strong) NSArray *images;

-(id)initWithDictionary:(NSDictionary *)dictionary;

-(NSURL *)giveMePleaseUrlForBiggestImage;
-(NSURL *)giveMePleaseUrlForSmallestImage;

@end
