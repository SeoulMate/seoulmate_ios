//
//  PAPUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation PAPUtility


#pragma mark - PAPUtility
#pragma mark Like Photos

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:photo forKey:kPAPActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;

        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }

            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];

        }];
    }];

}

+ (void)likeFeedInBackground:(id)photo block:(void (^)(BOOL, NSError *))completionBlock {

    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityFeedKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:photo forKey:kPAPActivityFeedKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnFeed:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];

    
}

+ (void)likeBoardInBackground:(id)board block:(void (^)(BOOL, NSError *))completionBlock {
    
    
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityBoardClassKey];
    [queryExistingLikes whereKey:kPAPActivityBoardKey equalTo:board];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityBoardClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[board objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:board forKey:kPAPActivityBoardKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[board objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnBoard:board cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForBoard:board likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:board userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    


}

+ (void)likeKoreanInBackground:(id)korean block:(void (^)(BOOL, NSError *))completionBlock {
    
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityKoreanClassKey];
    [queryExistingLikes whereKey:kPAPActivityKoreanKey equalTo:korean];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityKoreanClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[korean objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:korean forKey:kPAPActivityKoreanKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[korean objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            if(!error) {
                NSLog(@"Saved korean activity ! -> %@ ", @"successfully");
            }
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnKorean:korean cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForKorean:korean likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:korean userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    

}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }

            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnFeed:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];

        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  
}
+ (void)unlikeFeedInBackground:(id)photo block:(void (^)(BOOL, NSError *))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityFeedKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnFeed:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForFeed:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  

    
}

+ (void)unlikeBoardInBackground:(id)photo block:(void (^)(BOOL, NSError *))completionBlock {
    
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityBoardClassKey];
    [queryExistingLikes whereKey:kPAPActivityBoardKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnBoard:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForBoard:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];


}

+ (void)unlikeKoreanInBackground:(id)photo block:(void (^)(BOOL, NSError *))completionBlock {
    
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityKoreanClassKey];
    [queryExistingLikes whereKey:kPAPActivityKoreanKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnKorean:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForKorean:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];

}
#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    NSLog(@"Processing profile picture of size: %@", @(newProfilePictureData.length));
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];

    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];

    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);

    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];    
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
  NSLog(@"Processed profile picture");
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    // Check that PFUser has valid fbid that matches current FBSessions userId
    NSString *facebookId = [user objectForKey:kPAPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0 && [facebookId isEqualToString:[[[PFFacebookUtils session] accessTokenData] userID]]);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPAPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"AvatarPlaceholderBig.png"];
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
//    [followActivity setObject:[PFObject objectWithClassName:@"Feed"] forKey:kPAPActivityFeedKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [PAPUtility followUserEventually:user block:completionBlock];
        [[PAPCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[PAPCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];

    return query;
}

+ (PFQuery *)queryForActivitiesOnFeed:(PFObject *)feed cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityFeedKey equalTo:feed];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityFeedKey equalTo:feed];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityFeedKey];
    
    return query;
}

+ (PFQuery *)queryForActivitiesOnKorean:(PFObject *)korean cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityKoreanClassKey];
    [queryLikes whereKey:kPAPActivityKoreanKey equalTo:korean];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityKoreanClassKey];
    [queryComments whereKey:kPAPActivityKoreanKey equalTo:korean];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityKoreanKey];
    
    return query;
}


+ (PFQuery *)queryForActivitiesOnBoard:(PFObject *)board cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityBoardClassKey];
    [queryLikes whereKey:kPAPActivityBoardKey equalTo:board];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityBoardClassKey];
    [queryComments whereKey:kPAPActivityBoardKey equalTo:board];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityBoardKey];
    
    return query;
}


#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y - 5.0f, 
                                          rect.size.width, 
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y, 
                                          rect.size.width, 
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {    
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y - 5.0f, 
                                          rect.size.width, 
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}
@end
