/*
     File: FileSystemItem.m
 Abstract:  The data source backend for displaying the file system.
 This object can be improved a great deal; it never frees nodes that are expanded; it also is not too lazy when it comes to computing the children (when the number of children at a level are asked for, it computes the children array).
  Version: 1.2
*/


#import "ApertureItem.h"
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


@implementation ApertureItem

static ApertureItem *rootItem = nil;

#define IsALeafNode ((id)-1)

//- (id)initWithPath:(NSString *)path parent:(ApertureItem *)obj {
//    if (self = [super init]) {
//        relativePath = [[path lastPathComponent] copy];
//        parent = obj;
//    }
//    return self;
//}

- (id)initWithID:(NSString *)aID parent:(ApertureItem *)obj {
  if (self = [super init]) {
    //relativePath = [[path lastPathComponent] copy];
    apertureID = aID;
    parent = obj;
  }
  return self;
}

+ (ApertureItem *)rootItem {
   if (rootItem == nil) rootItem = [[ApertureItem alloc] initWithID:@"root" parent:nil];
   return rootItem;       
}


// Creates and returns the array of children
// Loads children incrementally
//
- (NSArray *)children {
  
  if (children == NULL) {
    NSLog(@"starting ApertureItem children with apertureID %@",[self apertureID]);
    Aperture *aperture = [[NSClassFromString(@"Aperture") alloc] init];
    NSArray *array;
    if ([[self apertureID]  isEqual: @"root"]) {
      array = [aperture topLevelFolders];
    }else{
      array = [aperture getChildren:[self apertureID]];
    }
    NSInteger cnt, numChildren = [array count];
    children = [[NSMutableArray alloc] initWithCapacity:numChildren];
    for (cnt = 0; cnt < numChildren; cnt++) {
      ApertureItem *item = [[ApertureItem alloc] initWithID:[array objectAtIndex:cnt] parent:self];
      [children addObject:item];
    }
    

//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *fullPath = [self fullPath];
//    BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
//    if (valid && isDir) {
//      NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
//      if (!array) {   // This is unexpected
//        children = [[NSMutableArray alloc] init];
//      } else {
//        NSInteger cnt, numChildren = [array count];
//        children = [[NSMutableArray alloc] initWithCapacity:numChildren];
//        for (cnt = 0; cnt < numChildren; cnt++) {
//          ApertureItem *item = [[ApertureItem alloc] initWithPath:[array objectAtIndex:cnt] parent:self];
//          [children addObject:item];
//        }
//      }
//    } else {
//      children = NULL;
//    }
  }
  return children;
}

//- (NSString *)relativePath {
//    return relativePath;
//}
//
//- (NSString *)fullPath {
//    return parent ? [[parent fullPath] stringByAppendingPathComponent:relativePath] : relativePath;
//}

- (NSString *)apertureID {
  return apertureID;
}

- (ApertureItem *)childAtIndex:(NSInteger)n {
    return [[self children] objectAtIndex:n];
}

- (NSInteger)numberOfChildren {
    id tmp = [self children];
    return (tmp == NULL) ? (-1) : [tmp count];
}


@end


