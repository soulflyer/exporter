//
//  IntegerToColourTransformer.m
//  Exporter
//
//  Created by Iain Wood on 31/03/2015.
//  Copyright (c) 2015 soulflyer. All rights reserved.
//

#import "IntegerToColourTransformer.h"

@implementation IntegerToColourTransformer

+(Class)transformedValueClass {
  return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
  return NO;
}

- (id)transformedValue:(id)value
{
  NSColor *cleanColour   = [NSColor colorWithRed:0 green:0.5 blue:0 alpha:1];
  NSColor *dirtyColour   = [NSColor colorWithRed:0.7 green:0 blue:0 alpha:1];
  NSColor *unknownColour = [NSColor blackColor];
  if ([value respondsToSelector:@selector(intValue)]) {
    modifiedState  inputValue = (modifiedState)[value integerValue];
    if (inputValue == dirty) {
      return dirtyColour;
    }else if (inputValue == clean){
      return cleanColour;
    }
  }
  return unknownColour;
}

@end
