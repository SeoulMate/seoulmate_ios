//
//  PAPCache.m
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPCache.h"

@interface PAPCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
- (void)setAttributes:(NSDictionary *)attributes forFeed:(PFObject *)feed;
- (void)setAttributes:(NSDictionary *)attributes forBoard:(PFObject *)board;
- (void)setAttributes:(NSDictionary *)attributes forKorean:(PFObject *)korean;
- (void)setAttributes:(NSDictionary *)attributes forPost:(PFObject *)post;
@end

@implementation PAPCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                      @([likers count]),kPAPPhotoAttributesLikeCountKey,
                                      likers,kPAPPhotoAttributesLikersKey,
                                      @([commenters count]),kPAPPhotoAttributesCommentCountKey,
                                      commenters,kPAPPhotoAttributesCommentersKey,
                                      nil];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setAttributesForFeed:(PFObject *)feed likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kPAPPhotoAttributesLikeCountKey,
                                likers,kPAPPhotoAttributesLikersKey,
                                @([commenters count]),kPAPPhotoAttributesCommentCountKey,
                                commenters,kPAPPhotoAttributesCommentersKey,
                                nil];
    
    [self setAttributes:attributes forFeed:feed];

}

- (void)setAttributesForBoard:(PFObject *)board likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kPAPPhotoAttributesLikeCountKey,
                                likers,kPAPPhotoAttributesLikersKey,
                                @([commenters count]),kPAPPhotoAttributesCommentCountKey,
                                commenters,kPAPPhotoAttributesCommentersKey,
                                nil];
    
    [self setAttributes:attributes forBoard:board];
}

- (void)setAttributesForKorean:(PFObject *)korean likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kPAPPhotoAttributesLikeCountKey,
                                likers,kPAPPhotoAttributesLikersKey,
                                @([commenters count]),kPAPPhotoAttributesCommentCountKey,
                                commenters,kPAPPhotoAttributesCommentersKey,
                                nil];
    
    [self setAttributes:attributes forKorean:korean];
}

- (void)setAttributesForPost:(PFObject *)post likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kPAPPhotoAttributesLikeCountKey,
                                likers,kPAPPhotoAttributesLikersKey,
                                @([commenters count]),kPAPPhotoAttributesCommentCountKey,
                                commenters,kPAPPhotoAttributesCommentersKey,
                                nil];
    [self setAttributes:attributes forPost:post];
}

- (NSDictionary *)attributesForPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForFeed:(PFObject *)feed {
    NSString *key = [self keyForFeed:feed];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForBoard:(PFObject *)board {
    NSString *key = [self keyForBoard:board];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForKorean:(PFObject *)korean {
    NSString *key = [self keyForKorean:korean];
    return [self.cache objectForKey:key];

}
- (NSNumber *)likeCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikeCountKey];
    }

    return [NSNumber numberWithInt:0];
}


- (NSNumber *)likeCountForFeed:(PFObject *)feed {
    NSDictionary *attributes = [self attributesForFeed:feed];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
    
}

- (NSNumber *)likeCountForBoard:(PFObject *)board {
    NSDictionary *attributes = [self attributesForBoard:board];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
    
}

- (NSNumber *)likeCountForKorean:(PFObject *)korean {
    NSDictionary *attributes = [self attributesForKorean:korean];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForFeed:(PFObject *)feed {
    NSDictionary *attributes = [self attributesForFeed:feed];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForBoard:(PFObject *)board {
    NSDictionary *attributes = [self attributesForBoard:board];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForKorean:(PFObject *)korean  {
    NSDictionary *attributes = [self attributesForKorean:korean];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)likersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)likersForFeed:(PFObject *)feed {
    NSDictionary *attributes = [self attributesForFeed:feed];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)likersForBoard:(PFObject *)board {
    NSDictionary *attributes = [self attributesForBoard:board];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)likersForKorean:(PFObject *)korean {
    NSDictionary *attributes = [self attributesForKorean:korean];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForFeed:(PFObject *)feed {
    NSDictionary *attributes = [self attributesForFeed:feed];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForBoard:(PFObject *)board {
    NSDictionary *attributes = [self attributesForBoard:board];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForKorean:(PFObject *)korean {
    NSDictionary *attributes = [self attributesForKorean:korean];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setFeedIsLikedByCurrentUser:(PFObject *)feed liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForFeed:feed]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forFeed:feed];
}

- (void)setKoreanIsLikedByCurrentUser:(PFObject *)korean liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForKorean:korean]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forKorean:korean];
}

- (void)setBoardIsLikedByCurrentUser:(PFObject *)board liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForBoard:board]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forBoard:board];
}

- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [[attributes objectForKey:kPAPPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (BOOL)isFeedLikedByCurrentUser:(PFObject *)feed {
    NSDictionary *attributes = [self attributesForFeed:feed];
    if (attributes) {
        return [[attributes objectForKey:kPAPPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (BOOL)isBoardLikedByCurrentUser:(PFObject *)board {
    NSDictionary *attributes = [self attributesForBoard:board];
    if (attributes) {
        return [[attributes objectForKey:kPAPPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (BOOL)isKoreanLikedByCurrentUser:(PFObject *)korean {
    NSDictionary *attributes = [self attributesForKorean:korean];
    if (attributes) {
        return [[attributes objectForKey:kPAPPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)incrementLikerCountForFeed:(PFObject *)feed {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForFeed:feed] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForFeed:feed]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forFeed:feed];
}

- (void)incrementLikerCountForBoard:(PFObject *)board {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForBoard:board] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForBoard:board]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forBoard:board];

}

- (void)incrementLikerCountForKorean:(PFObject *)korean {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForKorean:korean] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForKorean:korean]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forKorean:korean];
}


- (void)decrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementLikerCountForFeed:(PFObject *)feed {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForFeed:feed] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForFeed:feed]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forFeed:feed];

}

- (void)decrementLikerCountForBoard:(PFObject *)board {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForBoard:board] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForBoard:board]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forBoard:board];
    
}

- (void)decrementLikerCountForKorean:(PFObject *)korean {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForKorean:korean] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForKorean:korean]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forKorean:korean];
    
}

- (void)incrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)incrementCommentCountForFeed:(PFObject *)feed {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForFeed:feed] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForFeed:feed]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forFeed:feed];
}

- (void)incrementCommentCountForBoard:(PFObject *)board {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForBoard:board] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForBoard:board]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forBoard:board];

}

- (void)incrementCommentCountForKorean:(PFObject *)korean {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForKorean:korean] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForKorean:korean]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forKorean:korean];

}

- (void)decrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementCommentCountForFeed:(PFObject *)feed{
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForFeed:feed] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForFeed:feed]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forFeed:feed];
}

- (void)decrementCommentCountForBoard:(PFObject *)board {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForBoard:board] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForBoard:board]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forBoard:board];
}

- (void)decrementCommentCountForKorean:(PFObject *)korean {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForKorean:korean] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForKorean:korean]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forKorean:korean];

}

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kPAPUserAttributesPhotoCountKey,
                                [NSNumber numberWithBool:following],kPAPUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kPAPUserAttributesPhotoCountKey];
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }

    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kPAPUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }

    return friends;
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forFeed:(PFObject *)feed {
    NSString *key = [self keyForFeed:feed];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forBoard:(PFObject *)board {
    NSString *key = [self keyForBoard:board];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forKorean:(PFObject *)korean {
    NSString *key = [self keyForKorean:korean];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forPost:(PFObject *)post {
    NSString *key = [self keyForPost:post];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForFeed:(PFObject *)feed {
    return [NSString stringWithFormat:@"feed_%@", [feed objectId]];
}

- (NSString *)keyForBoard:(PFObject *)board {
    return [NSString stringWithFormat:@"board_%@", [board objectId]];
}

- (NSString *)keyForKorean:(PFObject *)korean {
    return [NSString stringWithFormat:@"korean_%@", [korean objectId]];
}

- (NSString *)keyForPost:(PFObject *)korean {
    return [NSString stringWithFormat:@"post_%@", [korean objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
