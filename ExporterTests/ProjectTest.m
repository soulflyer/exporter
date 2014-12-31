//
//  ProjectTest.m
//  Exporter
//
//  Created by Iain Wood on 24/12/2014.
//  Copyright (c) 2014 soulflyer. All rights reserved.
//

#import "ProjectTest.h"
#import "Project.h"

@implementation ProjectTest

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testPath {
  // This is an example of a functional test case.
  Project *project = [Project projectWithName:@"testProjectName" month:@"october" year:@"testYear"];
  NSLog(@"Test path is: %@",[project path]);
  XCTAssertEqualObjects([project path], @"/testYear/10/testProjectName");
}

-(void)testFullPath {
  Project *project = [Project projectWithName:@"testProjectName" month:@"June" year:@"testYear"];
  NSString *projectFullPath= [[project fullPath] stringByStandardizingPath];
  NSLog(@"Test fullPathString is: %@",projectFullPath);
  XCTAssertEqualObjects(projectFullPath,  @"/Users/iain/Pictures/Published/testYear/06/testProjectName");
}

-(void)testExists {
  Project *project = [Project projectWithName:@"15-House" month:@"October" year:@"2014"];
  BOOL projectExists = [project exported];
  XCTAssertEqual(projectExists, TRUE);
  [project setMonth:@"November"];
  [project setName:@"27-Carry-300"];
  projectExists = [project exported];
  XCTAssertEqual(projectExists, TRUE);
  
}

-(void)testFirstExportDate {
  Project *project = [Project projectWithName:@"15-House" month:@"October" year:@"2014"];
  NSDate *firstExportDate = [project firstExportDate];
  NSDate *testDate = [NSDate dateWithString:@"2014-11-29 11:22:55 +0000"];
  NSLog(@"firstExport: %@ %@",firstExportDate,testDate );
  XCTAssertEqual(firstExportDate, testDate);
}

-(void)testLastExportDate {
  Project *project = [Project projectWithName:@"15-House" month:@"October" year:@"2014"];
  NSDate *lastExportDate = [project lastExportDate];
  NSDate *testDate = [NSDate dateWithString:@"2014-11-29 11:23:33 +0000"];
  NSLog(@"Last export: %@ %@",lastExportDate,testDate );
  XCTAssertEqual(lastExportDate, testDate);
}

@end
