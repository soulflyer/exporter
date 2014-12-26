//
//  TreeNode.h
//  Suneth
//
//  Created by Iain Wood on 21/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface TreeNode : NSObject{
  NSString *entityName;
}
@property NSString * entityName;
+ (NSTreeNode *) makeNode:(NSString *)nodeName;

@end
