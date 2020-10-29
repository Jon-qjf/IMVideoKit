//
//  IMTextMessageCell.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/24.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "TUIBubbleMessageCell.h"
#import "TUITextMessageCellData.h"
#import "IMTextMessageCellData.h"
#import "IMTextView.h"
NS_ASSUME_NONNULL_BEGIN
@class IMTextMessageCell;
@protocol IMTextMessageCellDelegate <NSObject>

-(void)onLongPress:(IMTextMessageCell *)cell;

@end
@interface IMTextMessageCell : TUIBubbleMessageCell<UITextViewDelegate>

/**
 *  内容标签
 *  用于展示文本消息的内容。
 */
@property (nonatomic, strong) IMTextView *content;

/**
 *  文本消息单元数据源
 *  数据源内存放了文本消息的内容信息、消息字体、消息颜色、并存放了发送、接收两种状态下的不同字体颜色。
 */
@property IMTextMessageCellData *textData;

/**
 *  填充数据
 *  根据 data 设置文本消息的数据。
 *
 *  @param  data    填充数据需要的数据源
 */
- (void)fillWithData:(IMTextMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
