//
//  ADSDataViewController.m
//  MaxGif
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "ADSDataViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+animatedGIF.h"
// #import "AnimatedGIF.h"
#import "AFNetworking.h"

@interface ADSDataViewController ()

@property (nonatomic) BOOL isTweeting;

@end

@implementation ADSDataViewController

- (void)dealloc
{
    [_footerView release];
    [_dataLabel release];
    [_imageView release];
    [_dataObject release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.imageView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tmpDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)];
    [tmpDoubleTapRecognizer setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:tmpDoubleTapRecognizer];
    [tmpDoubleTapRecognizer release];

    UITapGestureRecognizer *tmpTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [tmpTapRecognizer setNumberOfTapsRequired:1];
    [tmpTapRecognizer requireGestureRecognizerToFail:tmpDoubleTapRecognizer];
    [self.imageView addGestureRecognizer:tmpTapRecognizer];
    [tmpTapRecognizer release];
}

- (void)tapped
{
    // tapped
    
    if ( [self.footerView isHidden] ) {
//        [self performSelector:@selector(showFooter) withObject:nil afterDelay:0.2f];
        [self showFooter];
    } else {
//        [self performSelector:@selector(hideFooter) withObject:nil afterDelay:0.2f];
        [self hideFooter];
    }
    
}

- (void)doubleTapped
{
    // two taps

    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.imageView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {

                             if ( self.imageView.contentMode == UIViewContentModeScaleAspectFit ) {
                                 [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
                             } else {
                                 [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
                             }
                             
                             // and bring it back
                             [UIView animateWithDuration:0.2f
                                              animations:^{
                                                  [self.imageView setAlpha:1.0f];
                                              }];
                         }
                     }];
    
    
}

- (void)showFooter
{
    if ( [self.footerView isHidden] ) {
        [self.footerView setAlpha:0.0f]; // just to be sure
        [self.footerView setHidden:NO]; // show it
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [self.footerView setAlpha:1.0f]; // animate it in
                         }
         ];
    }
}

- (void)hideFooter
{
    if ( [self.footerView isHidden] == NO ) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [self.footerView setAlpha:0.0f]; // animate it out
                         }
                         completion:^(BOOL finished) {
                             if ( finished ) {
                                 [self.footerView setHidden:YES]; // then hide it
                             }
                         }
         ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
    
    if ( [self.dataObject isKindOfClass:[UIImage class]]) {
        [self.imageView setImage:self.dataObject];
    } else if ( [self.dataObject isKindOfClass:[NSURL class]] ) {
       [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:self.dataObject duration:2.0f]];
        self.dataLabel.text = [[[NSString stringWithFormat:@"%@",self.dataObject] componentsSeparatedByString:@"/"] lastObject];
        
    }
}

- (void)tweet:(id)sender
{
    if ( !self.isTweeting ) {
        // tweet it
        [self setIsTweeting:YES];
    }
}


- (void)setIsTweeting:(BOOL)isTweeting
{
    _isTweeting = isTweeting;
    
    if ( self.tweetButton ) {
        [self.tweetButton setEnabled:!isTweeting];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [self.tweetButton isEnabled] ? [self.tweetButton setAlpha:1.0] : [self.tweetButton setAlpha:0.5f];
                         }];
        
    }

}


@end
