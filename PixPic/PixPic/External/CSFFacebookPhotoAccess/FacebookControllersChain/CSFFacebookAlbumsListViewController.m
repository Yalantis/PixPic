//
//  CSFFacebookAlbumsListTableViewController.m
//
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "CSFFacebookAlbumsListViewController.h"
#import "CSFFacebookExpandedAlbumCollectionViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CSFFacebookAlbum.h"
#import "CSFFacebookAlbumCell.h"
#import "TDIRoundNavigationButton.h"
#import "PixPic-Swift.h"

static const CGFloat CSFAlbumRequestDelay = 0.5;

@interface CSFFacebookAlbumsListViewController ()

@property (nonatomic,strong) NSArray *facebookAlbums;
@property (nonatomic,assign) NSInteger photosOfMeCount;
@property (nonatomic,strong) NSString *photosOfMeCoverUrl;

@end

@implementation CSFFacebookAlbumsListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.facebookAlbums = [NSArray array];
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self setupBackButton];
    [self setupPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self performSelector:@selector(requestAlbums) withObject:nil afterDelay:CSFAlbumRequestDelay];
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
    
    [self setRefreshControl:[UIRefreshControl new]];
    [self.refreshControl addTarget:self action:@selector(requestAlbums) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor: [UIColor appWhiteColor]];
    [self.refreshControl endRefreshing];
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
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

#pragma mark - Handlers

-(IBAction)cancelHandler:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RequestAlbums

-(void)requestAlbums{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=albums.fields(id,name,picture,count)"
                                                                   parameters:nil];
    __weak typeof(self) weakSelf = self;
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
    
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(error){
            [strongSelf showFBError:error];
            [strongSelf.refreshControl endRefreshing];
            return;
        }
        NSArray *albums = [result valueForKeyPath:@"albums.data"];
        
        [albums enumerateObjectsUsingBlock:^(NSDictionary *albumDictionary, NSUInteger idx, BOOL *stop) {
            
            CSFFacebookAlbum *album = [[CSFFacebookAlbum alloc] initWithDictionary:albumDictionary];
            if([album.count intValue] > 0){
                [tempArray addObject:album];
            }
        }];
        
        self.facebookAlbums = tempArray;
        
        if(tempArray.count){
            CSFFacebookAlbum *album = [CSFFacebookAlbum generatePhotosOfMeAlbumWithCount:self.photosOfMeCount
                                                                            withCoverUrl:self.photosOfMeCoverUrl];
            [tempArray insertObject:album atIndex:0];
        }
        [self requestPhotosOfMe];
    }];
}

-(void)requestPhotosOfMe{
    
    __weak typeof(self) weakSelf = self;
    FBSDKGraphRequest *photosOfMeRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/tagged?fields=name,images,id&limit=10000"
                                                                             parameters:nil];
    [photosOfMeRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(error){
            [strongSelf showFBError:error];
            [strongSelf.refreshControl endRefreshing];
            return;
        }
        NSArray *photos = [result objectForKey:@"data"];
        if (strongSelf.facebookAlbums.count) {
            if (photos.count) {
                CSFFacebookAlbum *album = [strongSelf.facebookAlbums objectAtIndex:0];
                [CSFFacebookAlbum fillEmptyFieldsAlbum:album fromPhotos:photos];
                strongSelf.photosOfMeCount = album.count.integerValue;
                strongSelf.photosOfMeCoverUrl = album.coverPhotoUrl;
            }
            [strongSelf.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)showFBError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error.userInfo objectForKey:kCFErrorLocalizedFailureReasonKey]
                                                    message:[error.userInfo objectForKey:kCFErrorLocalizedDescriptionKey]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.facebookAlbums ? [self.facebookAlbums count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSFFacebookAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSFFacebookAlbumCell" forIndexPath:indexPath];
    [cell setAlbum:[self.facebookAlbums objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CSFFacebookAlbumCell *)cell{
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self.tableView deselectRowAtIndexPath:path animated:YES];
    [self prepareSequeForController:[segue destinationViewController] sender:cell];
}

-(void)prepareSequeForController:(CSFFacebookExpandedAlbumCollectionViewController *)controller
                          sender:(CSFFacebookAlbumCell *)cell{
    
    controller.albumId = cell.album.albumId;
    controller.albumName = cell.album.name;
    [controller setSuccessfulCropWithImageView:^(UIImageView *imageView) {
        if(self.successfulCropWithImageView){
            self.successfulCropWithImageView(imageView);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end