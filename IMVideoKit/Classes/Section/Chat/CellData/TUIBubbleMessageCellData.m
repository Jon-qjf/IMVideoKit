//
//  TUIBubbleMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCellData.h"
#import "TUIKit.h"
#import "THeader.h"

@implementation TUIBubbleMessageCellData

- (id)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _bubble = [[self class] incommingBubble];
            _highlightedBubble = [[self class] incommingHighlightedBubble];
            _bubbleTop = [[self class] incommingBubbleTop];
        } else {
            _bubble = [[self class] outgoingBubble];
            _highlightedBubble = [[self class] outgoingHighlightedBubble];
            _bubbleTop = [[self class] outgoingBubbleTop];
        }
    }
    return self;
}


static UIImage *sOutgoingBubble;

+ (UIImage *)outgoingBubble
{
    if (!sOutgoingBubble) {
        sOutgoingBubble = [UIImage imageNamed:@"redchat"];
    }
    return sOutgoingBubble;
}

+ (void)setOutgoingBubble:(UIImage *)outgoingBubble
{
    sOutgoingBubble = outgoingBubble;
}

static UIImage *sOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble
{
    if (!sOutgoingHighlightedBubble) {
        sOutgoingHighlightedBubble = [UIImage imageNamed:@"select_redchat"];
    }
    return sOutgoingHighlightedBubble;
}

+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble
{
    sOutgoingHighlightedBubble = outgoingHighlightedBubble;
}

static UIImage *sIncommingBubble;
+ (UIImage *)incommingBubble
{
    if (!sIncommingBubble) {
        sIncommingBubble = [UIImage imageNamed:@"whitechat"];
    }
    return sIncommingBubble;
}

+ (void)setIncommingBubble:(UIImage *)incommingBubble
{
    sIncommingBubble = incommingBubble;
}

static UIImage *sIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble
{
    if (!sIncommingHighlightedBubble) {
        sIncommingHighlightedBubble =[UIImage imageNamed:@"select_whitechat"];
    }
    return sIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble
{
    sIncommingHighlightedBubble = incommingHighlightedBubble;
}


static CGFloat sOutgoingBubbleTop = -2;

+ (CGFloat)outgoingBubbleTop
{
    return sOutgoingBubbleTop;
}

+ (void)setOutgoingBubbleTop:(CGFloat)outgoingBubble
{
    sOutgoingBubbleTop = outgoingBubble;
}

static CGFloat sIncommingBubbleTop = -2;

+ (CGFloat)incommingBubbleTop
{
    return sIncommingBubbleTop;
}

+ (void)setIncommingBubbleTop:(CGFloat)incommingBubbleTop
{
    sIncommingBubbleTop = incommingBubbleTop;
}

@end
