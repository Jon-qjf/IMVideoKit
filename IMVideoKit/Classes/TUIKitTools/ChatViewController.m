//
//  ChatViewController.m
//  TUIKitApp
//
//  Created by kerwin Zhang on 2020/4/15.
//  Copyright © 2020 kerwin Zhang. All rights reserved.
//

#import "ChatViewController.h"
#import "TCUtil.h"
#import "IMManager.h"
#import "TUITextMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "IMSystemTipsCellData.h"
#import "IMSystemTipsCell.h"
#import "IMCustomMessageModel.h"
#import "IMSysMuteCellData.h"
#import "IMSysMuteCell.h"
#import "TUIConversationCellData.h"
#import "IMTextMessageCell.h"
#import "IMTextMessageCellData.h"
#import "TUIImageMessageCell.h"
#import "TUIImageMessageCellData.h"
#import "YBImageBrowser.h"
#import "TUIChatController.h"

@implementation UIImagePickerController (Leak)

- (BOOL)willDealloc {
    return NO;
}
@end
@interface ChatViewController ()<TUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate ,YBImageBrowserDelegate>
@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) TUIChatController *chat;
@property (nonatomic, strong) TUIMessageCellData *imTextMessageCellData;
@end

@implementation ChatViewController

- (instancetype)initWithConsultationID:(NSString *)conversationID{
    
    self = [super init];
    if (self) {
        self.conversationId = conversationID;
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:IMNewMessageNotification object:nil];
}
- (void)viewDidLoad {
    UIButton *leftButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [leftButton setFrame:CGRectMake(0, 0, 40, 40)];
    [leftButton setImageEdgeInsets:(UIEdgeInsetsMake(0, -15, 0, 15))];
    [leftButton setTintColor:[UIColor blackColor]];
    [leftButton setImage:[UIImage imageNamed:@"arrow_left"] forState:(UIControlStateNormal)];
    [leftButton addTarget:self action:@selector(back) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotification:)
                                                 name:TUIKitNotification_TIMRefreshListener
                                               object:nil];


}
-(void)setConversationId:(NSString *)conversationId{
    _conversationId = [conversationId copy];
    self.conversationData = [[TUIConversationCellData alloc] init];
    self.conversationData.convId = conversationId;
    self.conversationData.convType = self.isGroup?2:1;
    TUITextMessageCellData.outgoingTextColor = [UIColor whiteColor];
    if ([[IMManager shareManager] lastMsgIsEnd]) {
        [[IMManager shareManager]isAllMute:^(BOOL isMute) {
            self.chat.inputController.inputBar.hidden = YES;
            self.chat.messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.chat.inputController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0);
        }];
    }
    self.navigationItem.title = [IMManager shareManager].groupName;

    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:self.conversationData.convType receiver:self.conversationData.convId];
    _chat = [[TUIChatController alloc] initWithConversation:conv];
    _chat.delegate = self;
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
// 聊天窗口标题由上层维护，需要自行设置标题
- (void)onRefreshNotification:(NSNotification *)notifi
{
    NSArray<TIMConversation *> *convs = notifi.object;
    if ([convs isKindOfClass:[NSArray class]]) {
        for (TIMConversation *conv in convs) {
            if ([[conv getReceiver] isEqualToString:_conversationData.convId]) {
                if (_conversationData.convType == TIM_GROUP) {
                    _conversationData.title = [conv getGroupName];
                } else if (_conversationData.convType == TIM_C2C) {
                       TIMUserProfile *user = [[TIMFriendshipManager sharedInstance] queryUserProfile:_conversationData.convId];
                    if (user) {
                        _conversationData.title = [user showName];
                    }
                }
            }
        }
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)chatController:(TUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    if ([cell isKindOfClass:[TUIImageMessageCell class]]) {
        NSMutableArray *imgDataArr = [NSMutableArray array];
        NSMutableArray *datas = [NSMutableArray array];
        for (TUIMessageCellData *cellData in self.chat.messageController.uiMsgs) {
            if ([cellData isKindOfClass:[TUIImageMessageCellData class]]) {
                YBIBImageData *data = [YBIBImageData new];
                TUIImageMessageCellData *imgCellData = (TUIImageMessageCellData *)cellData;
                TIMImage *img = imgCellData.items[0];
                if (img) {
                    data.imageURL = [NSURL URLWithString:img.url];
                }else{
                    data.imagePath = imgCellData.path;
                }
                [datas addObject:data];
                [imgDataArr addObject:cellData];
            }
        }
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = datas;
        browser.currentPage = [imgDataArr indexOfObject:cell.messageData];
        browser.delegate = self;
        [browser show];
    }
}
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageChanged:(NSInteger)page data:(id<YBIBDataProtocol>)data {
    // 当是自定义的 Cell 时，隐藏右边的操作按钮
    // 对于工具栏的 处理自定义一个 id<YBIBToolViewHandler> 是最灵活的方式，默认实现很多时候可能满足不了需求
    imageBrowser.defaultToolViewHandler.topView.operationButton.hidden = YES;
}
- (void)sendMessage:(TUIMessageCellData*)msg {
    [_chat sendMessage:msg];
}

-(void)setParams:(NSDictionary *)params{
    _params = params;
    if (params[@"isGroup"]) {
        NSInteger isgroup = [params[@"isGroup"] boolValue];
        self.isGroup = isgroup;
        [IMManager shareManager].isGroup = self.isGroup;
    }
    if (params[@"conversationId"]) {
        self.conversationId = params[@"conversationId"];
        [IMManager shareManager].conversationId = self.conversationId;
    }
}


@end
