//
//  KoreanListViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 6/30/15.
//
//

#import "PAPPhotoHeaderView.h"


@interface KoreanListViewController : PFQueryTableViewController<PAPPhotoHeaderViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
