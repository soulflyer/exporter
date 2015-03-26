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
-(void) exportPictures:(NSString *)blah toDirectory:(NSString *)unk;
-(BOOL)exportPics:(NSString *)selection toDirectory:(NSString *)thePath atSize:(NSString *)theExportSetting withWatermark:(BOOL)watermark;
-(BOOL)exportProject:(NSString *)theProjectPath toDirectory:(NSString *)thePath atSize:(NSString *)theSize withWatermark:(NSString *)watermark;
-(BOOL) setup;
-(BOOL) teardown;
-(BOOL) setExportDate:(NSString *)theProjectPath;
@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

#define defaultPhotosPath @"~/Pictures"
#define photosPathKey @"photosPath"
#define defaultTopFolders @"2014,2015"
#define topFoldersKey @"topFolders"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSLog(@"applicationDidFinishLaunching");
  // Insert code here to initialize your application
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//  NSString *photosPath = [defaults stringForKey:photosPathKey];
//  NSLog(@"photosPath: %@",photosPath);
//  NSURL *photosURL = [NSURL URLWithString:[photosPath stringByStandardizingPath]];
//  NSLog(@"Photos URL again : %@",photosURL);
//  NSString *topFolders = [defaults objectForKey:topFoldersKey];
//  NSLog(@"%@",topFolders);
  
}

- (void)awakeFromNib{
  NSLog(@"awakeFromNib");
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
  //NSURL *photosURL = [NSURL URLWithString:[photosPath stringByStandardizingPath]];
  //NSLog(@"Photos URL: %@",photosURL);
  
  aperture = [[NSClassFromString(@"Aperture") alloc] init];
  [aperture setup];
  apertureTree = [aperture getAllProjects];
  
  [treeController setContent:[self generateApertureTree:apertureTree]];
  [outlineView reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [aperture teardown];
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
        BOOL    projectExported    = [projectInstance exported];
        NSDate *projectFirstExport = [projectInstance firstExportDate];
        NSDate *projectLastExport  = [projectInstance lastExportDate];
        projectNode = [TreeNode makeNode:projectName exported:projectExported firstExport:projectFirstExport lastExport:projectLastExport];
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

- (IBAction)export:(id)sender {
  //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  for (id thing in [treeController selectionIndexPaths]){
    NSUInteger length= [thing length];
    if (length < 3){
      NSLog(@"Can't yet export folders of projects");
    } else {
      NSUInteger indexes[3];
      [thing getIndexes:indexes];
      NSUInteger year    = indexes[0];
      NSUInteger month   = indexes[1];
      NSUInteger project = indexes[2];
      NSString *yearName    = [apertureTree[year] objectForKey:@"yearName"];
      NSString *monthName   = [[apertureTree[year] objectForKey:@"months"][month] objectForKey:@"monthName"];
      NSString *projectName = [[[apertureTree[year] objectForKey:@"months"][month] objectForKey:@"projectNames"][project] objectForKey:@"projectName"];

      Project *projectToExport=[Project projectWithName:projectName month:monthName year:yearName];
      NSLog(@"%@ ",[projectToExport path]);

      NSLog(@"Thumb Path:    %@",[projectToExport thumbPath]);
      NSLog(@"Medium Path:   %@",[projectToExport mediumPath]);
      NSLog(@"Large Path:    %@",[projectToExport largePath]);
      NSLog(@"Fullsize Path: %@",[projectToExport fullsizePath]);
      [aperture exportProject:[projectToExport path] toDirectory:[projectToExport thumbPath] atSize:@"JPEG - Thumbnail" withWatermark:@"false"];
      [aperture exportProject:[projectToExport path] toDirectory:[projectToExport mediumPath] atSize:@"JPEG - Fit within 1024 x 1024" withWatermark:@"true"];
      [aperture exportProject:[projectToExport path] toDirectory:[projectToExport largePath] atSize:@"JPEG - Fit within 2048 x 2048" withWatermark:@"true"];
      [aperture exportProject:[projectToExport path] toDirectory:[projectToExport fullsizePath] atSize:@"JPEG - Original Size" withWatermark:@"false"];
      
      [aperture setExportDate:[projectToExport path]];
      
      //[aperture exportPictures:[projectToExport path] toDirectory:[defaults stringForKey:photosPathKey]];
    }
  }
}
@end
