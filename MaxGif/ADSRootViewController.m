//
//  ADSRootViewController.m
//  MaxGif
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "ADSRootViewController.h"

#import "ADSModelController.h"

#import "ADSDataViewController.h"

@interface ADSRootViewController ()
@property (readonly, strong, nonatomic) ADSModelController *modelController;
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

    ADSDataViewController *startingViewController = [self.modelController viewControllerAtIndex:1 storyboard:self.storyboard];
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

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
//{
//    
//    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"transitionStarting" object:nil]];
//}
//
//
//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"transitionDone" object:nil]];
//}


- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // always one page on the top
    return UIPageViewControllerSpineLocationMin;
}

@end
