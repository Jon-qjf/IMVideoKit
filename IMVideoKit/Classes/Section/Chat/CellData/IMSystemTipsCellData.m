//
//  IMSystemTipsCellData.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMSystemTipsCellData.h"
#import "NSString+TUICommon.h"
@implementation IMSystemTipsCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        _contentFont = [UIFont systemFontOfSize:14];
        _contentColor = [UIColor colorWithRed:148.0 / 255.0
                                        green:149.0 / 255.0
                                         blue:149.0 / 255.0 alpha:1.0];
        self.cellLayout =  [TUIMessageCellLayout systemMessageLayout];
    }
    return self;
}

//- (CGSize)contentSize
//{
//    CGSize size = [self.content textSizeIn:CGSizeMake(Screen_Width - TMessageCell_Head_Width * 2, MAXFLOAT) font:self.contentFont breakMode:NSLineBreakByWordWrapping align:(NSTextAlignmentCenter)];
//    size.height += 10;
//    return size;
//}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return [self contentSize].height + 16;
}
@end
