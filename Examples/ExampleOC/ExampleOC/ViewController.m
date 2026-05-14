//
//  ViewController.m
//  ExampleOC
//
//  Created by CoderChan on 10/31/25.
//

#import "ViewController.h"
#import "MarsLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"viewDidLoad"];
}


@end
