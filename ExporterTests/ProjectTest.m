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
  Project *project = [Project projectWithName:@"testProjectName" month:@"testMonth" year:@"testYear"];
  NSLog(@"Test path is: %@",[project path]);
  XCTAssertEqualObjects([project path], @"/testYear/testMonth/testProjectName");
}

-(void)testFullPath {
  Project *project = [Project projectWithName:@"testProjectName" month:@"testMonth" year:@"testYear"];
  NSURL *projectFullPath= [project fullPath];
  NSString * fullPathString = [[projectFullPath relativeString] stringByStandardizingPath];
  NSLog(@"Test fullPathString is: %@",fullPathString);
  XCTAssertEqualObjects(fullPathString,  @"/Users/iain/Photos/testYear/testMonth/testProjectName");
}

@end
