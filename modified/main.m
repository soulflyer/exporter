//
//  main.m
//  modified
//
//  Created by Iain Wood on 13/04/2015.
//  Copyright (c) 2015 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
  [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
  @autoreleasepool {
      // insert code here...
      NSLog(@"Hello, World!");
  }
    return 0;
}
