//
//  PAPCache.h
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAPCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForFeed:(PFObject *)feed likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForBoard:(PFObject *)board likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForPost:(PFObject *)post likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForKorean:(PFObject *)korean likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (NSDictionary *)attributesForPhoto:(PFObject *)photo;
- (NSDictionary *)attributesForFeed:(PFObject *)feed;
- (NSDictionary *)attributesForBoard:(PFObject *)board;
- (NSDictionary *)attributesForKorean:(PFObject *)korean;
- (NSNumber *)likeCountForPhoto:(PFObject *)photo;
- (NSNumber *)likeCountForFeed:(PFObject *)feed;
- (NSNumber *)likeCountForBoard:(PFObject *)board;
- (NSNumber *)likeCountForKorean:(PFObject *)korean;
- (NSNumber *)commentCountForPhoto:(PFObject *)photo;
- (NSNumber *)commentCountForFeed:(PFObject *)feed;
- (NSNumber *)commentCountForBoard:(PFObject *)board;
- (NSNumber *)commentCountForKorean:(PFObject *)korean;
- (NSArray *)likersForPhoto:(PFObject *)photo;
- (NSArray *)likersForFeed:(PFObject *)feed;
- (NSArray *)likersForBoard:(PFObject *)board;
- (NSArray *)likersForKorean:(PFObject *)korean;
- (NSArray *)commentersForPhoto:(PFObject *)photo;
- (NSArray *)commentersForFeed:(PFObject *)feed;
- (NSArray *)commentersForBoard:(PFObject *)board;
- (NSArray *)commentersForKorean:(PFObject *)korean;
- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked;
- (void)setFeedIsLikedByCurrentUser:(PFObject *)feed liked:(BOOL)liked;
- (void)setBoardIsLikedByCurrentUser:(PFObject *)board liked:(BOOL)liked;
- (void)setKoreanIsLikedByCurrentUser:(PFObject *)korean liked:(BOOL)liked;
- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo;
- (BOOL)isFeedLikedByCurrentUser:(PFObject *)feed;
- (BOOL)isBoardLikedByCurrentUser:(PFObject *)board;
- (BOOL)isKoreanLikedByCurrentUser:(PFObject *)korean;
- (void)incrementLikerCountForPhoto:(PFObject *)photo;
- (void)incrementLikerCountForFeed:(PFObject *)feed;
- (void)incrementLikerCountForBoard:(PFObject *)board;
- (void)incrementLikerCountForKorean:(PFObject *)korean;
- (void)decrementLikerCountForPhoto:(PFObject *)photo;
- (void)decrementLikerCountForFeed:(PFObject *)feed;
- (void)decrementLikerCountForBoard:(PFObject *)board;
- (void)decrementLikerCountForKorean:(PFObject *)korean;
- (void)incrementCommentCountForPhoto:(PFObject *)photo;
- (void)incrementCommentCountForFeed:(PFObject *)feed;
- (void)incrementCommentCountForBoard:(PFObject *)board;
- (void)incrementCommentCountForKorean:(PFObject *)korean;
- (void)decrementCommentCountForPhoto:(PFObject *)photo;
- (void)decrementCommentCountForFeed:(PFObject *)feed;
- (void)decrementCommentCountForBoard:(PFObject *)board;
- (void)decrementCommentCountForKorean:(PFObject *)korean;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
