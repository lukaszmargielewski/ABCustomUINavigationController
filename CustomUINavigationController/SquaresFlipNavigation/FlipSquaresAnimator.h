//
//  FlipSquaresNavigationController.h
//  SquaresFlipNavigationExample
//
//  Created by Andrés Brun on 7/14/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {FSNavSortMethodRandom, FSNavSortMethodHorizontal} FSNavSortMethod;


@interface FlipSquaresAnimator : NSObject

@property (nonatomic, assign) FSNavSortMethod sortMethod;

-(void)animateFromView:(UIView *)fromView toView:(UIView *)toView  withCompletion: (void(^)(void))completion;

@end
