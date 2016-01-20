//
//  KoreanDetailsViewController.m
//  SeoulMate
//
//  Created by Hassan Abid on 7/12/15.
//
//

#import "KoreanDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPActivityCell.h"
#import "BoardDetailsFooterView.h"
#import "PAPConstants.h"
#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SVWebViewController.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};


@interface KoreanDetailsViewController ()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) KoreanDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@end

static const CGFloat kPAPCellInsetWidth = 0.0f;

@implementation KoreanDetailsViewController

@synthesize commentTextField;
@synthesize photo,korean, headerView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}


- (id)initWithKorean:(PFObject *)aPhoto korean:(PFObject *)aKorean {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityKoreanClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.photo = aPhoto;
        self.korean = aKorean;
        
        self.likersQueryInProgress = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Set table header
    PFFile *imageFile = [self.photo objectForKey:kPAPPhotoPictureKey];
    if ([imageFile isEqual:[NSNull null]]) {
        self.headerView = [[KoreanDetailsHeaderView alloc] initWithFrame:[KoreanDetailsHeaderView rectForViewWithoutImage] photo:self.photo];
    } else {
        if([imageFile url]) {
            self.headerView = [[KoreanDetailsHeaderView alloc] initWithFrame:[KoreanDetailsHeaderView rectForView] photo:self.photo];
        } else {
            self.headerView = [[KoreanDetailsHeaderView alloc] initWithFrame:[KoreanDetailsHeaderView rectForViewWithoutImage] photo:self.photo];
        }
    }
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    BoardDetailsFooterView *footerView = [[BoardDetailsFooterView alloc] initWithFrame:[BoardDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:25.0f/255.0f green:188.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:124.0/255.0f green:77.0/255.0f blue:255.0/255.0f alpha:1.0f];
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kAnalyticsKoreanDetailsVC];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForKorean:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kPAPActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            
            return [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
        }
    }
    
    // The pagination row
    return 44.0f;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityKoreanKey equalTo:self.korean];
    [query includeKey:kPAPActivityFromUserKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [query orderByAscending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";
    
    // Try to dequeue a cell and create one if necessary
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPageDetails";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.korean objectForKey:kPAPPhotoUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityKoreanClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.korean objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.korean forKey:kPAPActivityKoreanKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.korean objectForKey:kPAPPhotoUserKey]];
        [ACL setWriteAccess:YES forRoleWithName:@"Moderators"];
        [ACL setWriteAccess:YES forRoleWithName:@"Administrator"];
        comment.ACL = ACL;
        
        [[PAPCache sharedCache] incrementCommentCountForKorean:self.korean];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        //        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
        
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error && error.code == kPFErrorObjectNotFound) {
                [[PAPCache sharedCache] decrementCommentCountForKorean:self.photo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This korean post is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.korean userInfo:@{@"comments": @(self.objects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            // prompt to delete
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this post?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete post", nil) otherButtonTitles:nil];
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else if(buttonIndex == 1) {
            [self activityButtonAction:actionSheet];
        } else if (buttonIndex == 2) {
             NSLog(@"Report - : %@", @"Add method for offensive report");
            [self sendOffensiveReport];
        } else {
             NSLog(@"Actionsheet - : %@", @"cancel");
        }
    } else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldDeletePhoto];
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - KoreanDetailsHeaderViewDelegate

- (void)koreanDetailsHeaderView:(KoreanDetailsHeaderView *)headerView didTapReadMoreButton:(UIButton *)button {
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[self.photo objectForKey:@"link"]];
    [self.navigationController pushViewController:webViewController animated:YES];

}

-(void)koreanDetailsHeaderView:(KoreanDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete Post", nil)];
    if (NSClassFromString(@"UIActivityViewController")) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share Post", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Report as Offensive", nil)];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)activityButtonAction:(id)sender {
    if ([[self.photo objectForKey:kPAPPhotoPictureKey] isDataAvailable]) {
        [self showShareSheet];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                [self showShareSheet];
            }
        }];
    }
}


#pragma mark - ()

- (void)showShareSheet {
    [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
             [activityItems addObject:[self.photo objectForKey:@"title"]];
            // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
//            if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]] && [self.objects count] > 0) {
//                PFObject *firstActivity = self.objects[0];
//                if ([[[firstActivity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]]) {
//                    NSString *commentString = [firstActivity objectForKey:kPAPActivityContentKey];
//                    [activityItems addObject:commentString];
//                }
//            }
            
            [activityItems addObject:[UIImage imageWithData:data]];
            [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://seoulmateapp.co/lifeinkorea/%@", self.photo.objectId]]];
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    NSLog(@"Presenting account view controller with user: %@", user);
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }
    
    self.likersQueryInProgress = YES;
    PFQuery *query = [PAPUtility queryForActivitiesOnKorean:korean cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            NSLog(@"error while fetching activities: %@", error);
            [self.headerView reloadLikeBar];
            return;
        }
        NSLog(@"activity objects : %lu", (unsigned long)objects.count);
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                NSLog(@"likers added %@", @" -- ");
                
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                NSLog(@"commenters added %@", @" -- ");
            }
            
            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[PAPCache sharedCache] setAttributesForKorean:korean likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

- (BOOL)currentUserOwnsPhoto {
    return [[[self.korean objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityKoreanClassKey];
    [query whereKey:kPAPActivityKoreanKey equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.photo deleteEventually];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendOffensiveReport {
    
    PFObject *report = [PFObject objectWithClassName:kReportKoreanClassKey];
    [report setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
    [report setObject:@"post" forKey:kPAPActivityTypeKey];
    [report setObject:self.korean forKey:kPAPActivityKoreanKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
//    [ACL setWriteAccess:true forRoleWithName:@"Moderators"];
//    [ACL setWriteAccess:true forRoleWithName:@"Administrator"];
    [ACL setWriteAccess:YES forUser:[self.korean objectForKey:kPAPPhotoUserKey]];
    report.ACL = ACL;
    
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    
    
    [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error && error.code == kPFErrorObjectNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not report this post", nil) message:NSLocalizedString(@"Some thing went wrong. Please try again later", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You have successfully reported this post", nil) message:NSLocalizedString(@"Admins/Moderators will review it within 24 hours and let you know outcome!", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
        [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
        [self loadObjects];
    }];
}

@end
