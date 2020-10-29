

@objc public enum VideoCallAction: Int32, Codable { //UserA 向 UserB 发起通话请求
    case error = -1             //系统错误
    case unknown = 0            //未知流程
    case dialing = 1            //请求发起
    case sponsorCancel = 2      //用户取消 [UserA 在 UserB 未回应时主动取消视频请求]
    case reject = 3             //用户拒绝 [UserB 拒绝通话]
    case sponsorTimeout = 4     //用户未应答 [UserB 超时未回复]
    case hangup = 5             //用户挂断 [UserA or UserB 挂断通话]
    case linebusy = 6           //用户通话中 [UserB 通话中]
    case customMessage = 7      //处理自定义消息
}

//model
@objc open class VideoCallModel: NSObject, Codable {
    @objc open var version: UInt32 = videoCallVersion                 //自定义消息 version
    @objc public var  calltype:  VideoCallType = .unknown        //邀请类型 video or voice
    @objc open var groupid: String? = nil                             //邀请群组
    @objc open var callid: String = ""                                //通话ID，每次请求的唯一ID
    @objc open var roomid: UInt32 = 0                                 //房间ID
    @objc open var action: VideoCallAction = .unknown                 //信令消息
    @objc open var code: Int = 0                                      //信令代码
    @objc open var invitedList: [String] = []                         //邀请列表
    @objc open var hangUpType: Int = 0                                //挂断类型 end = 1 挂断--正常挂断 serviceReject = 2 挂断--服务被拒绝 complete = 3 挂断--完成
    @objc open var providerPortrait: String = ""                      //头像
    @objc open var providerName: String = ""                          //名称
    @objc open var doctorProfession: String? = nil                     //医生职称
    @objc open var clinicName: String = ""                            //诊所名称
    @objc open var appointmentId: String = ""                         //订单id
    
    @objc open var customMessage:Dictionary<String, Int>? = nil                         //自定义数据
    
    
    func copy() -> VideoCallModel {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("encode失败")
        }
        let decoder = JSONDecoder()
        guard let target = try? decoder.decode(VideoCallModel.self, from: data) else {
           fatalError("decode失败")
        }
        return target
    }
    
    enum CodingKeys: String, CodingKey {
        case version
        case calltype = "call_type"
        case groupid = "group_id"
        case callid = "call_id"
        case roomid = "room_id"
        case action
        case invitedList = "invited_list"
        case hangUpType = "hangup_type"
        case providerPortrait
        case providerName
        case appointmentId
        case customMessage
        case doctorProfession
        case clinicName
    }
}

extension VideoCallAction {
    var debug: String {
        switch self {
        case .dialing:
            return ".dialing"
        case .sponsorCancel:
            return ".sponsorCancel"
        case .reject:
            return ".reject"
        case .sponsorTimeout:
            return ".sponsorTimeout"
        case .hangup:
            return ".hangup"
        case .linebusy:
            return ".linebusy"
        default:
            return ".unknown"
        }
    }
}

//constant
let videoCallVersion: UInt32 = 4

