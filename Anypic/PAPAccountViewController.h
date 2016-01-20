//
//  PAPAccountViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

//#import "PAPPhotoTimelineViewController.h"
#import "FeedListViewController.h"

//@interface PAPAccountViewController : PAPPhotoTimelineViewController
@interface PAPAccountViewController : FeedListViewController

@property (nonatomic, strong) PFUser *user;

- (id)initWithUser:(PFUser *)aUser;

@end
