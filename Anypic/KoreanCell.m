//
//  KoreanCell.m
//  SeoulMate - Worldwide
//
//  Created by Hassan Abid on 6/11/15.
//
//

#import "KoreanCell.h"
#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - NSObject

@implementation KoreanCell
@synthesize photoButton;
@synthesize postTitle;
@synthesize postTags;

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
        dropshadowView.backgroundColor = [UIColor clearColor];
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
        
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.imageView.bounds;
        [self.imageView addSubview:effectView];
        
//        // create our blurred image
//        CIContext *context = [CIContext contextWithOptions:nil];
//        CIImage *inputImage = [CIImage imageWithCGImage:self.imageView.image.CGImage];
//        
//        // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
//        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//        [filter setValue:inputImage forKey:kCIInputImageKey];
//        [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
//        CIImage *result = [filter valueForKey:kCIOutputImageKey];
//        
//        // CIGaussianBlur has a tendency to shrink the image a little,
//        // this ensures it matches up exactly to the bounds of our original image
//        CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
//        
//        self.imageView.image = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
//        CGImageRelease(cgImage);//release CGIma
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 5.0f, 0.0f, 320.0f, 160.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        // Initialize Main Label
        self.postTitle = [[UILabel alloc] initWithFrame:CGRectMake(25.0, -60.0, 280.0f, 160.0f)];
        
        // Configure Main Label
        [self.postTitle setFont:[UIFont systemFontOfSize:20.0f]];
        [self.postTitle setTextAlignment:NSTextAlignmentCenter];
        self.postTitle.numberOfLines = 8;
        [self.postTitle setTextColor:[UIColor whiteColor]];
        [self.postTitle setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        //initialize Date Label
        self.postTags = [[UILabel alloc] initWithFrame:CGRectMake(80, -64, 220, 40)];
        // Configure Main Label
        [self.postTags setFont:[UIFont systemFontOfSize:12.0]];
        [self.postTags setTextAlignment:NSTextAlignmentRight];
        self.postTags.numberOfLines = 1;
        // rgb(178, 223, 219)
        [self.postTags setTextColor:[UIColor colorWithRed:178.0/255.0 green:223.0/255.0 blue:219.0/255.0 alpha:1.0]];
        [self.postTags setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        
        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView addSubview:self.postTitle];
        [self.contentView addSubview:self.postTags];
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
