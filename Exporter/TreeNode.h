//
//  TreeNode.h
//  Suneth
//
//  Created by Iain Wood on 21/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"
#import "IntegerToColourTransformer.h"

@import AppKit;

@interface TreeNode : NSObject{
  NSString *entityName;
  BOOL      exported;
  modifiedState modified;
  NSDate   *firstExport;
  NSDate   *lastExport;
  NSNumber *count;
  //Project *project;
}

@property NSString * entityName;
@property BOOL exported;
@property modifiedState modified;
@property NSDate *firstExport;
@property NSDate *lastExport;
@property NSNumber *count;

+ (NSTreeNode *) makeNode:(NSString *)nodeName;
+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported;
+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported firstExport:(NSDate*)firstExport lastExport:(NSDate*)lastExport;

@end
