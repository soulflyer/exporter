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

- (BOOL)exported{
  //check if notes.txt exists for the project
  return true;
}

- (NSDate *)firstExportDate{
  if ([self exported]) {
    // return the file creation date of notes.txt
    return [NSDate date];
  }
  return [NSDate date];
}

- (NSDate *)lastExportDate{
  if ([self exported]) {
    // return modification date of notes.txt
    return [NSDate date];
  }
  return [NSDate date];
}

- (NSString *)path{
  return [NSString stringWithFormat:@"/%@/%@/%@",[self year],[self month],[self name]];
}

- (NSURL *)fullPath{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSLog(@"%@",[NSString stringWithFormat:@"default path %@",[def stringForKey:@"photosPath"]]);
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"photosPath"],[self path]]];
}

@end
