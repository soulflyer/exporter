/*
     File: FileSystemItem.h
 Abstract:  The data source backend for displaying the file system.
 This object can be improved a great deal; it never frees nodes that are expanded; it also is not too lazy when it comes to computing the children (when the number of children at a level are asked for, it computes the children array).
  Version: 1.2
 
 */


#import <Foundation/Foundation.h>

@interface ApertureItem : NSObject {
//  NSString *relativePath;
  ApertureItem *parent;
  NSMutableArray *children;
  NSString *itemType;
  NSString *apertureID;
  NSString *apertureName;
}

+ (ApertureItem *)rootItem;
- (NSInteger)numberOfChildren;			// Returns -1 for leaf nodes
- (ApertureItem *)childAtIndex:(NSInteger)n;	// Invalid to call on leaf nodes
- (NSString *)apertureID;
- (NSString *)apertureName;

@end
