//
//  EventsListViewController.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/14/15.
//
//

#import "EventHeaderView.h"


@interface EventsListViewController : PFQueryTableViewController<EventHeaderViewDelegate>

- (EventHeaderView *)dequeueReusableSectionHeaderView;

@end