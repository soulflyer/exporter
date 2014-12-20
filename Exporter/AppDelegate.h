//
//  AppDelegate.h
//  Exporter
//
//  Created by Iain Wood on 12/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Aperture;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
  Aperture *aperture;
  IBOutlet NSOutlineView *outlineView;
}


@end

