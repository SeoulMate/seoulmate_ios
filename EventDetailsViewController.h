//
//  EventDetailsViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/22/15.
//
//

#import "PAPBaseTextCell.h"
#import "EventDetailsHeaderView.h"

@interface EventDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, EventDetailsHeaderViewDelegate, PAPBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) PFObject *board;

- (id)initWithEvent:(PFObject*)aPhoto post:(PFObject*)aPost ;

@end

