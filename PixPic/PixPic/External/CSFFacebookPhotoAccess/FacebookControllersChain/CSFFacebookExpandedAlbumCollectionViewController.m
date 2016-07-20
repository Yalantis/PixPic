//
//  CSFFacebookExpandedAlbumCollectionViewController.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookExpandedAlbumCollectionViewController.h"
#import "CSFFacebookPhotoCell.h"
#import "CSFFacebookPhoto.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "VPImageCropperViewController.h"
#import "TDIRoundNavigationButton.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CSFConstants.h"
#import "PixPic-Swift.h"

static const float TopPaddingForImageToCrop = 100.f;
static const float ScaleRatioForImageToCrop = 3.f;
static const float DefaultScreenWidth = 320.f;
static const float DefaultCellSide = 79.f;
static const CGFloat CSFPhotosRequestDelay = 0.4;

@interface CSFFacebookExpandedAlbumCollectionViewController ()<VPImageCropperDelegate>

@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *imageViewToCrop;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,assign) CGFloat cellSide;
@property (nonatomic,assign) CGFloat startYOffset;

@end

@implementation CSFFacebookExpandedAlbumCollectionViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.dataSource = [NSMutableArray array];
    
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self setupBackButton];
    [self setupCorrectCellSize];
    [self setupPullToRefresh];
    if([self.albumId isEqualToString:CSFPhotosOfMeAlbumId]){
      [self requestPhotosOfMe];
    }else{
      [self requestPhotos];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self setTitle:self.albumName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.navigationController.navigationBar.subviews) {
        for(UIView *view in self.navigationController.navigationBar.subviews) {
            view.exclusiveTouch = YES;
        }
    }
}

#pragma mark - SetupPullToRefresh

-(void)setupPullToRefresh{
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(requestPhotos) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor: [UIColor appWhiteColor]];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl endRefreshing];
    [self setupOffsetForStateLoading:YES];
}

-(void)setupOffsetForStateLoading:(BOOL)loading{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat barsHeight = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
    CGFloat offsetHeight = loading ? -barsHeight - self.refreshControl.frame.size.height : -barsHeight;
    [self.collectionView setContentOffset:CGPointMake(0.f, offsetHeight) animated:YES];
    SEL selector = loading ? @selector(beginRefreshing) : @selector(endRefreshing);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.refreshControl performSelector:selector];
#pragma clang diagnostic pop
}
- (void)hidePullToRefresh{
    [self setupOffsetForStateLoading:NO];
}

#pragma mark - SetupBackButton

- (void)setupBackButton{
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:UIImage.appBackButton
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

-(void)navigateBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupCorrectCellSize{
    
    CGFloat sizeRatio = [UIScreen mainScreen].bounds.size.width / DefaultScreenWidth;
    self.cellSide = DefaultCellSide * sizeRatio;
}

-(void)requestPhotos{
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"%@/photos?fields=name,images,id&limit=10000",self.albumId]
                                                                   parameters:nil];
    __weak typeof(self) weakSelf = self;
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(error){
            [strongSelf showFBError:error];
            [strongSelf.refreshControl endRefreshing];
            return;
        }
        [strongSelf handlePhotoResult:result];
    }];
}

-(void)requestPhotosOfMe{
    
    FBSDKGraphRequest *photosOfMeRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/tagged?fields=name,images,id&limit=10000"
                                                                   parameters:nil];
    __weak typeof(self) weakSelf = self;
    [photosOfMeRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(error){
            [strongSelf showFBError:error];
            [strongSelf.refreshControl endRefreshing];
            return;
        }
        
        [strongSelf handlePhotoResult:result];
        
    }];
}

-(void)showFBError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error.userInfo objectForKey:kCFErrorLocalizedFailureReasonKey]
                                                    message:[error.userInfo objectForKey:kCFErrorLocalizedDescriptionKey]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

-(void)handlePhotoResult:(id)result{
    
    NSArray *photos = [result objectForKey:@"data"];
    NSMutableArray *tempArray = [NSMutableArray array];
    [photos enumerateObjectsUsingBlock:^(NSDictionary *photoDictionary, NSUInteger idx, BOOL *stop) {
        
        [tempArray addObject:[[CSFFacebookPhoto alloc] initWithDictionary:photoDictionary]];
    }];
    [self performSelector:@selector(hidePullToRefresh) withObject:nil afterDelay:CSFPhotosRequestDelay];
    self.dataSource = [NSArray arrayWithArray:tempArray];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource ? [self.dataSource count] : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSFFacebookPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSFFacebookPhotoCell"
                                                                           forIndexPath:indexPath];
    [cell setPhoto:[self.dataSource objectAtIndex:indexPath.item]];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(self.cellSide, self.cellSide);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    CSFFacebookPhotoCell *cell = (CSFFacebookPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell showProgress];
    [self prepareImageToCropForCellAtIndexPath:indexPath];
}

-(void)prepareImageToCropForCellAtIndexPath:(NSIndexPath *)indexPath{
    
    CSFFacebookPhotoCell *cell = (CSFFacebookPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    self.imageViewToCrop = [[UIImageView alloc] initWithFrame:self.collectionView.bounds];
    [self.imageViewToCrop setContentMode:UIViewContentModeScaleAspectFit];
    
    __block CGRect targetFrame = [self.collectionView convertRect:cell.photoImageView.frame
                                                  fromView:cell.photoImageView];
    
    __weak CSFFacebookExpandedAlbumCollectionViewController *weakSelf = self;
    [self.imageViewToCrop sd_setImageWithURL:[cell.photo giveMePleaseUrlForBiggestImage]
                            placeholderImage:nil
                                     options:SDWebImageProgressiveDownload
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if(!error){
                                           [weakSelf showCropControllerWithImage:image fromFrame:targetFrame];
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [cell hideProgress];
                                       });

                                   }];
}

-(void)showCropControllerWithImage:(UIImage *)image fromFrame:(CGRect)frame{
    
    CGRect frameForImageToCrop = CGRectMake(0.f,
                                            TopPaddingForImageToCrop,
                                            self.view.frame.size.width,
                                            self.view.frame.size.width);
    
    VPImageCropperViewController *croperViewController = [[VPImageCropperViewController alloc] initWithImage:image
                                                                                           cropFrame:frameForImageToCrop
                                                                                     limitScaleRatio:ScaleRatioForImageToCrop];
    [croperViewController setDelegate:self];
    //[croperViewController setInitialFrame:frame];
    [croperViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:croperViewController animated:YES completion:nil];
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    [self.imageViewToCrop setImage:editedImage];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        if(self.successfulCropWithImageView){
            self.successfulCropWithImageView(self.imageViewToCrop);
        }
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end