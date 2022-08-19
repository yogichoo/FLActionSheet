//
//  ViewController.m
//  FLActionSheet
//
//  Created by sashy on 2022/8/19.
//

#import "ViewController.h"
#import "FLActionSheet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)actionSheetClick:(id)sender {
    [FLActionSheet initItems:@[@"点击1", @"点击2", @"点击3"] title:@"不带标题传nil" cancel:YES action:^(NSString * _Nonnull item, NSInteger index) {
        NSLog(@"==================%zd  ====%@", index, item);
    }];
}


@end
