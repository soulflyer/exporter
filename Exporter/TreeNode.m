//
//  TreeNode.m
//  Suneth
//
//  Created by Iain Wood on 21/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "TreeNode.h"
@import AppKit;


@implementation TreeNode
@synthesize entityName;
+ (NSTreeNode *) makeNode:(NSString *)nodeName {
  TreeNode *treeNode = [[TreeNode alloc]init];
  treeNode.entityName = nodeName;
  return [NSTreeNode treeNodeWithRepresentedObject:treeNode];
}

@end

