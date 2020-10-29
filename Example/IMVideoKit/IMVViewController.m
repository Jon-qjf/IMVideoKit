//
//  IMVViewController.m
//  IMVideoKit
//
//  Created by qjf on 10/28/2020.
//  Copyright (c) 2020 qjf. All rights reserved.
//

#import "IMVViewController.h"
#import <ChatViewController.h>
#import <IMManager.h>
@interface IMVViewController ()

@end

@implementation IMVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[IMManager shareManager]loginIMWithAppId:@"1400354488" UserId:@"6474bb78f0994c96801145596bf45b4c" userSig:@"eJw1Tt0KgjAYfZfdGrbNb39CF0FRkl2UYtRdczNWWGKiRfTuidW5O7*cF0rjxLePytUWhZQpigeMBr21NQoR9TH68ru5HKvKGRQSwDhgAFJ*HWfstXGFGwocBGgtZIGVglxxiQkBxhTXBTAN*X-NnfpwC4t5tozx*Tn1WCBuK36oPLPZ0y6K8nRLx7N1InK2y8pu8is2ruzPEo6DgAki5PsDJK02mA__" deviceToken:nil success:^{
        NSLog(@"success");
    } fail:^(NSInteger code, NSString * _Nonnull msg) {
        NSLog(@"%ld,%@",(long)code,msg);
    }];

    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ChatViewController *chatVC = [[ChatViewController alloc]initWithConsultationID:@"TRIAGE_6474bb78f0994c96801145596bf45b4c"];
    chatVC.modalPresentationStyle = 0;
    [self presentViewController:chatVC animated:YES completion:nil];



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
