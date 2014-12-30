//
//  Project.h
//  Exporter
//
//  Created by Iain Wood on 23/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject{
  //NSString *path;
}
//@property NSString *path;
@property NSString *year;
@property NSString *month;
@property NSString *name;
+ (Project  *)projectWithName:(NSString *)prName month:(NSString *)month year:(NSString *)year;
- (BOOL      )exported;
- (NSDate   *)firstExportDate;
- (NSDate   *)lastExportDate;
- (NSString *)path;
- (NSString *)fullPath;
- (NSString *)monthNumber;
@end
