//
//  FeedDetailsHeaderView.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/12/15.
//
//

@protocol FeedDetailsHeaderViewDelegate;

@interface FeedDetailsHeaderView : UIView

/*! @name Managing View Properties */

/// The board displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

/// The user that write the board post
@property (nonatomic, strong, readonly) PFUser *writer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<FeedDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;
+ (CGRect)rectForViewWithoutImage;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto writer:(PFUser*)aWriter likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
@end

/*!
 The protocol defines methods a delegate of a PAPPhotoDetailsHeaderView should implement.
 */
@protocol FeedDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)feedDetailsHeaderView:(FeedDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;


@end