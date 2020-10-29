//
//  UIImage+Gradient.h
//  testLayer
//
//  Created by tb on 17/3/17.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GradientType) {
    GradientFromTopToBottom = 1,            //从上到下
    GradientFromLeftToRight,                //从左到右
    GradientFromLeftTopToRightBottom,       //从上到下
    GradientFromLeftBottomToRightTop        //从上到下
};

@interface UIImage (Gradient)

/**
 *  根据给定的颜色，生成渐变色的图片
 *  @param imageSize        要生成的图片的大小
 *  @param colorArr         渐变颜色的数组
 *  @param percents          渐变颜色的占比数组
 *  @param gradientType     渐变色的类型
 */
- (UIImage *)createImageWithSize:(CGSize)imageSize gradientColors:(NSArray *)colorArr percentage:(NSArray *)percents gradientType:(GradientType)gradientType;
- (UIImage *)createImageWithColor: (UIColor*) color;

+(UIImage *)initWithBackGroundGradientImageWithSize:(CGSize)size;

/*
*  @return 裁切后的图片
*/
+ (UIImage *)getImageViewWithView:(UIView *)view;

/// 加载bundle中图片资源
/// @param imageName 图片名字
/// @param bundle 需要加载图片所在的bundle文件名称
/// @param targetClass 加载的class
+ (UIImage *)FLImagePathWithName:(NSString *)imageName bundle:(NSString *)bundle targetClass:(Class)targetClass;


@end
