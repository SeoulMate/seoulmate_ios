//
//  HomeFeedViewController.m
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/8/15.
//
//

#import "HomeFeedViewController.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "PAPAccountViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AddButtonItem.h"
#import "NewBoardPostViewController.h"
#import "NewFeedPostViewController.h"
#import "NewKoreanPostViewController.h"
#import "SettingsViewController.h"

@interface HomeFeedViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UINavigationController *presentingAccountNavController;
@property (nonatomic, strong) UINavigationController *presentingFriendNavController;
@property (nonatomic, strong) UINavigationController *newBoardPostNavController;
@property (nonatomic, strong) UINavigationController *newFeedPostNavController;
@property (nonatomic, strong) UINavigationController *newKoreanPostNavController;
@property (nonatomic, strong) UINavigationController *presentingSettingsNavController;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation HomeFeedViewController
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;


#pragma mark - UIViewController

- (UINavigationController *)presentingAccountNavController {
    if (!_presentingAccountNavController) {
        
        PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithUser:[PFUser currentUser]];
        _presentingAccountNavController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
        
    }
    return _presentingAccountNavController;
}

- (UINavigationController *)presentingFriendNavController {
    if (!_presentingFriendNavController) {
        
        PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] init];
        _presentingFriendNavController = [[UINavigationController alloc] initWithRootViewController:findFriendsVC];

    }
    return _presentingFriendNavController;
}

- (UINavigationController *)newBoardPostNavController {
    if (!_newBoardPostNavController) {
        
        NewBoardPostViewController *newBoardPostVC = [[NewBoardPostViewController alloc] init];
        _newBoardPostNavController = [[UINavigationController alloc] initWithRootViewController:newBoardPostVC];
    }
    return _newBoardPostNavController;
}

- (UINavigationController *)newFeedPostNavController {
    if (!_newFeedPostNavController) {
        
        NewFeedPostViewController *newFeedPostVC = [[NewFeedPostViewController alloc] init];
        _newFeedPostNavController = [[UINavigationController alloc] initWithRootViewController:newFeedPostVC];
    }
    return _newFeedPostNavController;
}

- (UINavigationController *)newKoreanPostNavController {
    if (!_newKoreanPostNavController) {
        
        NewKoreanPostViewController *newKoreanPostVC = [[NewKoreanPostViewController alloc] init];
        _newKoreanPostNavController = [[UINavigationController alloc] initWithRootViewController:newKoreanPostVC];
    }
    return _newKoreanPostNavController;
}

- (UINavigationController *)presentingSettingsNavController {
    if (!_presentingSettingsNavController) {
        
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        _presentingSettingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    }
    return _presentingSettingsNavController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.title = @"Feed / KGSP Scholars";
    
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    self.navigationItem.leftBarButtonItem = [[AddButtonItem alloc] initWithTarget:self action:@selector(addButtonAction:)];
    
//[self.navigationController.view addSubview:yourView];

    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}


#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Settings",@"Log Out", nil];
    actionSheet.tag = 10;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)addButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share with your peers" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Board Post",@"Feed Post",@"Life in Korea", nil];
    actionSheet.tag = 100;
//    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet showFromBarButtonItem: self.navigationItem.leftBarButtonItem  animated:YES];
}


- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == 10) {
        switch (buttonIndex) {
            case 0: {
                [self presentViewController:self.presentingAccountNavController animated:YES completion:nil];
            
                break;
            }
            
            case 1: {
                [self presentViewController:self.presentingSettingsNavController animated:YES completion:nil];
                break;
            }
            
            case 2: {
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            }
            
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0: {
                [self presentViewController:self.newBoardPostNavController animated:YES completion:nil];
                
                break;
            }
                
            case 1: {
                [self presentViewController:self.newFeedPostNavController animated:YES completion:nil];
                break;
            }
                
            case 2: {
                [self presentViewController:self.newKoreanPostNavController animated:YES completion:nil];
                break;
            }
                
            default:
                break;
        }

    }
}

@end