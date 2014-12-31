//
//  Project.m
//  Exporter
//
//  Created by Iain Wood on 23/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "Project.h"

@implementation Project
+ (Project *)projectWithName:(NSString *)prName month:(NSString *)month year:(NSString *)year {
  Project *pr = [[Project alloc] init];
  //[pr setPath:[NSString stringWithFormat:@"/%@/%@/%@",year,month,prName]];
  [pr setName:prName];
  [pr setMonth:month];
  [pr setYear:year];
  return pr;
}

- (NSString *)monthNumber{
  NSString *lowerMonth = [[[self month] lowercaseString] substringToIndex:3];
  if ([lowerMonth isEqual:@"jan"]) {
    return @"01";
  } else if ([lowerMonth isEqual:@"feb"]) {
    return @"02";
  }else if ([lowerMonth isEqual:@"mar"]) {
    return @"03";
  }else if ([lowerMonth isEqual:@"apr"]) {
    return @"04";
  }else if ([lowerMonth isEqual:@"may"]) {
    return @"05";
  }else if ([lowerMonth isEqual:@"jun"]) {
    return @"06";
  }else if ([lowerMonth isEqual:@"jul"]) {
    return @"07";
  }else if ([lowerMonth isEqual:@"aug"]) {
    return @"08";
  }else if ([lowerMonth isEqual:@"sep"]) {
    return @"09";
  }else if ([lowerMonth isEqual:@"oct"]) {
    return @"10";
  }else if ([lowerMonth isEqual:@"nov"]) {
    return @"11";
  }
  return @"12";
}

- (BOOL)exported{
  //check if notes.txt exists for the project
  NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
  NSString *filePath = [[NSString stringWithFormat:@"%@%@/notes.txt",[defaults objectForKey:@"photosPath"],[self path]] stringByStandardizingPath];
  //NSLog(@"Checking for %@",filePath);
  BOOL exists=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
  return exists;
}

- (NSDate *)firstExportDate{
  if ([self exported]) {
    // return the file creation date of notes.txt
    NSLog(@"Find creation date of %@",[self fullPath]);
    NSDate *creationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fullPath] stringByStandardizingPath] error:nil] fileCreationDate];
    NSLog(@"Creation date is: %@",creationDate);
    return creationDate;
  }
  return [NSDate date];
}

- (NSDate *)lastExportDate{
  if ([self exported]) {
    // return modification date of notes.txt
    NSLog(@"Find modification date of %@",[self path]);
    NSDate *modificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fullPath] stringByStandardizingPath] error:nil] fileModificationDate];
    NSLog(@"Modification date is: %@",modificationDate);
    return modificationDate;
  }
  return [NSDate date];
}

- (NSString *)path{
  return [NSString stringWithFormat:@"/%@/%@/%@",[self year],[self monthNumber],[self name]];
}

- (NSString *)fullPath{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSLog(@"%@",[NSString stringWithFormat:@"default path %@",[def stringForKey:@"photosPath"]]);
  return [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"photosPath"],[self path]];
}


@end
