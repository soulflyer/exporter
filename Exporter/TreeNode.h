//
//  TreeNode.h
//  Suneth
//
//  Created by Iain Wood on 21/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"
@import AppKit;

@interface TreeNode : NSObject{
  NSString *entityName;
  BOOL      exported;
  NSDate   *firstExport;
  NSDate   *lastExport;
  //Project *project;
}

@property NSString * entityName;
@property BOOL exported;
@property NSDate *firstExport;
@property NSDate *lastExport;

+ (NSTreeNode *) makeNode:(NSString *)nodeName;
+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported;
+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported firstExport:(NSDate*)firstExport lastExport:(NSDate*)lastExport;

@end
