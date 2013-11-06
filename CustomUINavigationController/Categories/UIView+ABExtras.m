//
//  UIView+ABExtras.m
//  SquaresFlipNavigationExample
//
//  Created by Andrés Brun on 8/8/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "UIView+ABExtras.h"
#import "UINavigationController+ABExtras.h"
#import "UIImageView+ABExtras.h"
#import "LMImageCache.h"

@implementation UIView (ABExtras)

- (CAGradientLayer *)addLinearGradientWithColor:(UIColor *)theColor transparentToOpaque:(BOOL)transparentToOpaque
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    //the gradient layer must be positioned at the origin of the view
    CGRect gradientFrame = self.frame;
    gradientFrame.origin.x = 0;
    gradientFrame.origin.y = 0;
    gradient.frame = gradientFrame;
    
    //build the colors array for the gradient
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[theColor CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.9f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.6f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.4f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.3f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.1f] CGColor],
                       (id)[[UIColor clearColor] CGColor],
                       nil];
    
    //reverse the color array if needed
    if(transparentToOpaque) {
        colors = [[colors reverseObjectEnumerator] allObjects];
    }
    
    //apply the colors and the gradient to the view
    gradient.colors = colors;
    
    [self.layer insertSublayer:gradient atIndex:[self.layer.sublayers count]];
    
    return gradient;
}

- (UIView *)addOpacityWithColor:(UIColor *)theColor
{
    UIView *shadowView = [[UIView alloc] initWithFrame:self.bounds];
    
    [shadowView setBackgroundColor:[theColor colorWithAlphaComponent:0.8]];
    
    [self addSubview:shadowView];
    
    return shadowView;
}

- (UIImageView *) imageInNavController: (UINavigationController *) navController
{
    [self.layer setContentsScale:[[UIScreen mainScreen] scale]];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 1.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    
    UIGraphicsEndImageContext();
    
    UIImageView *currentView = [[UIImageView alloc] initWithImage: img];
    
    //Fix the position to handle status bar and navigation bar
    float yPosition = [navController calculateYPosition];
    [currentView setFrame:CGRectMake(0, yPosition, currentView.frame.size.width, currentView.frame.size.height)];
    
    
    return currentView;
}
- (UIImageView *)snapshotImageView
{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //[window.layer setContentsScale:scale];
    
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, scale);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    NSString *url = [NSString stringWithFormat:@"window.jpg"];
    [[LMImageCache cache] saveImage:img forUrl:url];
    
    CGRect f = [self.superview convertRect:self.frame toView:window];
    f.origin.x *= scale;
    f.origin.y *= scale;
    f.size.width *= scale;
    f.size.height *= scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, f);
    UIImage * imgFrag = [UIImage imageWithCGImage:imageRef];
    
    url = [NSString stringWithFormat:@"window_fargment.jpg"];
    [[LMImageCache cache] saveImage:imgFrag forUrl:url];
    
     UIImageView *currentView = [[UIImageView alloc] initWithImage:imgFrag];
    //currentView.layer.contentsScale = scale;
    currentView.contentMode = UIViewContentModeScaleToFill;
    currentView.opaque = YES;
    currentView.frame = self.bounds;
    return currentView;
}
@end
