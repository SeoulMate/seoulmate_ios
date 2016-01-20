//
//  EventCell.h
//  SeoulMate
//
//  Created by Hassan Abid on 7/21/15.
//
//

#import "ParseUI/PFTableViewCell.h"
@interface EventCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic,strong) UILabel *postTitle;
@property (nonatomic,strong) UILabel *postDate;

@end

