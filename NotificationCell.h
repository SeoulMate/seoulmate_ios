//
//  NotificationCell.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/23/15.
//
//

#import "NotiBaseTextCell.h"

@protocol NotiActivityCellDelegate;

@interface NotificationCell : NotiBaseTextCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol NotiActivityCellDelegate <NotificationCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(NotificationCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
