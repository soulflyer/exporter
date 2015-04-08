//
//  AppDelegate.h
//  Exporter
//
//  Created by Iain Wood on 12/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Foundation/Foundation.h>
@class Aperture,PreferencesWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
  Aperture *aperture;
  NSArray *apertureTree;
  IBOutlet NSOutlineView *outlineView;
  IBOutlet NSTreeController *treeController;
  //IBOutlet NSTextView *consoleWindow;
  //IBOutlet NSString *statusMessage;
  IBOutlet PreferencesWindowController *preferencesWindowController;
}
- (IBAction)export:(id)sender;
@property (assign) NSInteger numberValue;
@property (assign) NSString* statusMessage;
@property (assign) BOOL exportButtonState;
@property (assign) NSTextView* consoleWindow;
@end

