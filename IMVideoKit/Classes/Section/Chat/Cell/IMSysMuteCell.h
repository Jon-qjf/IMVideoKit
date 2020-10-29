//
//  IMSysMuteCell.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "TUIMessageCell.h"
#import "IMSysMuteCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface IMSysMuteCell : TUIMessageCell

/**
 *  系统消息标签
 *  用于展示系统消息的内容。例如：“您撤回了一条消息”。
 */
@property (readonly) UIView *content;
@property (readonly) UILabel *titleLab;
/**
 *  系统消息单元数据源
 *  消息源中存放了系统消息的内容、消息字体以及消息颜色。
 *  详细信息请参考 Section\Chat\CellData\TUISystemMessageCellData.h
 */
@property (readonly) IMSysMuteCellData *systemData;

/**
 *  填充数据
 *  根据 data 设置系统消息的数据
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(IMSysMuteCellData *)data;

@end

NS_ASSUME_NONNULL_END
