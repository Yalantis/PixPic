//
//  CSFFacebookAlbum.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookAlbum.h"
#import "CSFConstants.h"

@implementation CSFFacebookAlbum


-(id)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    if(self){
        self.count = [dictionary objectForKey:@"count"];
        self.name = [dictionary objectForKey:@"name"];
        self.coverPhotoUrl = [dictionary valueForKeyPath:@"picture.data.url"];
        self.albumId = [dictionary objectForKey:@"id"];
    }
    
    return self;
}

+ (CSFFacebookAlbum *)generatePhotosOfMeAlbumWithCount:(NSInteger)count
                                         withCoverUrl:(NSString *)coverUrl{
    CSFFacebookAlbum *album = [CSFFacebookAlbum new];
    album.name = @"Photos of me";
    album.albumId = CSFPhotosOfMeAlbumId;
    album.count = [NSString stringWithFormat:@"%li",(long)count];
    album.coverPhotoUrl = coverUrl;
    return album;
}

+ (void)fillEmptyFieldsAlbum:(CSFFacebookAlbum *)album fromPhotos:(NSArray *)photos{
    album.count = [NSString stringWithFormat:@"%li",(unsigned long)photos.count];
    NSDictionary *photo = [photos objectAtIndex:0];
    NSArray *images = [photo objectForKey:@"images"];
    if(images.count){
        album.coverPhotoUrl = [[images objectAtIndex:0] objectForKey:@"source"];
    }
}

@end
