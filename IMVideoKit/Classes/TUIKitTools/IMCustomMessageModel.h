//
//  IMCustomMessageModel.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMMsgContentModel;
NS_ASSUME_NONNULL_BEGIN

@interface IMCustomMessageModel : NSObject

@property(nonatomic,strong)IMMsgContentModel *MsgContent;
@property(nonatomic,copy)NSString *MsgType;
@property(nonatomic,copy)NSString *ToMembers_Account;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
+ (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

@interface IMMsgContentModel : NSObject
@property(nonatomic,copy)NSString *Text;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
+ (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
NS_ASSUME_NONNULL_END
