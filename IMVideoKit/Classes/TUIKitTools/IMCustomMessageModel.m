//
//  IMCustomMessageModel.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/25.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMCustomMessageModel.h"

@implementation IMCustomMessageModel
- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.MsgType = dic[@"MsgType"];
        self.MsgContent = dic[@"MsgContent"];
        self.ToMembers_Account = dic[@"ToMembers_Account"];
    }
    return self;
}
+(instancetype)initWithDictionary:(NSDictionary *)dic
{
    
    return [[IMCustomMessageModel alloc]initWithDictionary:dic];
    
}
@end

@implementation IMMsgContentModel

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.Text = dic[@"Text"];
    }
    return self;
}
+(instancetype)initWithDictionary:(NSDictionary *)dic
{
    
    return [[IMMsgContentModel alloc]initWithDictionary:dic];
    
}

@end
