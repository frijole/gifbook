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
#import "Reachability.h"

@interface ADSDataViewController () <NSURLConnectionDelegate>
{
    float _downloadSize;
    NSURLConnection *_urlConnection;
    NSMutableData *_receivedData;
}

@property (nonatomic) BOOL isSharing;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIProgressView *progressBar;
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
    CGRect tmpFrame = CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 40);
    [_spinner setFrame:tmpFrame];
    [_spinner setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
    [_spinner setHidden:YES];
    [self.view insertSubview:_spinner atIndex:0];
    
    self.progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height-90, 100, 23)];
    [self.progressBar setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
    // customize appearance
    UIImage *track = [[UIImage imageNamed:@"track.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 12, 1, 12)];
    [self.progressBar setTrackImage:track];
    UIImage *progress = [[UIImage imageNamed:@"bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 12, 1, 12)];
    [self.progressBar setProgressImage:progress];
    [self.progressBar setProgress:0.1f animated:NO];
    // put a view on it
    [self.view addSubview:self.progressBar];
    [self.progressBar release];
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [_logoImageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [_logoImageView setBackgroundColor:[UIColor clearColor]];
    [_logoImageView setAlpha:0.5f];
    [_logoImageView setFrame:tmpLogoFrame];
    [_logoImageView setContentMode:UIViewContentModeCenter];
    [self.view insertSubview:_logoImageView atIndex:0];
    [_logoImageView release];
    
    if ( self.navbar.items.count > 0 ) {
        UINavigationItem *tmpNavItem = (UINavigationItem *)[self.navbar.items objectAtIndex:0];
        
        [tmpNavItem setTitle:[NSString stringWithFormat:@"%d of %d+",[self.modelController indexOfViewController:self]+1,[self.modelController numberOfPages]]];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setFrame:CGRectMake(0, 0, 30, 30)];
        [tmpButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
        [tmpButton.imageView setContentMode:UIViewContentModeCenter];
        [tmpButton setShowsTouchWhenHighlighted:YES];
        [tmpButton addTarget:self action:@selector(trash:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *tmpBBI = [[UIBarButtonItem alloc] initWithCustomView:tmpButton];
        [tmpNavItem setLeftBarButtonItem:tmpBBI];
        [tmpBBI release];

        tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setFrame:CGRectMake(0, 0, 30, 30)];
        [tmpButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        [tmpButton.imageView setContentMode:UIViewContentModeCenter];
        [tmpButton setShowsTouchWhenHighlighted:YES];
        [tmpButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        tmpBBI = [[UIBarButtonItem alloc] initWithCustomView:tmpButton];
        [tmpNavItem setRightBarButtonItem:tmpBBI];
        [tmpBBI release];
  }

    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)tapped
{
    // tapped
    
    // log it
    [TestFlight passCheckpoint:@"gif_tapped"];

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

    // log it
    [TestFlight passCheckpoint:@"gif_doubletapped"];

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
    // log it
    [TestFlight passCheckpoint:@"footer_show"];
    
    // reset the timer: cancel scheduled requests and call a new one
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ( self.autoPlay ) {
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:5.0f];
    }
    
    if ( self.footerView && [self.footerView isHidden] ) {
        
        [self.footerView setAlpha:0.0f];    // just to be sure
        [self.footerView setHidden:NO];     // show it

        [self.navbar setAlpha:0.0f];
        [self.navbar setHidden:NO];

        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFooter) object:nil];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self.footerView setAlpha:1.0f]; // animate it in
                             [self.navbar setAlpha:1.0f];
                         }
         completion:^(BOOL finished) {
             if ( finished ) {
                 // [self performSelector:@selector(hideFooter) withObject:nil afterDelay:5.0f];
             }
         }
         ];
    }
}

- (void)hideFooter
{
    // log it
    [TestFlight passCheckpoint:@"footer_hide"];
    
    if ( self.footerView && [self.footerView isHidden] == NO ) {
       
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self.footerView setAlpha:0.0f];   // animate it out
                             [self.navbar setAlpha:0.0f];      // animate it out
                         }
                         completion:^(BOOL finished) {
                             if ( finished ) {
                                 [self.footerView setHidden:YES];   // then hide it
                                 [self.navbar setHidden:YES];      // then hide it
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

    [self.spinner setHidden:YES];
    [self.logoImageView setHidden:NO];
    
    // check autoplay, configure toolbar button
    if ( self.autoPlay ) {
        // set the button
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"]];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"play.png"]];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // avoid scheduled calls firing while we're going away
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self hideFooter];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.imageView startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifLoaded:) name:@"imageViewAnimatedGIFLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifFailed:) name:@"imageViewAnimatedGIFLoadingFailed" object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self setup];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.imageView stopAnimating];

    // see if we hvae a pending download to cancel, and cancel it
    if ( _urlConnection ) {
        [_urlConnection cancel];
    }
}


- (void)setup
{
    if ( [self.dataObject isKindOfClass:[NSURL class]] && !_urlConnection && self.imageView.animationImages.count == 0 ) {
        // if we have a URL, and don't have a download or an animation... (this avoids redoing it when someone starts to turn the page, then stops.
        
        // self.labelItem.title = [[[NSString stringWithFormat:@"%@",self.dataObject] componentsSeparatedByString:@"/"] lastObject];
        // [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:self.dataObject duration:2.0f]];
        
        // [AnimatedGif setAnimationForGifAtUrl:self.dataObject forView:self.imageView];
        
        // Create a request.
        NSURLRequest *tmpRequest = [NSURLRequest requestWithURL:self.dataObject
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                timeoutInterval:10]; // only 10 seconds before we bail.
        // create the connection with the request
        // and start loading the data
        _urlConnection = [[NSURLConnection alloc] initWithRequest:tmpRequest delegate:self];
        if ( _urlConnection ) {
            // Create a NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
        }
    }
}

- (void)startAutoplay:(id)sender
{
    if ( !self.autoPlay ) {
        // log it
        [TestFlight passCheckpoint:@"autoplay_started"];
        
        // set the flag
        [self setAutoPlay:YES];
        
        // disable screen dim/sleep
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        // update the button
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"]];
        
        // and advance after a short delay
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:1.0f];
    } else {
        // log it
        [TestFlight passCheckpoint:@"autoplay_stopped"];
        
        // set the flag
        [self setAutoPlay:NO];

        // enable screen dim/sleep
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        // update the button
        [self.playButton setImage:[UIImage imageNamed:@"play.png"]];
        
        // cancel scheduled advance request
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextPage) object:nil];
    }
}

- (void)gifLoaded:(NSNotification *)sender
{
//    NSLog(@"gifLoaded: %@",sender);
    
    if ( [sender object] == self.imageView ) {
        [_spinner stopAnimating];
        [_logoImageView setHidden:YES];
        [_progressBar setHidden:YES];
        [_imageView setHidden:NO];
        
        // autoplay? start timer
        if ( self.autoPlay ) {
            
            if ( self.imageView.animationDuration > 3 ) {
                [self performSelector:@selector(nextPage) withObject:nil afterDelay:(2.5f*self.imageView.animationDuration)];
            } else {
                [self performSelector:@selector(nextPage) withObject:nil afterDelay:5.0f];
            }
            
        }

    } else {
//        NSLog(@"loadedGif received from %p but current image view is %p",sender.object,self.imageView);
    }
}

- (void)gifFailed:(NSNotification *)sender
{
    // log it
    [TestFlight passCheckpoint:@"gif_failed"];

    if ( [sender object] == self.imageView ) {
//        NSLog(@"this view controller's gif failed: %@",sender);
        
        // present failure
        [self.imageView setHidden:YES];
        [self.logoImageView setHidden:NO];
        [self.progressBar setHidden:YES];
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.spinner.frame.origin.x-75, self.spinner.frame.origin.y-5,
                                                                      self.spinner.frame.size.width+150, self.spinner.frame.size.height+10)];
        [tmpLabel setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
        [tmpLabel setBackgroundColor:[UIColor clearColor]];
        [tmpLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        [tmpLabel setTextAlignment:NSTextAlignmentCenter];
        [tmpLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [tmpLabel setNumberOfLines:2];
        [tmpLabel setText:@"there was a problem\nwith the download or file"];
        [self.view addSubview:tmpLabel];
        [tmpLabel release];

        
        // go to the next page
        // [self performSelector:@selector(nextPage) withObject:nil afterDelay:0.75f];

        // delete this image (will advance to the next page for us)
        // [self trash:nil];
        [self performSelector:@selector(trash:) withObject:nil afterDelay:0.25f]; // short delay before moving on

    } else {
//        NSLog(@"another view controller's gif failed: %@",sender);
    }
}

- (void)nextPage
{
    // go to the next page somehow
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageViewAdvanceRequest" object:self];
}

- (IBAction)rewind:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageViewRewindRequest" object:self];
}

- (IBAction)fastforward:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageViewFastforwardRequest" object:self];
}

- (void)share:(id)sender
{
    // log it
    [TestFlight passCheckpoint:@"gif_share"];

    // cancel any pending advances
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if ( !self.isSharing ) {
        // share it
        [self setIsSharing:YES];
        
        // ditch the toolbar and status bar
        [self hideFooter];
        
        // UIImage *postImage = [UIImage animatedImageWithAnimatedGIFURL:self.dataObject duration:2.0f];
        NSArray *activityItems = @[[NSString stringWithFormat:@"%@ via @gifbookapp",self.dataObject]];
        UIActivityViewController *activityController = [[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil] autorelease];
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

- (void)trash:(id)sender
{
    // log it
    [TestFlight passCheckpoint:@"gif_deleted"];

    // cancel any pending advances
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if ( self.modelController ) {

        // request an advance first, while the mode vc can still get index of the current page via its dataobject
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pageViewAdvanceRequest" object:self];

        if ( [self.modelController removeGif:self.dataObject] ) {
            // deleted
            NSLog(@"deleted gif: %@", self.dataObject);
        } else {
            NSLog(@"failed to delete gif: %@", self.dataObject);
        }
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)connection: (NSURLConnection*)connection didReceiveResponse: (NSHTTPURLResponse*) response
{
    NSInteger tmpStatusCode_ = [response statusCode];
    if (tmpStatusCode_ == 200) {
    
        if ( response.expectedContentLength > 5*pow(2, 20) ) {
            // too big
            [self gifFailed:[NSNotification notificationWithName:@"gifFailed" object:self.imageView]];
            [connection cancel];
        } else {
            _downloadSize = [response expectedContentLength];
        }
    
    
    } if ( tmpStatusCode_ == 404 ) {
        // make a fake notification
        NSLog(@"Download failed: %@ %@", @"404", response.URL);
        [self gifFailed:[NSNotification notificationWithName:@"gifFailed" object:self.imageView]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
    
    [self.progressBar setProgress:(_receivedData.length/_downloadSize) animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    _urlConnection = nil;
    
    // receivedData is declared as a method instance elsewhere
    [_receivedData release];
    _receivedData = nil;
    
    // inform the user
    NSLog(@"Download failed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if ( [error code] == NSURLErrorNotConnectedToInternet ) {
        // offline
        [self.imageView setHidden:YES];
        [self.logoImageView setHidden:NO];
        [self.progressBar setHidden:YES];
        [self.spinner setHidden:YES];
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.spinner.frame.origin.x-75, self.spinner.frame.origin.y-5,
                                                                      self.spinner.frame.size.width+150, self.spinner.frame.size.height+10)];
        [tmpLabel setBackgroundColor:[UIColor clearColor]];
        [tmpLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        [tmpLabel setTextAlignment:NSTextAlignmentCenter];
        [tmpLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [tmpLabel setNumberOfLines:2];
        [tmpLabel setText:@"no internet connection"];
        [self.view addSubview:tmpLabel];
        [tmpLabel release];
        
    } else {
        // make a fake notification
        [self gifFailed:[NSNotification notificationWithName:@"gifFailed" object:self.imageView]];
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
//    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    
    
    [self.progressBar setHidden:YES];
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    if ( [AnimatedGif setAnimationForGifWithData:_receivedData forView:self.imageView] ) {
//        NSLog(@"parsing gif...");
    } else {
        NSLog(@"failed to initiate parsing.");
    }

    // release the connection, and the data object
    [connection release];
    [_receivedData release];

    // clear convenience pointer to released connection and data
    _urlConnection = nil;
    _receivedData = nil;
}

@end
