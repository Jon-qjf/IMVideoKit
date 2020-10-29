//
//  TUIChatController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIChatController.h"
#import "THeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <MMLayout/UIView+MMLayout.h>
#import "TUIGroupPendencyViewModel.h"
#import "TUIMessageController.h"
#import "TUIImageMessageCellData.h"
#import "TUIGroupPendencyController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "TZImagePickerController.h"
#import "TUITextMessageCellData.h"
#import "THelper.h"
#import "IMCustomMessageModel.h"
#import "TCUtil.h"
#import "IMSystemTipsCell.h"
#import "IMSystemTipsCellData.h"
#import "IMSysMuteCellData.h"
#import "IMSysMuteCell.h"
#import "IMTextMessageCell.h"
#import "IMManager.h"
@interface TUIChatController () <TMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>
@property (nonatomic, strong) TIMConversation *conversation;
@property UIView *tipsView;
@property UILabel *pendencyLabel;
@property UIButton *pendencyBtn;
@property TUIGroupPendencyViewModel *pendencyViewModel;
@end

@implementation TUIChatController

- (instancetype)initWithConversation:(TIMConversation *)conversation;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _conversation = conversation;

        NSMutableArray *moreMenus = [NSMutableArray array];
        [moreMenus addObject:[TUIInputMoreCellData photoData]];
        [moreMenus addObject:[TUIInputMoreCellData pictureData]];
        _moreMenus = moreMenus;

        if (_conversation.getType == TIM_GROUP) {
            _pendencyViewModel = [TUIGroupPendencyViewModel new];
            _pendencyViewModel.groupId = [_conversation getReceiver];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}


- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];

    @weakify(self)
    //message
    _messageController = [[TUIMessageController alloc] init];
    _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:_conversation];

    //input
    _inputController = [[TUIInputController alloc] init];
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _inputController.delegate = self;
    [_inputController.inputBar.micButton setImage:[UIImage imageNamed:@"chat_video"] forState:UIControlStateNormal];
    [_inputController.inputBar.micButton setImage:[UIImage imageNamed:@"chat_video"] forState:UIControlStateHighlighted];
    

    
    [_inputController.inputBar.keyboardButton setImage:[UIImage imageNamed:@"chat_text"] forState:UIControlStateNormal];
    [_inputController.inputBar.keyboardButton setImage:[UIImage imageNamed:@"chat_text"] forState:UIControlStateHighlighted];
    [_inputController.inputBar.moreButton setImage:[UIImage FLImagePathWithName:@"icon_add" bundle:@"IMVideoKitImages" targetClass:[self class]] forState:UIControlStateNormal];
    
    
    _inputController.inputBar.recordButton.layer.cornerRadius = TTextView_TextView_Height_Min / 2;
    [_inputController.inputBar.recordButton.layer setBorderWidth:0];
    _inputController.inputBar.inputTextView.layer.cornerRadius = TTextView_TextView_Height_Min / 2;
    _inputController.inputBar.inputTextView.layer.borderWidth = 0;
    

    
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.inputController.moreView setData:x];
    }];
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];

    TIMMessageDraft *draft = [self.conversation getDraft];
    if(draft){
        for (int i = 0; i < draft.elemCount; ++i) {
            TIMElem *elem = [draft getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                _inputController.inputBar.inputTextView.text = text.text;
                [self.conversation setDraft:nil];
                break;
            }
        }
    }


    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);

    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];


    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:@"点击处理" forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.hidden = YES;


    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:@"%@条入群请求", unReadCnt];
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            [UIView animateWithDuration:1.f animations:^{
                self.tipsView.hidden = NO;
                self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
            }];
        } else {
            self.tipsView.hidden = YES;
        }
    }];
    [self getPendencyList];
}

- (void)getPendencyList
{
    if (self.conversation.getType == TIM_GROUP)
        [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender
{
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height
{
    
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.29 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height;
        ws.messageController.view.frame = msgFrame;

        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;

        [ws.messageController scrollToBottom:NO];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg
{
    [_messageController sendMessage:msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:msg];
    }
}

- (void)sendMessage:(TUIMessageCellData *)message
{
   
    [_messageController sendMessage:message];
    
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    }
    if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
        [_delegate chatController:self onSelectMoreCell:cell];
    }
}

- (void)didTapInMessageController:(TUIMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TUIMessageController *)controller willShowMenuInCell:(TUIMessageCell *)cell
{
    if([_inputController.inputBar.inputTextView isFirstResponder]){
        _inputController.inputBar.inputTextView.overrideNextResponder = cell;
        
        
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(TIMMessage *)data
{
    TIMMessage *msg = data;
    if (msg && msg.elemCount > 0) {
        TIMElem *elem = [msg getElem:0];
        if ([elem isKindOfClass:[TIMTextElem class]]) {
            if (!msg.isSelf) {
                TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            
                [[TIMFriendshipManager sharedInstance] getUsersProfile:@[msg.sender] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
                    data.avatarUrl = [NSURL URLWithString:profiles[0].faceURL];
                    
                    NSLog(@"%@",profiles[0].faceURL);
                } fail:^(int code, NSString *msg) {
                    
                }];
                
            }
        }
        if([elem isKindOfClass:[TIMCustomElem class]]) {
            NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
            IMCustomMessageModel *model = [IMCustomMessageModel initWithDictionary:param];
            if (param != nil && [model.MsgType isEqualToString:@"SYSTextElem"]) {
                TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
                data.content = model.MsgContent.Text;
                if (!msg.isSelf) {
                    [[TIMFriendshipManager sharedInstance] getUsersProfile:@[msg.sender] forceUpdate:NO succ:^(NSArray<TIMUserProfile *> *profiles) {
                        data.avatarUrl = [NSURL URLWithString:profiles[0].faceURL];
                        
                        NSLog(@"%@",profiles[0].faceURL);
                    } fail:^(int code, NSString *msg) {
                        
                    }];
                }
                return data;
            } else if (param != nil && [model.MsgType isEqualToString:@"SYSRemindElem"]) {
                IMSystemTipsCellData *cellData = [[IMSystemTipsCellData alloc] init];
                cellData.content = model.MsgContent.Text;
                return cellData;
            } else if (param != nil && [model.MsgType isEqualToString:@"SYSMuteElem"]) {
                IMSysMuteCellData *cellData = [[IMSysMuteCellData alloc] init];
                cellData.content = model.MsgContent.Text;
                [[IMManager shareManager]isAllMute:^(BOOL isMute) {
                    self.inputController.inputBar.hidden = YES;
                    self.messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                    self.inputController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0);
                }];
                return cellData;
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([data isKindOfClass:[IMSystemTipsCellData class]]) {
        IMSystemTipsCell *myCell = [[IMSystemTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMSystemTipsCell"];
        [myCell fillWithData:(IMSystemTipsCellData *)data];
        return myCell;
    }else if ([data isKindOfClass:[IMSysMuteCellData class]]) {
        IMSysMuteCell *myCell = [[IMSysMuteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMSysMuteCell"];
        [myCell fillWithData:(IMSysMuteCellData *)data];
        return myCell;
    }else if ([data isKindOfClass:[TUITextMessageCellData class]]) {
        IMTextMessageCell *myCell = [[IMTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMTextMessageCell"];
        [myCell fillWithData:(IMTextMessageCellData *)data];
        return myCell;
    }
    return nil;
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if (cell.messageData.identifier == nil)
        return;

    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageAvatar:)]) {
        [self.delegate chatController:self onSelectMessageAvatar:cell];
        return;
    }

    @weakify(self)
    TIMFriend *friend = [[TIMFriendshipManager sharedInstance] queryFriend:cell.messageData.identifier];
    if (friend) {
        id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
        if ([vc isKindOfClass:[UIViewController class]]) {
            vc.friendProfile = friend;
            [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            return;
        }
    }

    [[TIMFriendshipManager sharedInstance] getUsersProfile:@[cell.messageData.identifier] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
        @strongify(self)
        if (profiles.count > 0) {
            id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.userProfile = profiles[0];
                vc.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                return;
            }
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageContent:)]) {
        [self.delegate chatController:self onSelectMessageContent:cell];
        return;
    }
}


- (void)didHideMenuInMessageController:(TUIMessageController *)controller
{
    _inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

// ----------------------------------
- (void)selectPhotoForSend
{
     TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
       //            // 是否显示可选原图按钮
                   imagePicker.allowPickingOriginalPhoto = NO;
                   // 是否允许显示视频
                   imagePicker.allowPickingVideo = NO;
                   imagePicker.showSelectedIndex = YES;
                   imagePicker.barItemTextColor = RGB(50,61,81);
                   imagePicker.photoWidth = 500;     //图片宽度
                   imagePicker.photoPreviewMaxWidth = 500;
                   imagePicker.preferredLanguage = @"en";  //首选语言
                   imagePicker.iconThemeColor = [UIColor blueColor];
                   imagePicker.naviBgColor = [UIColor whiteColor];
                   imagePicker.naviTitleColor = [UIColor blackColor];
                   if (@available(iOS 13.0, *)) {
                      
                       imagePicker.statusBarStyle = UIStatusBarStyleDarkContent;
                   } else {
             
                       imagePicker.statusBarStyle = UIStatusBarStyleDefault;
                   }
                   
                   imagePicker.photoSelImage = [UIImage imageNamed:@"photo_sel"];
                   imagePicker.photoDefImage = [UIImage imageNamed:@"photo_def"];
                   imagePicker.needShowStatusBar = YES;
                 
                   __weak typeof(imagePicker) weakimagePicker = imagePicker;
                   [imagePicker setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
                       [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
                       [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateDisabled)];
                       [doneButton setBackgroundColor:RGB(107,162,255)];
                       weakimagePicker.showSelectedIndex = YES;
                       weakimagePicker.photoSelImage = [UIImage imageNamed:@"photo_sel"];
                       weakimagePicker.photoDefImage = [UIImage imageNamed:@"photo_def"];
                       
                   }];
                   [imagePicker setPhotoPreviewPageUIConfigBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
                       
                       NSString *countStr;
                       countStr = [NSString stringWithFormat:@"Done(%@)",numberLabel.text];
                       [doneButton setTitle:countStr forState:(UIControlStateNormal)];
                       [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
                       [doneButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateDisabled)];
                       [doneButton setBackgroundColor:RGB(107,162,255)];
                       weakimagePicker.showSelectedIndex = NO;
                       [selectButton setImage:[UIImage imageNamed:@"preview_photo_sel"] forState:(UIControlStateSelected)];
                       [selectButton setImage:[UIImage imageNamed:@"preview_photo_def"] forState:(UIControlStateNormal)];
                       
                       [originalPhotoButton setTitle:@"123" forState:(UIControlStateNormal)];
                       
                   }];
                   [imagePicker setPhotoPickerPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
                       doneButton.frame = CGRectMake(Screen_Width-120, 10, 95, 32);
                       doneButton.layer.cornerRadius = 3;
                   }];
                   [imagePicker setPhotoPreviewPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
                       backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y + 20, backButton.frame.size.width, backButton.frame.size.height);
                       selectButton.frame = CGRectMake(selectButton.frame.origin.x, selectButton.frame.origin.y + 20, selectButton.frame.size.width, selectButton.frame.size.height);
                       doneButton.frame = CGRectMake(Screen_Width-120, 5, 95, 32);
                       doneButton.layer.cornerRadius = 3;
                   }];
                   [imagePicker setPhotoPickerPageDidRefreshStateBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
                       NSString *countStr;
                       countStr = [NSString stringWithFormat:@"Done(%@)",numberLabel.text];
                       
                       [doneButton setTitle:countStr forState:(UIControlStateNormal)];
                       numberLabel.hidden = YES;
                       numberImageView.hidden = YES;
                       weakimagePicker.showSelectedIndex = YES;
                       weakimagePicker.photoSelImage = [UIImage imageNamed:@"photo_sel"];
                       weakimagePicker.photoDefImage = [UIImage imageNamed:@"photo_def"];
                   }];
                   [imagePicker setPhotoPreviewPageDidRefreshStateBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
                       NSString *countStr;
                       countStr = [NSString stringWithFormat:@"Done(%@)",numberLabel.text];
                       
                       [doneButton setTitle:countStr forState:(UIControlStateNormal)];
                       numberLabel.hidden = YES;
                       numberImageView.hidden = YES;
                   }];
                   // 这是一个navigation 只能present
                   // 设置 模态弹出模式。 iOS 13默认非全屏
                   imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                   [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)takePictureForSend
{
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Notification" message:@"Please allow us to access your camera to send a picture" preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([app canOpenURL:settingsURL]) {
                [app openURL:settingsURL options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        }]];
        [self presentViewController:ac animated:YES completion:nil];
        return;
    }
    if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 快速点的时候会回调多次
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            NSData *data = UIImageJPEGRepresentation(image, 0.75);
            NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiImage.path = path;
            uiImage.length = data.length;
            [self sendMessage:uiImage];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:uiImage];
            }
        }
    }];
}
// 选择照片的回调
-(void)imagePickerController:(TZImagePickerController *)picker
      didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                sourceAssets:(NSArray *)assets
       isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{

    NSLog(@"&^#$#%@",photos);
    for (UIImage *img in photos) {
        UIImage *image = img;
        UIImageOrientation imageOrientation = img.imageOrientation;
        if(imageOrientation != UIImageOrientationUp)
        {
            CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
            CGFloat aspectWidth = image.size.width * aspectRatio;
            CGFloat aspectHeight = image.size.height * aspectRatio;

            UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
            [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        CGSize size = CGSizeMake(500,500/(image.size.width/image.size.height));
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImageJPEGRepresentation(resultImage, 1);
        NSLog(@"datadatadata:%lu",(unsigned long)data.length);
        NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
        NSLog(@"pathpathpath:%@",path);
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];

        TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        uiImage.path = path;
        uiImage.length = data.length;
        [self sendMessage:uiImage];

        if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [self.delegate chatController:self didSendMessage:uiImage];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
