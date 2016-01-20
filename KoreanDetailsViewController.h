//
//  KoreanDetailsViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/12/15.
//
//

#import "PAPBaseTextCell.h"
#import "KoreanDetailsHeaderView.h"

@interface KoreanDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, KoreanDetailsHeaderViewDelegate, PAPBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) PFObject *korean;

- (id)initWithKorean:(PFObject*)aPhoto korean:(PFObject*)aKorean ;

@end
