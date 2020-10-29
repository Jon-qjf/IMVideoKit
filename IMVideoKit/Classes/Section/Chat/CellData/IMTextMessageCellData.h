//
//  IMTextMessageCellData.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "TUITextMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMTextMessageCellData : TUIBubbleMessageCellData

/**
 *  消息的文本内容
 */
@property (nonatomic, strong) NSString *content;

/**
 *  文本字体
 *  文本消息显示时的 UI 字体。
 */
@property (nonatomic, strong) UIFont *textFont;

/**
 *  文本颜色
 *  文本消息显示时的 UI 颜色。
 */
@property (nonatomic) UIColor *textColor;

/**
 *  可变字符串
 *  文本消息接收到 content 字符串后，需要将字符串中可能存在的字符串表情（比如[微笑]），转为图片表情。
 *  本字符串则负责存储上述过程转换后的结果。
 */
@property (nonatomic, strong) NSAttributedString *attributedString;

/**
 *  文本内容尺寸。
 *  配合原点定位文本消息。
 */
@property (readonly) CGSize textSize;

/**
 *  文本内容原点。
 *  配合尺寸定位文本消息。
 */
@property (readonly) CGPoint textOrigin;



@end

NS_ASSUME_NONNULL_END
