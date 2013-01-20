//
//  ADSDataViewController.h
//  GifBook
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADSModelController.h"

@interface ADSDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *labelItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareItem;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) id dataObject;

@property (strong, nonatomic) ADSModelController *modelController;

- (IBAction)share:(id)sender;
- (IBAction)trash:(id)sender;

@end
