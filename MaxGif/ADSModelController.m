//
//  ADSModelController.m
//  MaxGif
//
//  Created by Ian Meyer on 1/12/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "ADSModelController.h"

#import "ADSDataViewController.h"

#import "UIImage+animatedGIF.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface ADSModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;
@end

@implementation ADSModelController

- (void)dealloc
{
    [_pageData release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        // NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        // _pageData = [[dateFormatter monthSymbols] copy];
        
        NSMutableArray *tmpPageData = [NSMutableArray array];

        // for ( NSString *gifFile in [NSArray arrayWithObjects:@"wallet-blam.gif",@"head-bounce.gif",@"cat-run.gif",nil] ) {
        for ( NSString *gifFile in [NSArray arrayWithObjects:@"head-bounce.gif",nil] ) {

            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gifFile];
            NSURL *tmpGIFUrl = [NSURL fileURLWithPath:path isDirectory:NO];
            UIImage *tmpGIF = [UIImage animatedImageWithAnimatedGIFURL:tmpGIFUrl duration:5.0f];
            if ( tmpGIF ) {
                [tmpPageData addObject:tmpGIF];
                [tmpPageData addObject:tmpGIF];
                [tmpPageData addObject:tmpGIF];
            } else {
                NSLog(@"error loading %@",tmpGIFUrl);
            }
        }
        
        _pageData = [[NSArray arrayWithArray:tmpPageData] retain];
        
    }
    return self;
}

- (ADSDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ADSDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"ADSDataViewController"];
    dataViewController.dataObject = self.pageData[index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(ADSDataViewController *)viewController
{   
     // Return the index of the given data view controller.
     // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(ADSDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(ADSDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
