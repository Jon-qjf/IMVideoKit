//
//  ChatViewController.h
//  TUIKitApp
//
//  Created by kerwin Zhang on 2020/4/15.
//  Copyright © 2020 kerwin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class TUIMessageCellData;
@interface ChatViewController : UIViewController
@property(nonatomic,copy)NSString *conversationId;
@property(nonatomic,assign)BOOL isGroup;
@property (nonatomic, strong)NSDictionary *params;


- (void)sendMessage:(TUIMessageCellData*)msg;

- (instancetype)initWithConsultationID:(NSString *)conversationID;
@end

NS_ASSUME_NONNULL_END
