//
//  ADSRootViewController.h
//  MaxGif
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADSRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIView *footerView;

@end
