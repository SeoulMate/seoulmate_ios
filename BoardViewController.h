//
//  BoardViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 6/23/15.
//
//

#import <Google/Analytics.h>
#import "PAPPhotoHeaderView.h"

@interface BoardViewController : PFQueryTableViewController <PAPPhotoHeaderViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end

