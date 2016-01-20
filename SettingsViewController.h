//
//  SettingsViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/28/15.
//
//

@interface SettingsViewController :  UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>


@property (nonatomic, strong) UITextView *contentField;
@property (nonatomic, strong) UIButton *imagebutton;


- (BOOL)shouldPresentPhotoCaptureController;
- (id)initWithImage:(UIImage *)aImage;





@end