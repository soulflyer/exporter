//
//  TreeNode.m
//
//  Created by Iain Wood on 21/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "TreeNode.h"
#import "Project.h"
@import AppKit;


@implementation TreeNode
@synthesize entityName,exported,firstExport,lastExport;
+ (NSTreeNode *) makeNode:(NSString *)nodeName {
  TreeNode *treeNode = [[TreeNode alloc]init];
  treeNode.entityName = nodeName;
  treeNode.exported = NO;
  //treeNode.project = nil;
  return [NSTreeNode treeNodeWithRepresentedObject:treeNode];
}

+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported {
  TreeNode *treeNode = [[TreeNode alloc]init];
  treeNode.entityName = nodeName;
  treeNode.exported = exported;
  //treeNode.project = nil;
  return [NSTreeNode treeNodeWithRepresentedObject:treeNode];
}

+ (NSTreeNode *) makeNode:(NSString *)nodeName exported:(BOOL)exported firstExport:(NSDate*)firstExport lastExport:(NSDate*)lastExport{
  TreeNode *treeNode = [[TreeNode alloc]init];
  treeNode.entityName  = nodeName;
  treeNode.exported    = exported;
  treeNode.firstExport = firstExport;
  treeNode.lastExport  = lastExport;
  return [NSTreeNode treeNodeWithRepresentedObject:treeNode];
}

@end

