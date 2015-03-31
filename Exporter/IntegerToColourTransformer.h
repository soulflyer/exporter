//
//  IntegerToColourTransformer.h
//  Exporter
//
//  Created by Iain Wood on 31/03/2015.
//  Copyright (c) 2015 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;


typedef NS_ENUM(int, modifiedState) {
  unknown,
  clean,
  dirty
};


@interface IntegerToColourTransformer : NSValueTransformer

@end
