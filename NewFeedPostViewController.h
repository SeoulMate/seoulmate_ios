//
//  NewFeedPostViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/19/15.
//
//

@interface NewFeedPostViewController :  UIViewController <UITextFieldDelegate, UIScrollViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>


@property (nonatomic, strong) UITextView *contentField;
@property (nonatomic, strong) UIButton *imagebutton;


- (BOOL)shouldPresentPhotoCaptureController;
- (id)initWithImage:(UIImage *)aImage;



@end
