//
//  AppDelegate.m
//  Exporter
//
//  Created by Iain Wood on 12/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "AppDelegate.h"
#import "TreeNode.h"
#import "Project.h"
#import "PreferencesWindowController.h"
@class Aperture;

@interface Aperture:NSObject
// declare methods here
+(NSString *)libraryPath;
-(NSString *)libraryPath;
-(NSArray  *)getAllProjects;
@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

#define defaultPhotosPath @"~/Pictures"
#define photosPathKey @"photosPath"
#define defaultTopFolders @"2014,2013"
#define topFoldersKey @"topFolders"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *photosPath = [defaults stringForKey:photosPathKey];
  NSLog(@"photosPath: %@",photosPath);
  NSURL *photosURL = [NSURL URLWithString:[photosPath stringByStandardizingPath]];
  NSLog(@"Photos URL again : %@",photosURL);
  NSString *topFolders = [defaults objectForKey:topFoldersKey];
  NSLog(@"%@",topFolders);
}

- (void)awakeFromNib{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *photosPath = [defaults stringForKey:photosPathKey];
  if (photosPath == nil) {
    NSLog(@"photospath was nil");
    photosPath = defaultPhotosPath;
    [defaults setObject:photosPath forKey:photosPathKey];
  }
  NSString *topFolders = [defaults objectForKey:topFoldersKey];
  if (topFolders == nil) {
    NSLog(@"topFolders was nil");
    topFolders = defaultTopFolders;
    [defaults setObject:topFolders forKey:topFoldersKey];
  }
  [defaults synchronize];
  NSURL *photosURL = [NSURL URLWithString:[photosPath stringByStandardizingPath]];
  NSLog(@"Photos URL: %@",photosURL);
  
  aperture = [[NSClassFromString(@"Aperture") alloc] init];
  
  [treeController setContent:[self generateApertureTree:[aperture getAllProjects]]];
  [outlineView reloadData];
}

-(NSArray *)generateApertureTree:(NSArray *)apertureData {
  //  apertureData is an array of Dictionaries representing each year
  //  each year dictionary contains a yearName and an array of dictionaries representing months
  //  each month dictionary contains a name and an array of dictionaries representing projects
  //  ie:
  //
  //  NSArray *ar = [aperture getAllProjects];
  //  NSArray *aYear = ar[0];
  //  NSArray *aMonth = [aYear valueForKey:@"months"][2];
  //  NSDictionary *aProject = [aMonth valueForKey:@"projectNames"][3];
  //  NSLog(@"%@",aProject);
  //
  //  will show the 4th project of the 3rd month of the first year
  
  NSTreeNode *yearNode;
  NSTreeNode *monthNode;
  NSTreeNode *projectNode;
  NSMutableArray *rootNodes = [NSMutableArray array];
  for (id year in apertureData) {
    NSString *yearName = [year valueForKey:@"yearName"];
    yearNode = [ TreeNode makeNode:yearName];
    for (id month in [year valueForKey:@"months"]){
      NSString *monthName = [month valueForKey:@"monthName"];
      monthNode = [TreeNode makeNode:monthName];
      for (id project in [month valueForKey:@"projectNames"]){
        NSString *projectName = [project valueForKey:@"projectName"];
        Project *projectInstance = [Project projectWithName:projectName month:monthName year:yearName];
        BOOL projectExported = [projectInstance exported];
        projectNode = [TreeNode makeNode:projectName exported:projectExported];
        [[monthNode mutableChildNodes] addObject:projectNode];
      }
      [[yearNode mutableChildNodes] addObject:monthNode];
    }
    [rootNodes addObject:yearNode];
  }
  return rootNodes;
}

- (IBAction)showPreferences:(id)sender {
  preferencesWindowController = [[PreferencesWindowController alloc] init];
  //[preferencesWindowController showWindow:sender];
  [[preferencesWindowController window] makeMainWindow];
  [[preferencesWindowController window] makeKeyWindow];
}

@end
