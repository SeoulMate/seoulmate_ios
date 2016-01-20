//
//  BoardDetailsViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/11/15.
//
//


#import "PAPBaseTextCell.h"
#import "BoardDetailsHeaderView.h"

@interface BoardDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, BoardDetailsHeaderViewDelegate, PAPBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) PFObject *board;

- (id)initWithBoard:(PFObject*)aPhoto board:(PFObject*)aBoard ;

@end
