//
//  main.m
//  Exporter
//
//  Created by Iain Wood on 12/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>


int main(int argc, const char * argv[]) {
  [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
  return NSApplicationMain(argc, argv);
}
