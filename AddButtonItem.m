//
//  AddButtonItem.m
//  SeoulMate
//
//  Created by Hassan Abid on 7/15/15.
//
//

#import "AddButtonItem.h"

@implementation AddButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:addButton];
    if (self) {
        //        [settingsButton setBackgroundImage:[UIImage imageNamed:@"ButtonSettings.png"] forState:UIControlStateNormal];
        [addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [addButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [addButton setImage:[UIImage imageNamed:@"iconAdd.png"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"iconAdd.png"] forState:UIControlStateHighlighted];
    }
    
    return self;
}
@end
