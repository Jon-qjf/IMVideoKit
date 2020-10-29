//
//  UIButton+SystemStyle.h
//  TUIkitModule
//
//  Created by kerwin Zhang on 2020/10/22.
//

#import <UIKit/UIKit.h>
#import "UIImage+Gradient.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SystemStyle)
-(void)setMasterStyleWithTitle:(NSString *)title;
/**
 *  根据给定的颜色，设置按钮的颜色
 *  @param btnSize  这里要求手动设置下生成图片的大小，防止coder使用第三方layout,没有设置大小
 *  @param clrs     渐变颜色的数组
 *  @param percent  渐变颜色的占比数组
 *  @param type     渐变色的类型
 *  @param state    button state

 */
- (UIButton *)gradientButtonWithSize:(CGSize)btnSize colorArray:(NSArray *)clrs percentageArray:(NSArray *)percent gradientType:(GradientType)type forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END