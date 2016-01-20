//
//  EventHeaderView.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/14/15.
//
//

typedef enum {
    EventHeaderButtonsNone = 0,
    EventHeaderButtonsLike = 1 << 0,
    EventHeaderButtonsComment = 1 << 1,
    EventHeaderButtonsUser = 1 << 2,
    
    EventHeaderButtonsDefault = EventHeaderButtonsLike | EventHeaderButtonsComment | EventHeaderButtonsUser
} EventHeaderButtons;

@protocol EventHeaderViewDelegate;

@interface EventHeaderView : UITableViewCell

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(EventHeaderButtons)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) EventHeaderButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Photo button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <EventHeaderViewDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a PAPPhotoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol EventHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like photo button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
- (void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;

/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

@end