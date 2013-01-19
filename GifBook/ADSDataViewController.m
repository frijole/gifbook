//
//  ADSDataViewController.m
//  GifBook
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "ADSDataViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimatedGIF.h"
#import "AFNetworking.h"
#import <Social/Social.h>
#import "ADSRootViewController.h"
#import "ADSModelController.h"

@interface ADSDataViewController ()

@property (nonatomic) BOOL isSharing;

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIImageView *logoImageView;

@end

@implementation ADSDataViewController

- (void)dealloc
{
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

    CGRect tmpLogoFrame = self.view.bounds;
    tmpLogoFrame.origin.y += 20;
    tmpLogoFrame.size.height -= 120;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner startAnimating];
    CGRect tmpFrame = CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 40);
    [_spinner setFrame:tmpFrame];
    [_spinner setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
    [self.view insertSubview:_spinner atIndex:0];
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [_logoImageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [_logoImageView setBackgroundColor:[UIColor clearColor]];
    [_logoImageView setAlpha:0.5f];
    [_logoImageView setFrame:tmpLogoFrame];
    [_logoImageView setContentMode:UIViewContentModeCenter];
    [self.view insertSubview:_logoImageView atIndex:0];
    [_logoImageView release];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
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
    if ( self.footerView && [self.footerView isHidden] ) {
        [self.footerView setAlpha:0.0f]; // just to be sure
        [self.footerView setHidden:NO]; // show it
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFooter) object:nil];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [self.footerView setAlpha:1.0f]; // animate it in
                         }
         completion:^(BOOL finished) {
             if ( finished ) {
                 [self performSelector:@selector(hideFooter) withObject:nil afterDelay:2.5f];
             }
         }
         ];
    }
}

- (void)hideFooter
{
    if ( self.footerView && [self.footerView isHidden] == NO ) {
       
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];

    [self.spinner startAnimating];
    [self.logoImageView setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // avoid scheduled calls firing while we're going away
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.imageView startAnimating];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifLoaded:) name:@"imageViewAnimatedGIFLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifFailed:) name:@"imageViewAnimatedGIFLoadingFailed" object:nil];
    
    [self setup];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.imageView stopAnimating];
}


- (void)setup
{
    self.labelItem.title = [self.dataObject description];
    
    if ( [self.dataObject isKindOfClass:[UIImage class]]) {
        [self.imageView setImage:self.dataObject];
    } else if ( [self.dataObject isKindOfClass:[NSURL class]] ) {
        // [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:self.dataObject duration:2.0f]];
        [AnimatedGif setAnimationForGifAtUrl:self.dataObject forView:self.imageView];
        
        self.labelItem.title = [[[NSString stringWithFormat:@"%@",self.dataObject] componentsSeparatedByString:@"/"] lastObject];
    }
}

- (void)gifLoaded:(NSNotification *)sender
{
//    NSLog(@"gifLoaded: %@",sender);
    
    if ( [sender object] == self.imageView ) {
        [_spinner stopAnimating];
        [_logoImageView setHidden:YES];
    } else {
//        NSLog(@"loadedGif received from %p but current image view is %p",sender.object,self.imageView);
    }
}

- (void)gifFailed:(NSNotification *)sender
{

    if ( [sender object] == self.imageView ) {
//        NSLog(@"this view controller's gif failed: %@",sender);
        // go to the next page
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:0.5f];
    } else {
//        NSLog(@"another view controller's gif failed: %@",sender);
    }
}

- (void)nextPage
{
    // go to the next page somehow
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageViewAdvanceRequest" object:self];
}

- (void)share:(id)sender
{
    if ( !self.isSharing ) {
        // share it
        [self setIsSharing:YES];
        
        // ditch the toolbar and status bar
        [self hideFooter];
        
        // UIImage *postImage = [UIImage animatedImageWithAnimatedGIFURL:self.dataObject duration:2.0f];
        NSArray *activityItems = @[[NSString stringWithFormat:@"%@ via @gifbookapp",self.dataObject]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, // print a gif? lulz.
                                                      UIActivityTypeAssignToContact, // no animation
                                                      UIActivityTypeCopyToPasteboard, // doesn't copy animation
                                                      UIActivityTypeSaveToCameraRoll, // saves static version
                                                      UIActivityTypeMail, // attachments don't animate
                                                      nil]];
        [self presentViewController:activityController  animated:YES completion:^{
            [self setIsSharing:NO];
        }];
    }
}



@end
