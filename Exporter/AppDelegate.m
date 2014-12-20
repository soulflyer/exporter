//
//  AppDelegate.m
//  Exporter
//
//  Created by Iain Wood on 12/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "AppDelegate.h"
@class Aperture;

@interface Aperture:NSObject
// declare methods here
+(NSString *)libraryPath;
-(NSString *)libraryPath;
-(NSArray  *)topLevelFolders;
-(NSString *)getFolderID;
-(NSString *)getFolderName:(NSString*)folderID;
-(NSArray  *)getChildren:(NSString*)folderID;
@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  aperture = [[NSClassFromString(@"Aperture") alloc] init];
  NSString *blah = [NSClassFromString(@"Aperture") libraryPath];
  NSLog(@"LibPath from class method: %@",blah);
                  
  NSArray *topFolders=[aperture topLevelFolders];
  NSLog(@"topFolders: %@",topFolders);
  [outlineView expandItem:[outlineView itemAtRow:0]];
  //NSString *folderID=[aperture getFolderID];
  //NSString  *folderID=topFolders[2];
  //NSArray *charray=[aperture getChildrenRecords:folderID];
  //NSLog(@"getChildrenRecords: %@",charray);
  
  //NSString  *folderID=topFolders[2];
  //NSLog(@"FolderID: %@",folderID);
  //NSString *folderName=[aperture getFolderName:folderID];
  //NSLog(@"Folder: %@",folderName);
  //NSArray *childrenArray = [aperture getChildren:folderID];
  //NSLog(@"%@",childrenArray);
  
}

@end
