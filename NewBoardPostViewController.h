//
//  NewBoardPostViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/15/15.
//
//


@interface NewBoardPostViewController :  UIViewController <UITextFieldDelegate, UIScrollViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UITextViewDelegate>


@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *contentField;
@property (nonatomic, strong) UITextField *linkField;
@property (nonatomic, strong) UIButton *imagebutton;


- (BOOL)shouldPresentPhotoCaptureController;
- (id)initWithImage:(UIImage *)aImage;



@end