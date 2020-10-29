//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"
#import "Toast.h"
@implementation TUITextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UITextView alloc] init];
        _content.delegate = self;
        _content.dataDetectorTypes = UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink;
        _content.editable = NO;
        _content.backgroundColor = [UIColor clearColor];
        _content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: RGB(255, 204, 131),
                                         NSUnderlineColorAttributeName: RGB(255, 204, 131),
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:1]};
        _content.linkTextAttributes = linkAttributes;
        [self.bubbleView addSubview:_content];
        
    }
    return self;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"url=%@",URL);
    if ([URL.absoluteString hasPrefix:@"tel"]) {
        NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",URL.resourceSpecifier];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]){
            //调用系统拨号方法
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }else{//格式不正确时 toast提示
            [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@"%@ invalid format",phoneNumber]];
        }
        return NO;
    }
    return YES;
}
- (void)fillWithData:(TUITextMessageCellData *)data;
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

@end
