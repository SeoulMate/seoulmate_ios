//
//  NewKoreanPostViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/19/15.
//
//

@interface NewKoreanPostViewController :  UIViewController <UITextFieldDelegate, UIScrollViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextViewDelegate>


@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *contentField;
@property (nonatomic, strong) UITextField *linkField;
@property (nonatomic, strong) UITextField *tagsField;
@property (nonatomic, strong) UIButton *imagebutton;


- (BOOL)shouldPresentPhotoCaptureController;
- (id)initWithImage:(UIImage *)aImage;



@end
