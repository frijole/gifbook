//
//  ADSRootViewController.m
//  GifBook
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "ADSRootViewController.h"

#import "ADSDataViewController.h"

@interface ADSRootViewController ()
@property (strong, nonatomic) UIImageView *pageCurl;
@end

@implementation ADSRootViewController

@synthesize modelController = _modelController;

- (void)dealloc
{
    [_pageViewController release];
    [_modelController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil] autorelease];
    self.pageViewController.delegate = self;

    NSUserDefaults *tmpPrefs = [NSUserDefaults standardUserDefaults];
    int tmpPrevLastPage = [tmpPrefs integerForKey:@"pageNumber"];

    // make sure its not too high
    if ( tmpPrevLastPage > self.modelController.numberOfPages-1 )
        tmpPrevLastPage = self.modelController.numberOfPages-1;
    
    ADSDataViewController *startingViewController = [self.modelController viewControllerAtIndex:tmpPrevLastPage storyboard:self.storyboard];

// for making icon parts ;)
//    UIView *tmpCurtain = [[UIView alloc] initWithFrame:startingViewController.view.bounds];
//    [tmpCurtain setBackgroundColor:[UIColor colorWithRed:222/255.0f green:0.0f blue:22/255.0f alpha:1.0f]];
//    [startingViewController.view addSubview:tmpCurtain];
//    [tmpCurtain release];
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationOrientationHorizontal animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 1.0, 1.0);
    // }
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    // self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    for ( UIGestureRecognizer *tmpGR in self.pageViewController.gestureRecognizers) {
        if ( [tmpGR isKindOfClass:[UITapGestureRecognizer class]] ) {
//            NSLog(@"found tap recognizer");
            [tmpGR setEnabled:NO];
        } else {
//            NSLog(@"found another recognizer");
        }
    }
    
    // listen for a request to advance a page
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancePage:) name:@"pageViewAdvanceRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rewindPages:) name:@"pageViewRewindRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastforwardPages:) name:@"pageViewFastforwardRequest" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ADSModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ADSModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    return UIPageViewControllerSpineLocationMin;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if ( finished ) {
        if ( [[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[ADSDataViewController class]] ) {
            int tmpPageNumber = [[self modelController] indexOfViewController:(ADSDataViewController *)[pageViewController.viewControllers objectAtIndex:0]];
            // NSLog(@"landed on page %d",tmpPageNumber);
        
            NSUserDefaults *tmpPrefs = [NSUserDefaults standardUserDefaults];
            [tmpPrefs setInteger:tmpPageNumber forKey:@"pageNumber"];
            [tmpPrefs synchronize];
            
        } else {
            NSLog(@"landed on page with unknown view controller type");
        }
    }
}


#pragma mark - Page View Advance Request Notification
- (void)advancePage:(NSNotification *)inNotification
{
    //  NSLog(@"root view controller received request to advance page: %@",inNotification);
    if ( [inNotification.object isKindOfClass:[ADSDataViewController class]] ) {

        int currentPage = [self.modelController indexOfViewController:inNotification.object];
        ADSDataViewController *nextViewController = [self.modelController viewControllerAtIndex:currentPage+1 storyboard:self.storyboard];
        if ( nextViewController ) {
            NSArray *viewControllers = @[nextViewController];
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        } else {
            NSLog(@"no more view controllers, disregarding request to advance");
        }
    } else {
        NSLog(@"request to advance page originated from unknown page controller class, disregarding request to advance");
    }
}

- (void)rewindPages:(NSNotification *)inNotification
{
    //  NSLog(@"root view controller received request to advance page: %@",inNotification);
    if ( [inNotification.object isKindOfClass:[ADSDataViewController class]] ) {
        
        int currentPage = [self.modelController indexOfViewController:inNotification.object];
        if ( currentPage == 0 ) {
            NSLog(@"at first view controller, disregarding request to rewind");
        } else {
            ADSDataViewController *nextViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
            if ( nextViewController ) {
                NSArray *viewControllers = @[nextViewController];
                [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
            } else {
                NSLog(@"error creating first view controller, bailing out of rewind request");
            }
        }
    } else {
            NSLog(@"request to rewind pages originated from unknown page controller class, disregarding request to advance");
    }
}

- (void)fastforwardPages:(NSNotification *)inNotification
{
    //  NSLog(@"root view controller received request to advance page: %@",inNotification);
    if ( [inNotification.object isKindOfClass:[ADSDataViewController class]] ) {
        
        int currentPage = [self.modelController indexOfViewController:inNotification.object];
        if ( currentPage == self.modelController.numberOfPages ) {
            NSLog(@"at last view controller, disregarding request to fast forward");
        } else {
            ADSDataViewController *nextViewController = [self.modelController viewControllerAtIndex:self.modelController.numberOfPages-1 storyboard:self.storyboard];
            if ( nextViewController ) {
                NSArray *viewControllers = @[nextViewController];
                [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
            } else {
                NSLog(@"error creating last view controller, bailing out of fast forward request");
            }
        }
    } else {
        NSLog(@"request to fast forward pages originated from unknown page controller class, disregarding request to advance");
    }
}
@end
