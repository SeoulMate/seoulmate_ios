//
//  BoardCell.m
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/4/15.
//
//

#import <UIKit/UIKit.h>
#import "BoardCell.h"
#import "PAPUtility.h"

//@interface BoardCell()
//@end

#pragma mark - NSObject

@implementation BoardCell

@synthesize photoButton;
@synthesize postTitle;

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
        dropshadowView.backgroundColor = [UIColor redColor];
        //        dropshadowView.frame = CGRectMake( 20.0f, -44.0f, 280.0f, 322.0f);
        dropshadowView.frame = CGRectMake( 5.0f, -44.0f, 320.0f, 160.0f);
//        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
        

        self.imageView.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
//        self.imageView.backgroundColor = [UIColor colorWithRed:3.0f green:169.0f blue:244.0f alpha:0];
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
        self.postTitle = [[UILabel alloc] initWithFrame:CGRectMake(34.0, -50.0, 250.0, 160.0f)];
        
        // Configure Main Label
        [self.postTitle setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self.postTitle setTextAlignment:NSTextAlignmentCenter];
        self.postTitle.numberOfLines = 4;
        [self.postTitle setTextColor:[UIColor whiteColor]];
        [self.postTitle setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        [self.contentView bringSubviewToFront:self.imageView];
        //        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.postTitle];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
    self.photoButton.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
}

@end
