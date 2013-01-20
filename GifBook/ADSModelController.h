//
//  ADSModelController.h
//  GifBook
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADSDataViewController;

@interface ADSModelController : NSObject <UIPageViewControllerDataSource>

- (NSUInteger)numberOfPages;

- (ADSDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(ADSDataViewController *)viewController;

- (void)addGif:(NSString *)inString;
- (BOOL)removeGif:(NSString *)inString;

@end
