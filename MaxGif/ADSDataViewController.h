//
//  ADSDataViewController.h
//  MaxGif
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADSDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *labelItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareItem;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) id dataObject;

- (IBAction)share:(id)sender;

@end
