//
//  SettingsViewController.m
//  SeoulMate
//
//  Created by Hassan Abid on 7/28/15.
//
//

#import "SettingsViewController.h"
#import <POP/POP.h>
#import <POP/POPLayerExtras.h>
#import "PAPPhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"



#define baseX 10.0f

#define contentY 15.0f
#define contentX baseX
#define contentHeight 140.0f
#define contentWidth 300.0f


#define imageY contentY+10.0f+contentHeight
#define imageHeight 60.0f
#define imageWidth 60.0f

#define categoryY imageY+imageHeight
#define categoryHeight 40.0f



@interface SettingsViewController ()
@property (nonatomic) CGFloat popAnimationProgress;
@property (nonatomic) CGFloat composerIsVisibleProgress;
@property (nonatomic) CGFloat feedSlidingProgress;
@property (nonatomic) CGFloat postScalingProgress;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic,strong) UIImageView *photoImageView;
@property (nonatomic,assign) NSInteger category;
@property (nonatomic,assign) Boolean isEdited;

@end

@implementation SettingsViewController

@synthesize scrollView;
@synthesize image;
@synthesize photoFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize contentField;
@synthesize imagebutton;
//@synthesize category;


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
    self.category = 0;
    self.isEdited = NO;
    [self.navigationItem setHidesBackButton:YES];
    
    //    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.title = @"Settings";
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    cancel.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem =  cancel;
    
    UIBarButtonItem *post = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    post.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = post;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self toggleComposerIsVisible:animated];
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    self.scrollView.delegate = self;
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
    
//    [self.scrollView addSubview:self.photoImageView];
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
            prop.readBlock = ^(SettingsViewController *obj, CGFloat values[]) {
                values[0] = obj.popAnimationProgress;
            };
            prop.writeBlock = ^(SettingsViewController *obj, const CGFloat values[]) {
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
            prop.readBlock = ^(SettingsViewController *obj, CGFloat values[]) {
                values[0] = obj.composerIsVisibleProgress;
            };
            prop.writeBlock = ^(SettingsViewController *obj, const CGFloat values[]) {
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
            prop.readBlock = ^(SettingsViewController *obj, CGFloat values[]) {
                values[0] = obj.feedSlidingProgress;
            };
            prop.writeBlock = ^(SettingsViewController *obj, const CGFloat values[]) {
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
            prop.readBlock = ^(SettingsViewController *obj, CGFloat values[]) {
                values[0] = obj.postScalingProgress;
            };
            prop.writeBlock = ^(SettingsViewController *obj, const CGFloat values[]) {
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

    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentUniversity = [defaults integerForKey:@"university"];
    [defaults setInteger:self.category forKey:@"university"];
    
    
    if (currentUniversity == self.category) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        return;
        
    }
    
    PFObject *feed = [PFObject objectWithClassName:@"MyUniversity"];
    [feed setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [feed setObject:[NSNumber numberWithInteger:self.category] forKey:@"position"];
    [feed setObject:[self setUniversityName:self.category] forKey:@"title"];
    
    // board posts are public, but may only be modified by the user who uploaded them
    PFACL *feedACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [feedACL setPublicReadAccess:YES];
    feed.ACL = feedACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // First check for the exisitng University
    
    PFQuery *query = [PFQuery queryWithClassName:@"MyUniversity"];
    [query whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"University doesnt exisit so add new one ");
            // save
            [feed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"succeed");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations - University Saved" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                } else {
                    NSLog(@"failed to save: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't save" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            }];
            
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved university with pos %@ new value: %ld", [object objectForKey:@"position"],(long)self.category);
            // save
            [object setObject:[NSNumber numberWithInteger:self.category] forKey:@"position"];
            [object setObject:[self setUniversityName:self.category] forKey:@"title"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"succeed");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"University Saved" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                } else {
                    NSLog(@"failed to save: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't save" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            }];
        }
    }];
    
    
    [defaults synchronize];
    
    
    
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
//    cameraUI.delegate = self;
    
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
//    cameraUI.delegate = self;
    
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
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            //            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //                if (succeeded) {
            //                    NSLog(@"Thumbnail uploaded successfully");
            //                }
            //                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            //            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)setupTextFields {
    
    self.contentField = [[UITextView alloc] initWithFrame:CGRectMake( baseX, contentY, contentWidth, contentHeight)];
//    self.contentField.delegate = self;
    self.contentField.editable = NO;
    self.contentField.text = @"Select University                (press Done to save it)";
    //    self.contentField.delegate = self;
    self.contentField .font = [UIFont boldSystemFontOfSize:22.0f];
    self.contentField .returnKeyType = UIReturnKeyDefault;
    self.contentField .textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    //    self.contentField .contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //    [self.contentField  setValue:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.scrollView addSubview:self.contentField];
    
    
    UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(baseX,15.0f+contentHeight,contentWidth,categoryHeight)];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    [self.scrollView addSubview:picker];
    //This is how you manually SET(!!) a selection!
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __block NSInteger currentUniversity = 25;
    if([defaults objectForKey:@"university"]) {
         currentUniversity = [defaults integerForKey:@"university"];
        [picker selectRow:currentUniversity inComponent:0 animated:YES];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"MyUniversity"];
        [query whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                
                 [defaults setInteger:[[object objectForKey:@"position"] integerValue] forKey:@"university"];
                 [defaults synchronize];
                 currentUniversity = [defaults integerForKey:@"university"];
                 [picker selectRow:currentUniversity inComponent:0 animated:YES];
            }
        }];

        
    }
    
    
}
#pragma mar - UITextFieldDelegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;//Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 39;//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self setUniversityName:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.category = row;
        NSLog(@"didSelectRow : %ld", (long)self.category);
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

- (NSString *)setUniversityName:(NSUInteger)position {
    
    switch(position) {
            
        case 0 :
            return @"Chungang Univ";
            break;
        case 1 :
            return @"Duksung Univ";
            break;
        case 2 :
            return @"Dongguk Univ";
            break;
        case 3 :
            return@"Ewha Women Univ";
            break;
        case 4 :
            return @"Hanyang Univ";
            break;
        case 5 :
            return @"Hongik Univ";
            break;
        case 6 :
            return @"HUFS.";
            break;
        case 7 :
            return @"Konkuk Univ";
            break;
        case 8 :
            return @"Korea Univ";
            break;
            
        case 9 :
            return @"Kookmin Univ";
            break;
        case 10 :
            return @"KyungHee Univ";
            break;
        case 11 :
            return @"Seoul National Univ";
            break;
        case 12:
            return @"SungkyungKwan Univ";
            break;
        case 13 :
            return @"Sogang Univ";
            break;
        case 14:
            return  @"Sookmyung Univ";
            break;
        case 15:
            return @"Univ of Seoul";
            break;
        case 16:
            return  @"Yonsei Univ";
            break;
        case 17 :
            return @"KAIST";
            break;
        case 18:
            return @"POSTECH";
            break;
        case 19:
            return @"Soongsil & Sejeong Uni";
            break;
        case 20:
            return @"Ajou Univ";
            break;
        case 21:
            return @"GIST";
            break;
        case 22:
            return @"Pusan Nat. Univ";
            break;
        case 23:
            return @"Jeju Univ";
            break;
        case 24:
            return @"English Teachers";
            break;
        case 25:
            return @"Tourists";
            break;
        case 26:
            return @"Chonbuk National University";
            break;
        case 27:
            return @"Sungshin Women's Univ";
            break;
        case 28:
            return @"Inha University";
            break;
        case 29:
            return @"Yeungnam Univ";
            break;
        case 30:
            return @"Keimyung Univ";
            break;
        case 31:
            return @"Chosun Univ";
            break;
        case 32:
            return @"BUFS";
            break;
        case 33:
            return @"Pai Chai Univ";
            break;
        case 34:
            return @"Kangwon Nat. Univ";
            break;
        case 35:
            return @"Dongseo University";
            break;
        case 36:
            return @"Sunmoon University";
            break;
        case 37:
            return @"Chonnam Nat. Univ";
            break;
        case 38:
            return @"KDI School";
            break;
        case 39:
            return @"";
            break;
        case 40:
            return @"";
            break;
        case 41:
            return @"";
            break;
        default:
            return @"Tourists";
            
    }
    
}



@end

