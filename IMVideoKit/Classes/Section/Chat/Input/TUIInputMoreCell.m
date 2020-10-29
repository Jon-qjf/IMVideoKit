//
//  TMoreCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIInputMoreCell.h"
#import "THeader.h"
#import "TUIKit.h"

static TUIInputMoreCellData *TUI_Photo_MoreCell;
static TUIInputMoreCellData *TUI_Picture_MoreCell;

@implementation TUIInputMoreCellData



+ (TUIInputMoreCellData *)pictureData
{
    if (!TUI_Picture_MoreCell) {
        TUI_Picture_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Picture_MoreCell.title = @"Camera";
        TUI_Picture_MoreCell.image = [UIImage imageNamed:@"icon_takephoto"];

    }
    return TUI_Picture_MoreCell;
}

+ (void)setPictureData:(TUIInputMoreCellData *)cameraData
{
    TUI_Picture_MoreCell = cameraData;
}

+ (TUIInputMoreCellData *)photoData
{
    if (!TUI_Photo_MoreCell) {
        TUI_Photo_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Photo_MoreCell.title = @"Album";
        TUI_Photo_MoreCell.image = [UIImage imageNamed:@"icon_picture"];
    }
    return TUI_Photo_MoreCell;
}

+ (void)setPhotoData:(TUIInputMoreCellData *)pictureData
{
    TUI_Photo_MoreCell = pictureData;
}

@end
@interface TUIInputMoreCell(){
    UIView *_backView;
}
@end
@implementation TUIInputMoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    
    _backView = [[UIView alloc]init];
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.layer.cornerRadius = 15;
    
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [_backView addSubview:_image];
    [self addSubview:_backView];
    

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:12]];
    [_title setTextColor:[UIColor colorWithRed:50/255.0 green:61/255.0 blue:81/255.0 alpha:1]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(TUIInputMoreCellData *)data
{
    //set data
    _data = data;
    if (data == nil) {
        _backView.backgroundColor = [UIColor clearColor];
    }else{
        _backView.backgroundColor = [UIColor whiteColor];
    }
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
    CGSize menuSize = TMoreCell_Image_Size;
    _backView.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _image.frame = CGRectMake(0, 0, 30, 30);
    _image.center = _backView.center;
    _title.frame = CGRectMake(0, _backView.frame.origin.y + _backView.frame.size.height+2, _backView.frame.size.width, TMoreCell_Title_Height);
}

+ (CGSize)getSize
{
    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(menuSize.width, menuSize.height + TMoreCell_Title_Height);
}
-(void)setHighlighted:(BOOL)highlighted{
    if (highlighted) {
        _backView.backgroundColor = RGBA(50, 61, 81, 0.1);
    }else{
        _backView.backgroundColor = [UIColor whiteColor];
    }
}
@end
