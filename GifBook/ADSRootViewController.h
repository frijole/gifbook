//
//  ADSRootViewController.h
//  GifBook
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADSModelController.h"

@interface ADSRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (readonly, strong, nonatomic) ADSModelController *modelController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIView *footerView;

@end
