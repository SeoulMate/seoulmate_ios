//
//  NotificationViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/23/15.
//
//

//#import "PAPActivityCell.h"
#import "NotificationCell.h"

//@interface NotificationViewController : PFQueryTableViewController <PAPActivityCellDelegate>
@interface NotificationViewController : PFQueryTableViewController <NotiActivityCellDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
