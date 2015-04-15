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
#import "IntegerToColourTransformer.h"

@class Aperture;

@interface Aperture:NSObject
// declare methods here
+(NSString *)libraryPath;
-(NSString *)libraryPath;
-(NSArray  *)getAllProjects;
-(BOOL)exportProject:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear toDirectory:(NSString *)thePath atSize:(NSString *)theSize withWatermark:(NSString *)watermark exportEverything:(NSString *)everything;
-(BOOL)setup;
-(BOOL)teardown;
-(BOOL)setExportDateOf:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
-(BOOL)setExportDateOfModified:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
-(NSString *)getNotes:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
-(NSString *)isUptodate:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
-(NSArray *)modifiedPics:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
-(NSArray *)exportedPics:(NSString *)theProject ofMonth:(NSString *)theMonth ofYear:(NSString *)theYear;
@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

#define defaultPhotosPath @"~/Pictures"
#define photosPathKey @"photosPath"
#define defaultTopFolders @"2014,2015"
#define topFoldersKey @"topFolders"
#define defaultMastersPath @"~/Pictures/Photos"
#define mastersPathKey @"mastersPath"

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
  NSString *mastersPath = [defaults objectForKey:mastersPathKey];
  if (mastersPath ==nil) {
    NSLog(@"mastersPath was nil");
    mastersPath = defaultMastersPath;
    [defaults setObject:mastersPath forKey:mastersPathKey];
  }
  [defaults synchronize];
  
  aperture = [[NSClassFromString(@"Aperture") alloc] init];
  [aperture setup];
  apertureTree = [aperture getAllProjects];
  
  [treeController setContent:[self generateApertureTree:apertureTree]];
  [outlineView reloadData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self setExportButtonState:true];
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
        if (projectExported) {
          projectNode = [TreeNode makeNode:projectName exported:projectExported firstExport:projectFirstExport lastExport:projectLastExport];}
        else{
          projectNode = [TreeNode makeNode:projectName];
        }
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


NSString* runCommand(NSString *commandToRun) {
  // Credit to Kenial http://stackoverflow.com/questions/412562/execute-a-terminal-command-from-a-cocoa-app/696942#696942
  NSTask *task;
  task = [[NSTask alloc] init];
  [task setLaunchPath: @"/bin/sh"];
  
  NSArray *arguments = [NSArray arrayWithObjects:
                        @"-c" ,
                        [NSString stringWithFormat:@"%@", commandToRun],
                        nil];
  NSLog(@"run command: %@",commandToRun);
  [task setArguments: arguments];
  
  NSPipe *pipe;
  pipe = [NSPipe pipe];
  [task setStandardOutput: pipe];
  
  NSFileHandle *file;
  file = [pipe fileHandleForReading];
  
  [task launch];
  
  NSData *data;
  data = [file readDataToEndOfFile];
  
  return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (NSArray *)selectedProjectIndexes{
  NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:1];
  for (id projectIndex in [treeController selectionIndexPaths]){
    NSUInteger length= [projectIndex length];
    if (length == 3){
      [returnArray addObject:projectIndex];
    }
  }
  return [NSArray arrayWithArray:returnArray];
}


-(void)markProjectAtIndexPath:(NSIndexPath *)indexPath withState:(enum modifiedState)state{
  NSUInteger indexes[3];
  [indexPath getIndexes:indexes];
  NSUInteger year    = indexes[0];
  NSUInteger month   = indexes[1];
  NSUInteger project = indexes[2];
  NSTreeNode *nd = [[[[treeController content][year] childNodes][month] childNodes][project] representedObject];
  [nd setValue:[NSString stringWithFormat:@"%d",state]  forKey:@"modified"];
}

-(void)markProjectAtIndexPath:(NSIndexPath *)indexPath withState:(enum modifiedState)state andExportDate:(NSDate*) exportDate{
  NSUInteger indexes[3];
  [indexPath getIndexes:indexes];
  NSUInteger year    = indexes[0];
  NSUInteger month   = indexes[1];
  NSUInteger project = indexes[2];
  NSTreeNode *nd = [[[[treeController content][year] childNodes][month] childNodes][project] representedObject];
  [nd setValue:[NSString stringWithFormat:@"%d",state]  forKey:@"modified"];
  [nd setValue:exportDate forKey:@"lastExport"];
}

-(Project *)projectFromIndexPath:(NSIndexPath *)indexPath{
  NSUInteger indexes[3];
  [indexPath getIndexes:indexes];
  NSUInteger year    = indexes[0];
  NSUInteger month   = indexes[1];
  NSUInteger project = indexes[2];
  NSString *yearName    = [apertureTree[year] objectForKey:@"yearName"];
  NSString *monthName   = [[apertureTree[year] objectForKey:@"months"][month] objectForKey:@"monthName"];
  NSString *projectName = [[[apertureTree[year] objectForKey:@"months"][month] objectForKey:@"projectNames"][project] objectForKey:@"projectName"];
  return[Project projectWithName:projectName month:monthName year:yearName];
}

- (IBAction)modified:(id)sender {
  [self setStatusMessage:@"Checking projects for updated pics"];
  [[self window] displayIfNeeded];
  for (NSIndexPath *indexPath in [self selectedProjectIndexes]){
    Project *project = [self projectFromIndexPath:indexPath];
    [self setStatusMessage:[NSString stringWithFormat:@"Checking %@",[project name]]];
    [[self window] displayIfNeeded];
    NSArray *modifiedPics = [aperture modifiedPics:[project name] ofMonth:[project month] ofYear:[project year]];
    [self setStatusMessage:[NSString stringWithFormat:@"Check complete, found %lu pics", (unsigned long)[modifiedPics count]]];
    if ([modifiedPics count] > 0) {
      NSLog(@"Modified %@",modifiedPics);
      [[self consoleWindow] insertText:[NSString stringWithFormat:@"%@ ",[project name]]];
      [[self consoleWindow] insertText:[NSString stringWithFormat:@"%@\n",modifiedPics]];
      [[self window] displayIfNeeded];
      [self markProjectAtIndexPath:indexPath withState:dirty];
    }else{
      //[self markProjectAtIndexPath:indexPath withState:clean];
      NSArray *exportedPics = [aperture exportedPics:[project name] ofMonth:[project month] ofYear:[project year]];
      if ([exportedPics count] > 0){
        if ([project exported]) {
          [self markProjectAtIndexPath:indexPath withState:clean];
          NSLog(@"There are already pictures exported");
          [self setStatusMessage:[NSString stringWithFormat:@"There are already pictures exported from %@", [project name]]];
        }else{
          [self markProjectAtIndexPath:indexPath withState:dirty];
          NSLog(@"There are pictures to export");
          [self setStatusMessage:[NSString stringWithFormat:@"There are pictures to export in %@", [project name]]];
        }
      }else{
        [self markProjectAtIndexPath:indexPath withState:unknown];
        NSLog(@"No pictures to export");
        [self setStatusMessage:[NSString stringWithFormat:@"No pictures to export in %@", [project name]]];
      }
      [[self window] displayIfNeeded];
    }
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
  }
}

- (void)doExport:(BOOL)full{
  NSString *fullString = @"false";
  if (full) {
    fullString = @"true";
  }else{
    fullString = @"false";
  }
  for (NSIndexPath *indexPath in [self selectedProjectIndexes]){
    Project *project = [self projectFromIndexPath:indexPath];
    NSArray *exportedPics = [aperture exportedPics:[project name] ofMonth:[project month] ofYear:[project year]];
    NSLog(@"Piclist %@", exportedPics);
    NSLog(@"Piclist count %lu", (unsigned long)[exportedPics count]);
    NSLog(@"mastersPath %@",[[project mastersPath] stringByExpandingTildeInPath]);
    
    //Check if there are any exporteable pictures
    if ([exportedPics count] > 0) {
      
      //Check if the photos are online
      if ([[NSFileManager defaultManager] fileExistsAtPath:[[project mastersPath]stringByExpandingTildeInPath]]) {
        
        //Check if project has never been exported
        if (![project exported]) {
          NSLog(@"project not yet exported, should do full export");
          fullString = @"true";
        }
        
        [self setStatusMessage:@"Exporting thumbnails"];
        [[self window] displayIfNeeded];
        [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[project thumbPath] atSize:@"JPEG - Thumbnail" withWatermark:@"false" exportEverything:fullString];
        
        [self setStatusMessage:@"Exporting medium"];
        [[self window] displayIfNeeded];
        [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[project mediumPath] atSize:@"JPEG - Fit within 1024 x 1024" withWatermark:@"true" exportEverything:fullString];
        
        [self setStatusMessage:@"Exporting large"];
        [[self window] displayIfNeeded];
        [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[project largePath] atSize:@"JPEG - Fit within 2048 x 2048" withWatermark:@"true" exportEverything:fullString];
        
        [self setStatusMessage:@"Exporting fullsize"];
        [[self window] displayIfNeeded];
        [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[project fullsizePath] atSize:@"JPEG - Original Size" withWatermark:@"false" exportEverything:fullString];
        
        [self setStatusMessage:@"Setting exported date"];
        [[self window] displayIfNeeded];
        [aperture setExportDateOf:[project name] ofMonth:[project month] ofYear:[project year]];
        
        [self setStatusMessage:@"Getting notes"];
        [[self window] displayIfNeeded];
        NSString *notes=[aperture getNotes:[project name] ofMonth:[project month] ofYear:[project year]];
        NSLog(@"Notes %@",notes);
        if (!notes) {
          notes=(@"");
        }
        NSLog(@"Notes %@",notes);
        NSString *cmd = [NSString stringWithFormat:@"mkdir -p %@; echo \"%@\" > %@/notes.txt", [project rootPath], notes, [project rootPath]];
        //NSLog(@"%@",cmd);
        runCommand(cmd);
        
        [self setStatusMessage:@"Building web page"];
        [[self window] displayIfNeeded];
        cmd=[NSString stringWithFormat:@"/Users/iain/bin/build-shoot-page %@",[project rootPath]];
        runCommand(cmd);
        
        //[self setExportButtonState:true];
        [self markProjectAtIndexPath:indexPath withState:clean andExportDate:[project lastExportDate]];
        [self setStatusMessage:@"Export complete"];
        [[self window] displayIfNeeded];
      }else{
        NSLog(@"Masters are not online");
        [self setStatusMessage:[NSString stringWithFormat:@"Masters for %@ are not online", [project name]]];
        [[self window] displayIfNeeded];
      }
      [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
    }else{
      NSLog(@"No pictures to export");
      [self setStatusMessage:[NSString stringWithFormat:@"No pictures to export in %@", [project name]]];
      [[self window] displayIfNeeded];
    }
  }
}


- (IBAction)export:(id)sender {
  [self setExportButtonState:false];
  [self doExport:true];
  [self setExportButtonState:true];
}


- (IBAction)exportModified:(id)sender {
  [self setExportButtonState:false];
  [self doExport:false];
  [self setExportButtonState:true];
}

@end
