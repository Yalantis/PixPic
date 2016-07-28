//
//  CSFFacebookPhoto.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookPhoto.h"
#import "CSFFacebookPhotoImage.h"

@implementation CSFFacebookPhoto

-(id)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    if(self){
        self.photoId = [dictionary objectForKey:@"id"];
        NSMutableArray *tempArray = [NSMutableArray array];
        [[dictionary objectForKey:@"images"] enumerateObjectsUsingBlock:^(NSDictionary *image, NSUInteger idx, BOOL *stop) {
            [tempArray addObject:[[CSFFacebookPhotoImage alloc] initWithDictionary:image]];
        }];
        self.images = [NSArray arrayWithArray:tempArray];
    }
    return self;
}

-(NSURL *)giveMePleaseUrlForBiggestImage{
    return [self imageUrlForSizeInPredicateCriteria:@"@max.width"];
}

-(NSURL *)giveMePleaseUrlForSmallestImage{
    return [self imageUrlForSizeInPredicateCriteria:@"@min.width"];
}

-(NSURL *)imageUrlForSizeInPredicateCriteria:(NSString *)criteria{
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.width == %@.%@",self.images,criteria];
    NSArray *filteredArray = [self.images filteredArrayUsingPredicate:predicate];
    CSFFacebookPhotoImage *photoImage = [filteredArray lastObject];
    return [NSURL URLWithString:photoImage.source];
}

@end