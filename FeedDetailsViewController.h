//
//  FeedDetailsViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/12/15.
//
//

#import "PAPBaseTextCell.h"
#import "FeedDetailsHeaderView.h"

@interface FeedDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, FeedDetailsHeaderViewDelegate, PAPBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) PFObject *feed;

- (id)initWithFeed:(PFObject*)aPhoto feed:(PFObject*)aFeed ;

@end
