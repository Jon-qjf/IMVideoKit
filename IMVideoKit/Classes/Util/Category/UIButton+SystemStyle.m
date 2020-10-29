//
//  UIButton+SystemStyle.m
//  TUIkitModule
//
//  Created by kerwin Zhang on 2020/10/22.
//

#import "UIButton+SystemStyle.h"
#import "THeader.h"


@implementation UIButton (SystemStyle)

-(void)setMasterStyleWithTitle:(NSString *)title
{
    [self setTitle:title forState:(UIControlStateNormal)];
    [self setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:(UIControlStateDisabled)];
    [self.titleLabel setFont:BOLDSYSTEMFONT(14)];
    self.layer.shadowColor = SYSTEM_BLUE.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 7);
    self.layer.shadowRadius = 5 ;
    self.layer.shadowOpacity = 0.3;
    [self gradientButtonWithSize:CGSizeMake(Main_Screen_Width-60,50) colorArray:@[(id)RGB(115, 175, 255),(id)RGB(86, 149, 255)] percentageArray:@[@(0.5),@(1)] gradientType:(GradientFromLeftToRight) forState:UIControlStateNormal];
    [self gradientButtonWithSize:CGSizeMake(Main_Screen_Width-60,50) colorArray:@[(id)RGB(171, 202, 255),(id)RGB(185, 215, 255)] percentageArray:@[@(0.5),@(1)] gradientType:GradientFromLeftToRight forState:(UIControlStateDisabled)];
}

- (UIButton *)gradientButtonWithSize:(CGSize)btnSize colorArray:(NSArray *)clrs percentageArray:(NSArray *)percent gradientType:(GradientType)type forState:(UIControlState)state{
    
    UIImage *backImage = [[UIImage alloc]createImageWithSize:btnSize gradientColors:clrs percentage:percent gradientType:type];
//    [backImage roundedCornerImage:10 borderSize:0];
    backImage = [backImage sd_roundedCornerImageWithRadius:10 corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil];
    
    [self setBackgroundImage:backImage forState:state];
    
    return self;
}


@end
