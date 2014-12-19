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
//-(NSArray  *)topLevelFolders;
-(NSArray  *)topLevelFolders;
-(NSString *)getFolderID;
-(NSString *)getFolderName:(NSString*)folderID;
//-(NSArray  *)getChildren:(NSString*)folderID;
-(NSArray  *)getChildren:(NSString*)folderID;
@end


@implementation ApertureItem

static ApertureItem *rootItem = nil;

#define IsALeafNode ((id)-1)

- (id)initWithID:(NSString *)apID parent:(ApertureItem *)obj {
  if (self = [super init]) {
    apertureID = apID;
    parent = obj;
  }
  return self;
}

- (id)initWithID:(NSString *)apID name:(NSString*)apName parent:(ApertureItem *)obj {
  if (self = [super init]) {
    apertureID = apID;
    parent = obj;
    apertureName = apName;
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
      NSString *an = [[array objectAtIndex:cnt] valueForKey:@"apertureName"];
      NSString *apid = [[array objectAtIndex:cnt] valueForKey:@"apertureID"];
      //NSLog(@"an %@",an);
      ApertureItem *item = [[ApertureItem alloc] initWithID:apid name:an  parent:self];
      [children addObject:item];
    }
  }
  return children;
}

- (NSString *)apertureID {
  return apertureID;
}

- (NSString *)apertureName {
  return apertureName;
}

- (ApertureItem *)childAtIndex:(NSInteger)n {
    return [[self children] objectAtIndex:n];
}

- (NSInteger)numberOfChildren {
    id tmp = [self children];
    return (tmp == NULL) ? (-1) : [tmp count];
}


@end


