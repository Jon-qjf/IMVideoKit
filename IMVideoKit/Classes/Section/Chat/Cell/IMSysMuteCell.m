//
//  IMSysMuteCell.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMSysMuteCell.h"
#import "IMSysMuteCellData.h"
#import "THeader.h"
#import <MMLayout/UIView+MMLayout.h>
@interface IMSysMuteCell ()<UITextViewDelegate>
@property IMSysMuteCellData *systemData;
@property UIView *lineV;
@end
@implementation IMSysMuteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UIView alloc] init];
        _content.backgroundColor = [UIColor clearColor];
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        
        _titleLab.textColor = [UIColor grayColor];
        _titleLab.backgroundColor = TMessageController_Background_Color;
        
        
        _lineV = [[UIView alloc]init];
        _lineV.backgroundColor = RGB(216, 216, 216);
        _lineV.frame = CGRectMake(0, 0, Screen_Width - TMessageCell_Head_Width * 2, 1);
        [_content addSubview:_lineV];
        [_content addSubview:_titleLab];
        [self.container addSubview:_content];
    }
    return self;
}
- (void)fillWithData:(IMSysMuteCellData *)data;
{
   [super fillWithData:data];
    self.systemData = data;
    //set data
    self.titleLab.text = data.content;
    [self.titleLab sizeToFit];
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];
    [self setNeedsLayout];
  
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.mm_center();
    self.content.mm_fill();
    self.lineV.mm_center();
    self.titleLab.mm_center();
}
@end
