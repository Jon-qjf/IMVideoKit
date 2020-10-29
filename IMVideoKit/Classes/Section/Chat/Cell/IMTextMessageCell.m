//
//  IMTextMessageCell.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/24.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMTextMessageCell.h"
@implementation IMTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _content = [[IMTextView alloc] init];
        _content.delegate = self;
        _content.dataDetectorTypes = UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink;
        _content.editable = NO;
        
        _content.backgroundColor = [UIColor clearColor];
        _content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                         NSUnderlineColorAttributeName: [UIColor blueColor],
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:1]};
        _content.linkTextAttributes = linkAttributes;
        [self.bubbleView addSubview:_content];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [_content addGestureRecognizer:longPress];
//        UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPress:)];
//        [_content addGestureRecognizer:tapPress];
    }
    return self;
}


- (void)onLongPress:(UIGestureRecognizer *)recognizer
{
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateBegan){
        TUIMessageCell * view = (TUIMessageCell *)self;
        if(view.delegate && [view.delegate respondsToSelector:@selector(onLongPressMessage:)]){
            [view.delegate onLongPressMessage:self];
        }
    }
}
//-(void)onTapPress:(UIGestureRecognizer *)recognizer{
//
//    if([recognizer isKindOfClass:[UITapGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateEnded){
//        TUIMessageCell * view = (TUIMessageCell *)self;
//        if(view.delegate && [view.delegate respondsToSelector:@selector(onSelectMessage:)]){
//            [view.delegate onSelectMessage:self];
//        }
//    }
//}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    TUIMessageCell * view = (TUIMessageCell *)self;
    if(view.delegate && [view.delegate respondsToSelector:@selector(onSelectMessage:)]){
        [view.delegate onSelectMessage:self];
    }
    NSLog(@"url=%@",URL);
    if ([URL.absoluteString hasPrefix:@"tel"]) {
        
        if ([[[URL.resourceSpecifier stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"+6562026868"]) {
            //点击电话号码
        }else{
            NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",URL.resourceSpecifier];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]){
                //调用系统拨号方法
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }else{//格式不正确时 toast提示
                
            }
        }
        return NO;
    }
    return YES;
}
- (void)fillWithData:(IMTextMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    
    self.textData = data;
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.superview.userInteractionEnabled = YES;
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    TUIMessageCell * view = (TUIMessageCell *)self;
//    if(view.delegate && [view.delegate respondsToSelector:@selector(onSelectMessage:)]){
//        [view.delegate onSelectMessage:self];
//    }
//    [self.content resignFirstResponder];
////    if (action == @selector(paste:))
//        return NO;
////    return [super canPerformAction:action withSender:sender];
//}
@end
