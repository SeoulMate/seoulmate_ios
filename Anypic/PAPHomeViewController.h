//
//  PAPHomeViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoTimelineViewController.h"
#import "BoardViewController.h"

//@interface PAPHomeViewController : PAPPhotoTimelineViewController
@interface PAPHomeViewController : BoardViewController

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@end
