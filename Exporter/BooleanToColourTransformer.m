//
//  BooleanToColourTransformer.m
//  Exporter
//
//  Created by Iain Wood on 31/03/2015.
//  Copyright (c) 2015 soulflyer. All rights reserved.
//

#import "BooleanToColourTransformer.h"

@implementation BooleanToColourTransformer

+(Class)transformedValueClass {
  return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
  return NO;
}

- (id)transformedValue:(id)value
{
  if ([value respondsToSelector:@selector(boolValue)]) {
    bool inputValue = [value boolValue];
    if (inputValue) {
      return [NSColor redColor];
    }else{
      return [NSColor greenColor];
    }
  }
  return [NSColor blackColor];
}
@end
