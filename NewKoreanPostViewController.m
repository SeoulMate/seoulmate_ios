//
//  NewKoreanPostViewController.m
//  SeoulMate
//
//  Created by Hassan Abid on 7/19/15.
//
//

#import "NewKoreanPostViewController.h"
#import <POP/POP.h>
#import <POP/POPLayerExtras.h>
#import "PAPPhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import <Google/Analytics.h>

#define titleY 10.0f
#define baseX 10.0f
#define titleHeight 40.0f
#define titleWidth 300.0f

#define contentY titleHeight+titleY
#define contentX baseX
#define contentHeight 100.0f
#define contentWidth titleWidth

#define tagsY contentHeight+titleHeight
#define tagsHeight titleHeight

#define linkY  tagsY+tagsHeight
#define linkHeight titleHeight

#define imageY linkY+10.0f+linkHeight
#define imageHeight 60.0f
#define imageWidth 60.0f

#define categoryY imageY+imageHeight
#define categoryHeight 40.0f



@interface NewKoreanPostViewController ()
@property (nonatomic) CGFloat popAnimationProgress;
@property (nonatomic) CGFloat composerIsVisibleProgress;
@property (nonatomic) CGFloat feedSlidingProgress;
@property (nonatomic) CGFloat postScalingProgress;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic,strong) UIImageView *photoImageView;
@property (nonatomic,assign) Boolean isEdited;

@end

@implementation NewKoreanPostViewController

@synthesize scrollView;
@synthesize image;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize titleField;
@synthesize contentField;
@synthesize linkField;
@synthesize imagebutton;
@synthesize tagsField;


- (id)initWithImage:(UIImage *)aImage {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.isEdited = NO;
    
    //    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.title = @"Seoul Mate";
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    cancel.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem =  cancel;
    UIImage *send = [UIImage imageNamed:@"iconSend.png"];
    //    UIImage *newImage = [send imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)]; // your image size
    //    imageView.tintColor = [UIColor redColor];
    
    UIBarButtonItem *post = [[UIBarButtonItem alloc] initWithImage:send style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    post.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = post;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self toggleComposerIsVisible:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kAnalyticsNewKoreanVC];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(baseX, imageY, imageWidth, imageHeight)];
    [self.photoImageView setBackgroundColor:[UIColor blackColor]];
    [self.photoImageView setImage:self.image];
    [self.photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.imagebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imagebutton setBackgroundColor:[UIColor clearColor]];
    [self.imagebutton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventAllEvents];
    //    [button setTitle:@"point" forState:UIControlStateNormal];
    [self.imagebutton setBackgroundImage:[UIImage imageNamed:@"iconImage.png"] forState:UIControlStateNormal];
    self.imagebutton.frame = CGRectMake(6.0f, 6.0f, 48.0, 48.0);
    self.photoImageView.userInteractionEnabled = YES;
    [self.photoImageView addSubview:self.imagebutton];
    
    [self.scrollView addSubview:self.photoImageView];
    [self setupTextFields];
    
    CGRect footerRect = [PAPPhotoDetailsFooterView rectForView];
    footerRect.origin.y = self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + imageY)];
}


// popAnimation transition

- (void)togglePopAnimation:(BOOL)on {
    POPSpringAnimation *animation = [self pop_animationForKey:@"popAnimation"];
    
    if (!animation) {
        animation = [POPSpringAnimation animation];
        animation.springBounciness = 10;
        animation.springSpeed = 10;
        animation.property = [POPAnimatableProperty propertyWithName:@"popAnimationProgress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(NewKoreanPostViewController *obj, CGFloat values[]) {
                values[0] = obj.popAnimationProgress;
            };
            prop.writeBlock = ^(NewKoreanPostViewController *obj, const CGFloat values[]) {
                obj.popAnimationProgress = values[0];
            };
            prop.threshold = 0.001;
        }];
        
        [self pop_addAnimation:animation forKey:@"popAnimation"];
    }
    
    animation.toValue = on ? @(1.0) : @(0.0);
}

- (void)setPopAnimationProgress:(CGFloat)progress {
    _popAnimationProgress = progress;
    
    CGFloat transition = POPTransition(progress, 1, 0.8);
    POPLayerSetScaleXY(self.view.layer, CGPointMake(transition, transition));
}

// composerIsVisible transition

- (void)toggleComposerIsVisible:(BOOL)on {
    POPSpringAnimation *animation = [self pop_animationForKey:@"composerIsVisible"];
    
    if (!animation) {
        animation = [POPSpringAnimation animation];
        animation.springBounciness = 1;
        animation.springSpeed = 5;
        animation.property = [POPAnimatableProperty propertyWithName:@"composerIsVisibleProgress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(NewKoreanPostViewController *obj, CGFloat values[]) {
                values[0] = obj.composerIsVisibleProgress;
            };
            prop.writeBlock = ^(NewKoreanPostViewController *obj, const CGFloat values[]) {
                obj.composerIsVisibleProgress = values[0];
            };
            prop.threshold = 0.001;
        }];
        
        [self pop_addAnimation:animation forKey:@"composerIsVisible"];
    }
    
    animation.toValue = on ? @(1.0) : @(0.0);
}

- (void)setComposerIsVisibleProgress:(CGFloat)progress {
    _composerIsVisibleProgress = progress;
    
    CGFloat yPosition = POPTransition(progress, -1,341);
    POPLayerSetTranslationY(self.view.layer, POPPixelsToPoints(-yPosition));
}

// feedSliding transition

- (void)toggleFeedSliding:(BOOL)on {
    POPSpringAnimation *animation = [self pop_animationForKey:@"feedSliding"];
    
    if (!animation) {
        animation = [POPSpringAnimation animation];
        animation.springBounciness = 5;
        animation.springSpeed = 10;
        animation.property = [POPAnimatableProperty propertyWithName:@"feedSlidingProgress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(NewKoreanPostViewController *obj, CGFloat values[]) {
                values[0] = obj.feedSlidingProgress;
            };
            prop.writeBlock = ^(NewKoreanPostViewController *obj, const CGFloat values[]) {
                obj.feedSlidingProgress = values[0];
            };
            prop.threshold = 0.001;
        }];
        
        [self pop_addAnimation:animation forKey:@"feedSliding"];
    }
    
    animation.toValue = on ? @(1.0) : @(0.0);
}

- (void)setFeedSlidingProgress:(CGFloat)progress {
    _feedSlidingProgress = progress;
    
    //    CGFloat pixelsHigh = POPTransition(progress, 2,100);
    //
    //    CGFloat transition2 = POPTransition(progress, 0, 14.0625);
}

// postScaling transition

- (void)togglePostScaling:(BOOL)on {
    POPSpringAnimation *animation = [self pop_animationForKey:@"postScaling"];
    
    if (!animation) {
        animation = [POPSpringAnimation animation];
        animation.springBounciness = 5;
        animation.springSpeed = 10;
        animation.property = [POPAnimatableProperty propertyWithName:@"postScalingProgress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(NewKoreanPostViewController *obj, CGFloat values[]) {
                values[0] = obj.postScalingProgress;
            };
            prop.writeBlock = ^(NewKoreanPostViewController *obj, const CGFloat values[]) {
                obj.postScalingProgress = values[0];
            };
            prop.threshold = 0.001;
        }];
        
        [self pop_addAnimation:animation forKey:@"postScaling"];
    }
    
    animation.toValue = on ? @(1.0) : @(0.0);
}

- (void)setPostScalingProgress:(CGFloat)progress {
    _postScalingProgress = progress;
}

// Utilities

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

static inline CGFloat POPPixelsToPoints(CGFloat pixels) {
    static CGFloat scale = -1;
    if (scale < 0) {
        scale = [UIScreen mainScreen].scale;
    }
    return pixels / scale;
}


- (void)doneButtonAction:(id)sender {

    NSString *trimmedTitle = [self.titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedContent = [self.contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedTags = [self.tagsField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedLink = [self.linkField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedTitle.length == 0 || trimmedContent.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter title & contents of the post" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
        
    }
    if(self.photoImageView.image != nil) {
        [self shouldUploadImage:self.photoImageView.image];
        if (!self.photoFile) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't save your attached photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
    }
    if(self.photoImageView.image == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select a photo first!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *korean = [PFObject objectWithClassName:kPAPKoreanClassKey];
    [korean setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [korean setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [korean setObject:trimmedTitle forKey:@"title"];
    [korean setObject:trimmedContent forKey:@"content"];
    [korean setObject:trimmedLink forKey:@"link"];
    korean[@"tags"] = trimmedTags;
    korean[@"likeCount"] = @0;
    korean[@"commentCount"] = @0;
    
    // board posts are public, but may only be modified by the user who uploaded them
    PFACL *boardACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [boardACL setPublicReadAccess:YES];
    korean.ACL = boardACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [korean saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Life in Korea post is published");
            
            [[PAPCache sharedCache] setAttributesForKorean:korean likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:korean];
        } else {
            NSLog(@"post failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonAction:(id)sender {
    [self togglePostScaling:YES];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    //    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *imageRx = [info objectForKey:UIImagePickerControllerEditedImage];
    self.photoImageView.image = imageRx;
    self.image = imageRx;
    self.imagebutton.hidden = YES;
    
    
    //    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
    //    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    //    [self.navController pushViewController:viewController animated:NO];
    
    //    [self presentViewController:self.navController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)setupTextFields {
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake( baseX, titleY, titleWidth, titleHeight)];
    self.titleField.delegate = self;
    self.titleField .font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleField .placeholder = @"Title of the post";
    self.titleField .returnKeyType = UIReturnKeyDefault;
    self.titleField .textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    self.titleField .contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.titleField  setValue:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.view.frame.size.height - 1, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor redColor].CGColor;
    [self.titleField.layer addSublayer:bottomBorder];
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    //    [[userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.scrollView addSubview:self.titleField];
    
    //    self.contentField = [[UITextField alloc] initWithFrame:CGRectMake( baseX, contentY, contentWidth, contentHeight)];
    self.contentField = [[UITextView alloc] initWithFrame:CGRectMake( baseX, contentY, contentWidth, contentHeight)];
    self.contentField.delegate = self;
    self.contentField.editable = YES;
    self.contentField.text = @"Write content of the post";
    //    self.contentField.delegate = self;
    self.contentField .font = [UIFont systemFontOfSize:16.0f];
    //    self.contentField .placeholder = @"Write contents of the post";
    self.contentField .returnKeyType = UIReturnKeyDefault;
    self.contentField .textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    //    self.contentField .contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.contentField  setValue:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.scrollView addSubview:self.contentField];
    
    self.tagsField = [[UITextField alloc] initWithFrame:CGRectMake( baseX, tagsY, contentWidth, linkHeight)];
    self.tagsField.delegate = self;
    self.tagsField .font = [UIFont systemFontOfSize:14.0f];
    self.tagsField .placeholder = @"Enter comma separated Tags scholarships,jobs etc.";
    self.tagsField .returnKeyType = UIReturnKeyDefault;
    self.tagsField .textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    self.tagsField .contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.tagsField  setValue:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.scrollView addSubview:self.tagsField];
    
    
    self.linkField = [[UITextField alloc] initWithFrame:CGRectMake( baseX, linkY, contentWidth, linkHeight)];
    self.linkField.delegate = self;
    self.linkField .font = [UIFont systemFontOfSize:14.0f];
    self.linkField .placeholder = @"Add a link";
    self.linkField .returnKeyType = UIReturnKeyDefault;
    self.linkField .textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    self.linkField .contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.linkField  setValue:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.scrollView addSubview:self.linkField];
    
}
#pragma mar - UITextFieldDelegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    if(!self.isEdited)
        [self.contentField setText:@""];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    if([self.contentField.text length] == 0 && !self.isEdited) {
        self.contentField.text = @"Write content of the post";
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    self.isEdited = YES;
}


@end
