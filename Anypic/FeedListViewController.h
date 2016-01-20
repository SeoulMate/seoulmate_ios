//
//  FeedListViewController.h
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/8/15.
//
//

#import "PAPPhotoHeaderView.h"


@interface FeedListViewController : PFQueryTableViewController<PAPPhotoHeaderViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;
@property (nonatomic,strong) UIButton *floatbutton;

@end