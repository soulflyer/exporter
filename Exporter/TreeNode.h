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
  BOOL exported;
  Project *project;
}
@property NSString * entityName;
@property BOOL exported;
@property Project* project;
+ (NSTreeNode *) makeNode:(NSString *)nodeName;
+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported;

@end
