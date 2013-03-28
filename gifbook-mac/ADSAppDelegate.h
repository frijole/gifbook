//
//  ADSAppDelegate.h
//  gifbook-mac
//
//  Created by Ian on 3/28/13.
//  Copyright (c) 2013 Adelie Software. All rights reserved.
//

#import "MenubarController.h"
#import "PanelController.h"

@interface ADSAppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;

@end
