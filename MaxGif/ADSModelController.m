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

#import "AFNetworking.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface ADSModelController()
{
    BOOL _fetching;
}

@property (strong, nonatomic) NSMutableArray *pageData;

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
        self.pageData = [NSMutableArray array];
        
        for ( NSString *gifAddress in [NSArray arrayWithObjects:@"http://25.media.tumblr.com/65fb793b66ac2c5b57236a78ccfb4437/tumblr_mgp9jgo1FF1qa2d04o1_500.gif",
                                       @"http://25.media.tumblr.com/564890ce29aaa87f2e8bae45fe5c3d2f/tumblr_mgnwf9ld0B1qfg786o1_500.gif",
                                       @"http://25.media.tumblr.com/4d6bfe7484da35cf9dd235d60109fe47/tumblr_mg6ld5tbaG1qehntzo1_500.gif",
                                       @"http://25.media.tumblr.com/0a9f27187f486be9d24a4760b89ac03a/tumblr_mgn52pl4hI1qg39ewo1_500.gif",
                                       @"http://24.media.tumblr.com/tumblr_m7dbzmGd4n1qzqdulo1_500.gif",
                                       @"http://24.media.tumblr.com/1e56a4ab8fda12c8e396fe02a850939a/tumblr_mg9x5pQUlH1qd4q8ao1_500.gif",
                                       nil] ) {
            NSURL *tmpGIFUrl = [NSURL URLWithString:gifAddress];
            if ( tmpGIFUrl ) {
                [self.pageData addObject:tmpGIFUrl];
            }
        }
        
    }
    
    [self getAGif];
    
    return self;
}

- (ADSDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    if ( index > self.pageData.count-3 ) {
        [self getAGif];
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

- (NSUInteger)numberOfPages
{
    return self.pageData.count;
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

#pragma mark - Web Updating
- (void)getAGif
{
    if ( !_fetching ) {
        _fetching = YES;
        
        NSString *tmpURLString = @"http://iank.org/picbot/pic?type=gif";
        AFJSONRequestOperation *tmpRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tmpURLString]]
                                                                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                 // parse 'it
                                                                                                 [JSON valueForKey:@"pic"] ? [self addGif:[JSON valueForKey:@"pic"]] : nil;
                                                                                                 // clear the block
                                                                                                 _fetching = NO;
                                                                                                 
                                                                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                 //
                                                                                                 NSLog(@"failed to download new url");
                                                                                             }];
        [tmpRequest start];
    }
}

- (void)getGifs:(NSInteger)inQuantity
{
    if ( !_fetching ) {
        _fetching = YES;
        
        NSString *tmpURLString = [NSString stringWithFormat:@"http://iank.org/picbot/pic?n=%dtype=gif",inQuantity];
        AFJSONRequestOperation *tmpRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tmpURLString]]
                                                                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                 // parse 'em
                                                                                                 for ( NSString *tmpGIFAddress in [JSON valueForKey:@"pics"] ) {
                                                                                                     [self addGif:tmpGIFAddress];
                                                                                                 }
                                                                                                 // clear the block
                                                                                                 _fetching = NO;

                                                                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                 //
                                                                                                 NSLog(@"failed to download new url");
                                                                                             }];
        [tmpRequest start];
    }
}

- (void)addGif:(NSString *)inString
{
    if ( ![inString isKindOfClass:[NSString class]] ) {
        NSLog(@"git string is not a string (%@)",NSStringFromClass([inString class]));
    } else if ( [inString rangeOfString:@"https"].location != NSNotFound ) {
        NSLog(@"gif contained https, discarding");
        [self getAGif];
    } else if ( [inString rangeOfString:@"http"].location != NSNotFound &&
               [inString rangeOfString:@"gif"].location != NSNotFound ) {
        [self.pageData addObject:[NSURL URLWithString:inString]];
        NSLog(@"added new url: %@",inString);
    } else {
        NSLog(@"no valid url found in downloaded url: %@",inString);
    }
}

@end
