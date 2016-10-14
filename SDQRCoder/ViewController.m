//
//  ViewController.m
//  SDQRCoder
//
//  Created by 宋东昊 on 16/10/14.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "ViewController.h"
#import "SDScanQRViewController.h"
#import "SDMyQRCodeViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTitle:@"扫描" forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(onScanClick:) forControlEvents:UIControlEventTouchUpInside];
    scanButton.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:scanButton];
    
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(100);
        make.right.equalTo(-100);
        make.top.equalTo(200);
        make.height.equalTo(50);
    }];
    
    
    UIButton *codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [codeButton setTitle:@"我的二维码" forState:UIControlStateNormal];
    [codeButton addTarget:self action:@selector(onMyCodeViewShow:) forControlEvents:UIControlEventTouchUpInside];
    codeButton.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:codeButton];
    
    [codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scanButton);
        make.right.equalTo(scanButton);
        make.height.equalTo(scanButton);
        make.top.equalTo(scanButton.mas_bottom).offset(50);
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onScanClick:(id)sender
{
    SDScanQRViewController *controller = [[SDScanQRViewController alloc]init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)onMyCodeViewShow:(id)sender
{
    SDMyQRCodeViewController *controller = [[SDMyQRCodeViewController alloc]init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}






@end
