//
//  FeedCell.m
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/9/15.
//
//

#import "FeedCell.h"
#import <UIKit/UIKit.h>
#import "PAPUtility.h"

#pragma mark - NSObject

@implementation FeedCell

@synthesize photoButton;
@synthesize postTitle;
@synthesize postUni;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        UIView *dropshadowView = [[UIView alloc] init];
        dropshadowView.backgroundColor = [UIColor whiteColor];
        dropshadowView.frame = CGRectMake( 5.0f, -44.0f, 320.0f, 160.0f);
//        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
        
        self.imageView.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        self.imageView.image = [UIImage imageNamed:@"scholarshipsBack.png"];
        
        //        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        //        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        //        effectView.frame = self.imageView.bounds;
        //        [self.imageView addSubview:effectView];
        
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        // Initialize Main Label
        self.postTitle = [[UILabel alloc] initWithFrame:CGRectMake(34.0, -60.0, 250.0f, 160.0f)];
        
        // Configure Main Label
        [self.postTitle setFont:[UIFont systemFontOfSize:14.0f]];
        [self.postTitle setTextAlignment:NSTextAlignmentLeft];
        self.postTitle.numberOfLines = 7;
        [self.postTitle setTextColor:[UIColor whiteColor]];
        [self.postTitle setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        //initialize Date Label
        self.postUni = [[UILabel alloc] initWithFrame:CGRectMake(80, -64, 220, 40)];
        // Configure Main Label
        [self.postUni setFont:[UIFont systemFontOfSize:12.0]];
        [self.postUni setTextAlignment:NSTextAlignmentRight];
        self.postUni.numberOfLines = 1;
        // rgb(178, 223, 219)
        [self.postUni setTextColor:[UIColor colorWithRed:178.0/255.0 green:223.0/255.0 blue:219.0/255.0 alpha:1.0]];
        [self.postUni setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
//       [self setUniversityName:<#(NSUInteger)#>];
        
        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView addSubview:self.postTitle];
        [self.contentView addSubview:self.postUni];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(5.0f, 0.0f, 320.0f, 160.0f);
    self.photoButton.frame = CGRectMake(5.0f, 0.0f, 320.0f, 160.0f);
}


@end
