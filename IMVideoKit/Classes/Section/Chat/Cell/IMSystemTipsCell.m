//
//  IMSystemTipsCell.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMSystemTipsCell.h"
#import "IMSystemTipsCellData.h"
#import <MMLayout/UIView+MMLayout.h>
@interface IMSystemTipsCell ()<UITextViewDelegate>
@property (nonatomic, strong) UILabel *messageLabel;
@property IMSystemTipsCellData *systemData;
@end

@implementation IMSystemTipsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UITextView alloc] init];
        _content.editable = NO;
        _content.scrollEnabled = NO;
        _content.delegate = self;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.textColor = [UIColor grayColor];
        _content.backgroundColor = [UIColor clearColor];
        _content.font = [UIFont systemFontOfSize:14];
        _content.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]}; // 修改可点击文字的颜色
        _content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        _content.dataDetectorTypes = UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink;
       
        [self.container addSubview:_content];
    }
    return self;
}
- (void)fillWithData:(IMSystemTipsCellData *)data;
{
   [super fillWithData:data];
    self.systemData = data;
    //set data
    self.content.text = data.content;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];
    [self setNeedsLayout];
  
}
// 其他方式修改
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
  
    return YES;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.mm_center();
    self.content.mm_fill();
}

@end
