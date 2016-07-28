//
//  CSFFacebookPhotoImage.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookPhotoImage.h"

@implementation CSFFacebookPhotoImage

-(id)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    if(self){
        
        self.width = [dictionary objectForKey:@"width"];
        self.height = [dictionary objectForKey:@"height"];
        self.source = [dictionary objectForKey:@"source"];
    }
    
    return self;
}



@end
