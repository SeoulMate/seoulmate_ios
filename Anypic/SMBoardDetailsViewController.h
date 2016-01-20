//
//  SMBoardDetailsViewController.h
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/11/15.
//
//
#import "SMBoardDetailsHeaderView.h"
#import "PAPBaseTextCell.h"

@interface SMBoardDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, SMBoardDetailsHeaderViewDelegate, PAPBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end