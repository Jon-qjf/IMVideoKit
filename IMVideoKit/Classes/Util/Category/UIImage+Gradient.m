//
//  UIImage+Gradient.m
//  testLayer
//
//  Created by tb on 17/3/17.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import "UIImage+Gradient.h"
#import "THeader.h"

@implementation UIImage (Gradient)

- (UIImage *)createImageWithSize:(CGSize)imageSize gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(GradientType)gradientType {
    
    NSAssert(percents.count <= 5, @"输入颜色数量过多，如果需求数量过大，请修改locations[]数组的个数");
    
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    
//    NSUInteger capacity = percents.count;
//    CGFloat locations[capacity];
    CGFloat locations[5];
    for (int i = 0; i < percents.count; i++) {
        locations[i] = [percents[i] floatValue];
    }
    
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, locations);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientFromTopToBottom:
            start = CGPointMake(imageSize.width/2, 0.0);
            end = CGPointMake(imageSize.width/2, imageSize.height);
            break;
        case GradientFromLeftToRight:
            start = CGPointMake(0.0, imageSize.height/2);
            end = CGPointMake(imageSize.width, imageSize.height/2);
            break;
        case GradientFromLeftTopToRightBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, imageSize.height);
            break;
        case GradientFromLeftBottomToRightTop:
            start = CGPointMake(0.0, imageSize.height);
            end = CGPointMake(imageSize.width, 0.0);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage*)createImageWithColor: (UIColor*) color

{
    
    CGRect rect=CGRectMake(0.0f,0.0f,Main_Screen_Width,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context,rect);
    
    UIImage*theImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;

}

+(UIImage *)initWithBackGroundGradientImageWithSize:(CGSize)size{
    
    UIImage *image = [[UIImage alloc]createImageWithSize:size  gradientColors:@[(id)RGB(255,255,255),(id)RGB(224, 234, 243)] percentage:@[@(0),@(1)] gradientType:(GradientFromTopToBottom)];
    return image;
}


+ (UIImage *)getImageViewWithView:(UIView *)view{
    UIGraphicsBeginImageContext(view.frame.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

+ (UIImage *)FLImagePathWithName:(NSString *)imageName bundle:(NSString *)bundle targetClass:(Class)targetClass {
        /*
        NSInteger scale = [[UIScreen mainScreen] scale];
        NSURL *bundleURL = [[NSBundle mainBundle]  URLForResource:@"IMVideoKitImages" withExtension:@"bundle"];
        NSBundle *currentBundle = [NSBundle bundleWithURL:bundleURL];
//        NSBundle *currentBundle = [NSBundle bundleForClass:targetClass];
        NSString *name = [NSString stringWithFormat:@"%@@%zdx.png",imageName,(long)scale];
//        NSString *dir = [NSString stringWithFormat:@"%@.bundle",bundle];
//        NSString *path = [currentBundle pathForResource:name ofType:@"png" inDirectory:dir];
    
    //    return path ? [UIImage imageWithContentsOfFile:path] : nil;
    return [UIImage imageWithContentsOfFile:[currentBundle pathForResource:name ofType:nil]];
         */
    
    NSInteger scale = [[UIScreen mainScreen] scale];
      NSBundle *currentBundle = [NSBundle bundleForClass:targetClass];
      NSString *name = [NSString stringWithFormat:@"%@@%zdx",imageName,scale];
      NSString *dir = [NSString stringWithFormat:@"%@.bundle",bundle];
      NSString *path = [currentBundle pathForResource:name ofType:@"png" inDirectory:dir];
      return path ? [UIImage imageWithContentsOfFile:path] : nil;
}

@end
