//
//  IMTextView.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/29.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMTextView.h"

@implementation IMTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    UIMenuController *menu = sender;
    [self resignFirstResponder];
    return NO;
}
@end
