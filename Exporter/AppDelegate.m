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

#define defaultPhotosPath @"~/Pictures/Published"
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
//  NSLog(@"---------------------Log message from main thread.-----------------------");
  backgroundQueue = [[NSOperationQueue alloc] init];
  mainQueue = [NSOperationQueue mainQueue];
//  [backgroundQueue addOperationWithBlock:^{
//    sleep(4);
//    NSLog(@"********************Log message from background task.********************");
//    sleep(4);
//    [mainQueue addOperationWithBlock:^{
//      NSLog(@"+++++++++Log message sent from background task to main queue+++++++++++++");
//    }];
//  }];
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

-(void)markProjectAtIndexPath:(NSIndexPath *)indexPath withState:(enum modifiedState)state andCount:(NSNumber*) count{
  NSUInteger indexes[3];
  [indexPath getIndexes:indexes];
  NSUInteger year    = indexes[0];
  NSUInteger month   = indexes[1];
  NSUInteger project = indexes[2];
  NSTreeNode *nd = [[[[treeController content][year] childNodes][month] childNodes][project] representedObject];
  [nd setValue:[NSString stringWithFormat:@"%d",state]  forKey:@"modified"];
  [nd setValue:count forKey:@"count"];
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
    [self setStatusMessage:[NSString stringWithFormat:@"Checking: %@",[project name]]];
    [[self window] displayIfNeeded];
    NSArray *modifiedPics = [aperture modifiedPics:[project name] ofMonth:[project month] ofYear:[project year]];
    [self setStatusMessage:[NSString stringWithFormat:@"Check complete, found %lu pics", (unsigned long)[modifiedPics count]]];
    NSString *message;
    if ([modifiedPics count] > 0) {
      // NSLog(@"Modified %@",modifiedPics);
      [[self consoleWindow] insertText:[NSString stringWithFormat:@"%@ ",[project name]]];
      [[self consoleWindow] insertText:[NSString stringWithFormat:@"%@\n",modifiedPics]];
      [[self window] displayIfNeeded];
      [self markProjectAtIndexPath:indexPath withState:dirty andCount:[NSNumber numberWithUnsignedLong:[modifiedPics count]]];
      message = [NSString stringWithFormat:@"%@:\t found %lu modified pictures.", [project name], [modifiedPics count]];
    }else{
      NSArray *exportedPics = [aperture exportedPics:[project name] ofMonth:[project month] ofYear:[project year]];
      if ([exportedPics count] > 0){
        if ([project exported]) {
          [self markProjectAtIndexPath:indexPath withState:clean];
          message = [NSString stringWithFormat:@"%@:\t already pictures exported.", [project name]];
        }else{
          [self markProjectAtIndexPath:indexPath withState:dirty];
          message = [NSString stringWithFormat:@"%@:\t has pictures to export.", [project name]];
        }
      }else{
        [self markProjectAtIndexPath:indexPath withState:unknown];
        message = [NSString stringWithFormat:@"%@:\t has no pictures to export.", [project name]];
      }
    }
    NSLog(@"%@",message);
    [self setStatusMessage:message];
    [[self window] displayIfNeeded];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
  }
}

- (void)doBackgroundExport:(BOOL)full{
  NSString *fullString = @"false";
  if (full) {
    fullString = @"true";
  }else{
    fullString = @"false";
  }
  for (NSIndexPath *indexPath in [self selectedProjectIndexes]){
    Project *project = [self projectFromIndexPath:indexPath];
    NSArray *exportedPics = [aperture exportedPics:[project name] ofMonth:[project month] ofYear:[project year]];
    //NSLog(@"Piclist %@", exportedPics);
    //NSLog(@"Piclist count %lu", (unsigned long)[exportedPics count]);
    NSLog(@"Exporting %@ , %lu pictures",[project name], (unsigned long)[exportedPics count]);
    
    //Check if there are any exporteable pictures
    if ([exportedPics count] > 0) {
      NSLog(@"project path %@", [project mastersPath] );
      //Check if the photos are online
      if ([[NSFileManager defaultManager] fileExistsAtPath:[[project mastersPath]stringByExpandingTildeInPath]]) {
        
        //Check if project has never been exported
        if (![project exported]) {
          NSLog(@"project not yet exported, doing full export");
          fullString = @"true";
        }
        [self setStatusMessage:[NSString stringWithFormat:@"%@ - exporting thumbs.", [project name]]];
        [[self window] displayIfNeeded];
        [backgroundQueue addOperationWithBlock:^{
          NSLog(@"Exporting thumbnails");
          [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[[project thumbPath]stringByExpandingTildeInPath] atSize:@"JPEG - Thumbnail" withWatermark:@"false" exportEverything:fullString];
          [mainQueue addOperationWithBlock:^{
            [self setStatusMessage:[NSString stringWithFormat:@"%@ - exporting medium pics.", [project name]]];
            [[self window] displayIfNeeded];
          }];
          NSLog(@"Exporting mediums");
          [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[[project mediumPath]stringByExpandingTildeInPath] atSize:@"JPEG - Fit within 1024 x 1024" withWatermark:@"true" exportEverything:fullString];
          NSLog(@"Exporting larges");
          [mainQueue addOperationWithBlock:^{
            [self setStatusMessage:[NSString stringWithFormat:@"%@ - exporting large pics.", [project name]]];
            [[self window] displayIfNeeded];
          }];
          [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[[project largePath]stringByExpandingTildeInPath] atSize:@"JPEG - Fit within 2048 x 2048" withWatermark:@"true" exportEverything:fullString];
          NSLog(@"Exporting fullsize");
          [mainQueue addOperationWithBlock:^{
            [self setStatusMessage:[NSString stringWithFormat:@"%@ - exporting fullsize pics.", [project name]]];
            [[self window] displayIfNeeded];
          }];
          [aperture exportProject:[project name] ofMonth:[project month] ofYear: [project year] toDirectory:[[project fullsizePath]stringByExpandingTildeInPath] atSize:@"JPEG - Original Size" withWatermark:@"false" exportEverything:fullString];
          NSLog(@"Setting export date");
          [aperture setExportDateOf:[project name] ofMonth:[project month] ofYear:[project year]];
          //NSLog(@"Geting notes");
          NSString *notes=[aperture getNotes:[project name] ofMonth:[project month] ofYear:[project year]];
          if (!notes) {
            notes=(@"");
          }
          NSLog(@"Notes: %@",notes);
          NSString *cmd = [NSString stringWithFormat:@"mkdir -p %@; echo \"%@\" > %@/notes.txt", [project rootPath], notes, [project rootPath]];
          //NSLog(@"%@",cmd);
          runCommand(cmd);
          
          cmd=[NSString stringWithFormat:@"/Users/iain/bin/build-shoot-page %@",[project rootPath]];
          runCommand(cmd);
          
          cmd=[NSString stringWithFormat:@"/Users/iain/bin/save-meta %@",[project fullsizePath]];
          NSLog(@"Adding pics to database");
          runCommand(cmd);
          
          [mainQueue addOperationWithBlock:^{
            NSLog(@"Export of %@ complete.", [project name]);
            [self markProjectAtIndexPath:indexPath withState:clean andExportDate:[project lastExportDate]];
            [self setStatusMessage:[NSString stringWithFormat:@"%@ - export complete.", [project name]]];
            [[self window] displayIfNeeded];
          }];
        }];
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
  [self doBackgroundExport:true];
  [self setExportButtonState:true];
}


- (IBAction)exportModified:(id)sender {
  [self setExportButtonState:false];
  [self doBackgroundExport:false];
  [self setExportButtonState:true];
}

@end
