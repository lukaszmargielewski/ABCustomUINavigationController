//
//  FlipSquaresNavigationController.m
//  SquaresFlipNavigationExample
//
//  Created by Andrés Brun on 7/14/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "FlipSquaresAnimator.h"

#import <QuartzCore/QuartzCore.h>

#import "NSObject+ABExtras.h"
#import "UIImageView+ABExtras.h"
#import "UIView+ABExtras.h"
#import "UINavigationController+ABExtras.h"

#define ARC4RANDOM_MAX 0x100000000

//Configure params
#define SQUARE_ROWS 8
#define SQUARE_COLUMNS 3
#define TIME_ANIMATION 10.0

@interface FlipSquaresAnimator (){
    NSMutableArray *fromViewImagesArray;
    NSMutableArray *toViewImagesArray;
    BOOL pushingVC;
}

- (void) makeSquaresFlipAnimationFrom:(UIImageView *) fromImage view:(UIView *)fromView to: (UIImageView *) toImage view:(UIView *)toView option: (UIViewAnimationOptions) options withCompletion: (void(^)(void))completion;

//Array methods
- (NSMutableArray *) shuffleArray: (NSMutableArray *)array;
- (NSMutableArray *) sortFrom: (BOOL) leftToRight array: (NSMutableArray *) array;
- (NSMutableArray *) sortRandomArray:(NSMutableArray *)array;
- (float) getRandomFloat01;

//Aux methods
- (void) releaseImagesArray;

@end

@implementation FlipSquaresAnimator

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.sortMethod = FSNavSortMethodHorizontal;
    }
    return self;
}


#pragma mark - Overwrite UINavigationController methods

-(void)animateFromView:(UIView *)fromView toView:(UIView *)toView  withCompletion: (void(^)(void))completion{
    
    pushingVC=YES;

    
        UIImageView *fromImageView = [fromView snapshotImageView];
        UIImageView *toImageView = [toView snapshotImageView];
        
    [self makeSquaresFlipAnimationFrom:fromImageView view:fromView to:toImageView view:toView option:UIViewAnimationOptionTransitionFlipFromLeft withCompletion:^{

            completion();
            
            
        }];

}


#pragma mark - animate methods
                                                                  
- (void) makeSquaresFlipAnimationFrom:(UIImageView *) fromImage view:(UIView *)fromView to: (UIImageView *) toImage view:(UIView *)toView option: (UIViewAnimationOptions) options withCompletion: (void(^)(void))completion{
    
    fromViewImagesArray = [NSMutableArray array];
    toViewImagesArray = [NSMutableArray array];
    
    //Make the matrix and add the images
    float rowsWidth = fromImage.frame.size.width / SQUARE_ROWS;
    float columnsHeight = fromImage.frame.size.height / SQUARE_COLUMNS;
    
    //Create the cropped images
    
    for (int col=0; col<SQUARE_COLUMNS; col++) {
        
        for (int row=0; row<SQUARE_ROWS; row++) {
            CGRect currentRect = CGRectMake(row*rowsWidth,col*columnsHeight,rowsWidth,columnsHeight);
            
            UIView *fromView = [[fromImage createCrop:currentRect] createView];
            UIView *toView = [[toImage createCrop:currentRect] createView];

            [fromViewImagesArray addObject:fromView];
            [toViewImagesArray addObject:toView];
        }
    }
    
    //Add the images
    for (UIView *currentView in fromViewImagesArray) {
        [fromView addSubview:currentView];
    }
        
    //Create a array with all the number and unsort after
    NSMutableArray *orderArray = [NSMutableArray array];
    for (int i=0; i<[toViewImagesArray count]; i++) {
        [orderArray addObject:[NSNumber numberWithInt:i]];
    }
    
    orderArray=[self shuffleArray:orderArray];
    
    float maxDelay=0;
    for (NSNumber *currentPos in orderArray) {
        int posIndex = [orderArray indexOfObject:currentPos];
        
        UIView *fromViewCrop = [fromViewImagesArray objectAtIndex:[currentPos intValue]];
        UIView *toViewCrop = [toViewImagesArray objectAtIndex:[currentPos intValue]];
    
        //we "order" the delays for sort the animation in time
        float ratio = posIndex/([orderArray count]*1.0);
        float delay = [self getRandomFloat01]*TIME_ANIMATION*0.4*ratio + TIME_ANIMATION*0.3*ratio;//Random + Fix -> MAX 70% of TIME_ANIMATION
        ////DLog(@"PosIndex: %d Element: %d delay: %f", posIndex, [currentPos intValue], delay);
        maxDelay = MAX(delay, maxDelay);
        [self performBlock:^{
            
            CAGradientLayer *fromGradient = [fromViewCrop addLinearGradientWithColor:[UIColor blackColor] transparentToOpaque:YES];
            CAGradientLayer *toGradient = [fromViewCrop addLinearGradientWithColor:[UIColor blackColor] transparentToOpaque:YES];
            
            [fromGradient setOpacity:1.0];
            [toGradient setOpacity:0.0];
            [UIView animateWithDuration:TIME_ANIMATION*0.3 animations:^{
                [fromGradient setOpacity:0.0];
                [toGradient setOpacity:1.0];
            }];
            
            [UIView transitionFromView:[fromViewCrop viewWithTag:TAG_IMAGE_VIEW]
                                toView:[toViewCrop viewWithTag:TAG_IMAGE_VIEW]
                              duration:TIME_ANIMATION*0.3
                               options:options
                            completion:^(BOOL finished) {
                                
                            }];
        } afterDelay:delay];
        
    }
    
    //Perform the completion when the animation is finished. Calculate that with the 30% remain of TIME_ANIMATION
    [self performBlock:^{
        //Clean the others views
        [self releaseImagesArray];
        
        completion();
    } afterDelay:maxDelay+TIME_ANIMATION*0.3];

}


#pragma mark - Auxiliar methods
- (float) getRandomFloat01
{
    return ((double)arc4random() / ARC4RANDOM_MAX);
}


- (void) releaseImagesArray
{
    //Clean the others views
    for (UIImageView *currentView in fromViewImagesArray) {
        [[currentView viewWithTag:TAG_IMAGE_VIEW] removeFromSuperview];
        [currentView removeFromSuperview];
    }
    for (UIImageView *currentView in toViewImagesArray) {
        [UIView animateWithDuration:0.1 animations:^{
            [currentView setAlpha:0.0];
        }completion:^(BOOL finished) {
            [[currentView viewWithTag:TAG_IMAGE_VIEW] removeFromSuperview];
            [currentView removeFromSuperview];
        }];
    }
    
    [fromViewImagesArray removeAllObjects];
    [toViewImagesArray removeAllObjects];
}

#pragma mark - Sort Array methods
- (NSMutableArray *)shuffleArray: (NSMutableArray *)array
{
    switch (self.sortMethod) {
        case FSNavSortMethodRandom:{
            array=[self sortRandomArray:array];
        }break;
            
        case FSNavSortMethodHorizontal:
            array=[self sortFrom:pushingVC array:array];
            break;
            
        default:
            break;
    }
    return array;
}

/**
 Sort the elements randomly
 */
- (NSMutableArray *) sortRandomArray:(NSMutableArray *)array
{
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom(time(NULL));
    }
    
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return array;
}

/**
 Sort the elements for colums
 */
- (NSMutableArray *) sortFrom: (BOOL) leftToRight array: (NSMutableArray *) array
{
    NSMutableArray *sortedArray = [NSMutableArray array];
    
    //Get an array sort the elements by columns
    for (int index=0; index<[array count]; index++) {
        int auxPos = ((index%SQUARE_COLUMNS)*SQUARE_ROWS) + index/SQUARE_COLUMNS;       
        [sortedArray addObject:[array objectAtIndex:auxPos]];
    }
    
    if (leftToRight) {
        array = sortedArray;
    }else{
        array = [NSMutableArray arrayWithArray:[[sortedArray reverseObjectEnumerator] allObjects]];
    }
    
    return array;
}

@end
