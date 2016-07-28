//
//  CSFFacebookAlbum.h
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSFFacebookAlbum : NSObject

@property (nonatomic,strong) NSString *albumId;
@property (nonatomic,strong) NSString *coverPhotoUrl;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *count;

-(id)initWithDictionary:(NSDictionary *)dictionary;
+(CSFFacebookAlbum *)generatePhotosOfMeAlbumWithCount:(NSInteger)count
                                         withCoverUrl:(NSString *)coverUrl;
+(void)fillEmptyFieldsAlbum:(CSFFacebookAlbum *)album fromPhotos:(NSArray *)photos;

@end
