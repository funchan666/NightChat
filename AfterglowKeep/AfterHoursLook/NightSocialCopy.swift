import UIKit

enum NightKey: String {
    case cancel, confirm, more, send, stay, leave
    case follow, followed, following, followers, friends
    case chatting, video, liveNow, audience, host
    case settings, settingsKicker
    case blacklist, blacklistHint, empty
    case language, languageHint, chooseLanguage, languageNote, confirmLanguage
    case community, communityHint
    case privacy, privacyHint
    case agreement, agreementHint
    case logOut, logOutHint
    case deleteAccount, deleteAccountHint
    case safety, houseScrolls, preferences, account
    case customerSupport, inviteCode, feedback, backpack
    case all, live, fresh, followTab, music
    case featuredCreators, liveRooms, newVideo, followCreators, nightTracks
    case global, europe, eastAsia, latin, africa
    case party, recent
    case liveVoiceRooms, followedRooms, recentlyJoined
    case roomsFollow, roomsRecent, roomsActive
    case noFollowedRooms, noRecentRooms, noLiveRooms, noRoomsInList
    case message, chatWithFriends, tellOpinion, deleteConversation, newMessage
    case followSomeoneFirst, noPostsYet, noChatsYet, noFollowsYet
    case fans, followStat
    case sendGift, liveRoomDetails, roomRank, region
    case viewers, likes, gifts, liveDuration
    case leaveRoom, leaveRoomBody
    case audienceWatching, addFriend, asked
    case plusFollow, unfollow
    case editProfile, save, name, bio, gender, birthday, country, interests
    case changeCover, changePhoto
    case female, male, nonbinary, preferNot
}

enum NightLang {
    static func t(_ key: NightKey) -> String {
        let tongue = NightSocialSessionDrawer.shared.spokenTongue
        return pack(tongue)[key] ?? pack("English")[key] ?? key.rawValue
    }

    static func format(_ key: NightKey, _ value: CVarArg) -> String {
        String(format: t(key), value)
    }

    static func localeId() -> String {
        switch NightSocialSessionDrawer.shared.spokenTongue {
        case "中文 (简体)": return "zh-Hans"
        case "中文 (繁體)": return "zh-Hant"
        case "日本語": return "ja"
        case "한국어": return "ko"
        case "Español": return "es"
        case "Français": return "fr"
        case "Deutsch": return "de"
        case "العربية": return "ar"
        case "Português": return "pt"
        case "Italiano": return "it"
        case "Русский": return "ru"
        case "हिन्दी": return "hi"
        case "Türkçe": return "tr"
        case "ไทย": return "th"
        case "Tiếng Việt": return "vi"
        case "Bahasa Indonesia": return "id"
        case "Nederlands": return "nl"
        case "Polski": return "pl"
        default: return "en"
        }
    }

    static func applyLayoutDirection() {
        let rtl = NightSocialSessionDrawer.shared.spokenTongue == "العربية"
        let dir: UISemanticContentAttribute = rtl ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = dir
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.semanticContentAttribute = dir }
        UserDefaults.standard.set([localeId()], forKey: "AppleLanguages")
    }

    private static func pack(_ tongue: String) -> [NightKey: String] {
        tables[tongue] ?? tables["English"] ?? [:]
    }

    private static var tables: [String: [NightKey: String]] { [
        "English": en,
        "中文 (简体)": zhHans,
        "中文 (繁體)": zhHant,
        "日本語": ja,
        "한국어": ko,
        "Español": es,
        "Français": fr,
        "Deutsch": de,
        "العربية": ar,
        "Português": pt,
        "Italiano": it,
        "Русский": ru,
        "हिन्दी": hi,
        "Türkçe": tr,
        "ไทย": th,
        "Tiếng Việt": vi,
        "Bahasa Indonesia": id,
        "Nederlands": nl,
        "Polski": pl,
    ] }

    private static let en: [NightKey: String] = [
        .cancel: "Cancel", .confirm: "Confirm", .more: "More", .send: "SEND",
        .stay: "Stay", .leave: "Leave",
        .follow: "Follow", .followed: "Followed", .following: "Following",
        .followers: "Followers", .friends: "Friends",
        .chatting: "Chatting", .video: "video", .liveNow: "Live now",
        .audience: "Audience", .host: "Host",
        .settings: "Settings", .settingsKicker: "House, desk, and sitting",
        .blacklist: "Blacklist", .blacklistHint: "Desks you hid from this sitting", .empty: "Empty",
        .language: "Language", .languageHint: "Spoken labels on this desk",
        .chooseLanguage: "Choose the language for NightChat",
        .languageNote: "Menus and buttons switch to the language you pick.",
        .confirmLanguage: "Are you sure you want to\nchange the language?",
        .community: "Community Rules", .communityHint: "How we keep the house kind",
        .privacy: "Privacy agreement", .privacyHint: "How NightChat holds your data",
        .agreement: "User agreement", .agreementHint: "Terms of this sitting",
        .logOut: "Log Out", .logOutHint: "Park this desk until next time",
        .deleteAccount: "Deletion of account", .deleteAccountHint: "Erase this night desk",
        .safety: "Safety", .houseScrolls: "House scrolls", .preferences: "Preferences", .account: "Account",
        .customerSupport: "Customer Support", .inviteCode: "Invite Code",
        .feedback: "Feedback", .backpack: "My backpack",
        .all: "ALL", .live: "Live", .fresh: "New", .followTab: "Follow", .music: "Music",
        .featuredCreators: "Featured creators", .liveRooms: "Live rooms",
        .newVideo: "New Video", .followCreators: "Follow creators", .nightTracks: "Night tracks",
        .global: "Global", .europe: "Europe", .eastAsia: "East Asia", .latin: "Latin", .africa: "Africa",
        .party: "Party", .recent: "Recent",
        .liveVoiceRooms: "Live voice rooms", .followedRooms: "Followed rooms",
        .recentlyJoined: "Recently joined",
        .roomsFollow: "%d rooms from creators you follow",
        .roomsRecent: "%d rooms you visited recently",
        .roomsActive: "%d active rooms",
        .noFollowedRooms: "No followed rooms yet.",
        .noRecentRooms: "No recent rooms yet.",
        .noLiveRooms: "No live rooms right now.",
        .noRoomsInList: "No rooms in this list yet.",
        .message: "Message", .chatWithFriends: "Chat with friends",
        .tellOpinion: "Tell me your opinion...",
        .deleteConversation: "Delete conversation",
        .newMessage: "New message",
        .followSomeoneFirst: "Follow someone first.\nNew messages start from people you follow.",
        .noPostsYet: "No posts yet.",
        .noChatsYet: "No chats yet.\nOpen a profile, then send a line after you follow each other.",
        .noFollowsYet: "You are not following anyone yet.",
        .fans: "Fans", .followStat: "Follow",
        .sendGift: "Send a gift", .liveRoomDetails: "Live Room Details",
        .roomRank: "Room rank", .region: "Region",
        .viewers: "Viewers", .likes: "Likes", .gifts: "Gifts", .liveDuration: "Live",
        .leaveRoom: "Leave this room?",
        .leaveRoomBody: "You'll drop the mic and go back to Party.",
        .audienceWatching: "%d watching this sitting",
        .addFriend: "Add friend", .asked: "Asked",
        .plusFollow: "+ Follow", .unfollow: "Unfollow",
        .editProfile: "Edit Profile", .save: "Save",
        .name: "Name", .bio: "Bio", .gender: "Gender",
        .birthday: "Birthday", .country: "Country", .interests: "Interests",
        .changeCover: "Change the background image", .changePhoto: "Change photo",
        .female: "Female", .male: "Male", .nonbinary: "Non-binary", .preferNot: "Prefer not to say",
    ]

    private static let zhHans: [NightKey: String] = [
        .cancel: "取消", .confirm: "确认", .more: "更多", .send: "发送",
        .stay: "留下", .leave: "退出",
        .follow: "关注", .followed: "已关注", .following: "关注",
        .followers: "粉丝", .friends: "好友",
        .chatting: "私信", .video: "动态", .liveNow: "直播中",
        .audience: "观众", .host: "房主",
        .settings: "设置", .settingsKicker: "账号、安全与偏好",
        .blacklist: "黑名单", .blacklistHint: "你屏蔽的用户", .empty: "空",
        .language: "语言", .languageHint: "切换应用显示语言",
        .chooseLanguage: "选择 NightChat 的显示语言",
        .languageNote: "菜单和按钮会切换成你选择的语言。",
        .confirmLanguage: "确定要切换语言吗？",
        .community: "社区规范", .communityHint: "一起维护友善氛围",
        .privacy: "隐私协议", .privacyHint: "我们如何保护你的数据",
        .agreement: "用户协议", .agreementHint: "使用条款",
        .logOut: "退出登录", .logOutHint: "下次再回来",
        .deleteAccount: "注销账号", .deleteAccountHint: "删除这个账号",
        .safety: "安全", .houseScrolls: "协议", .preferences: "偏好", .account: "账号",
        .customerSupport: "客服", .inviteCode: "邀请码",
        .feedback: "反馈", .backpack: "我的背包",
        .all: "全部", .live: "直播", .fresh: "最新", .followTab: "关注", .music: "音乐",
        .featuredCreators: "精选创作者", .liveRooms: "直播间",
        .newVideo: "新视频", .followCreators: "关注的人", .nightTracks: "夜间曲目",
        .global: "全球", .europe: "欧洲", .eastAsia: "东亚", .latin: "拉美", .africa: "非洲",
        .party: "派对", .recent: "最近",
        .liveVoiceRooms: "语音直播间", .followedRooms: "关注的房间",
        .recentlyJoined: "最近加入",
        .roomsFollow: "你关注的人有 %d 个房间",
        .roomsRecent: "你最近访问过 %d 个房间",
        .roomsActive: "%d 个正在进行的房间",
        .noFollowedRooms: "还没有关注的房间。",
        .noRecentRooms: "还没有最近访问的房间。",
        .noLiveRooms: "现在没有正在直播的房间。",
        .noRoomsInList: "这个列表还没有房间。",
        .message: "消息", .chatWithFriends: "和好友聊天",
        .tellOpinion: "说点什么…",
        .deleteConversation: "删除会话",
        .newMessage: "新消息",
        .followSomeoneFirst: "先关注一个人。\n互相关注后就可以发消息。",
        .noPostsYet: "还没有动态。",
        .noChatsYet: "还没有聊天。\n打开主页，互关之后就可以发消息。",
        .noFollowsYet: "你还没有关注任何人。",
        .fans: "粉丝", .followStat: "关注",
        .sendGift: "送礼物", .liveRoomDetails: "直播间详情",
        .roomRank: "房间排名", .region: "地区",
        .viewers: "观众", .likes: "点赞", .gifts: "礼物", .liveDuration: "时长",
        .leaveRoom: "离开这个房间？",
        .leaveRoomBody: "你会放下麦克风，回到派对。",
        .audienceWatching: "%d 人正在观看",
        .addFriend: "加好友", .asked: "已申请",
        .plusFollow: "+ 关注", .unfollow: "取消关注",
        .editProfile: "编辑资料", .save: "保存",
        .name: "昵称", .bio: "简介", .gender: "性别",
        .birthday: "生日", .country: "国家", .interests: "兴趣标签",
        .changeCover: "点击更换背景图", .changePhoto: "更换头像",
        .female: "女", .male: "男", .nonbinary: "非二元", .preferNot: "不愿透露",
    ]

    private static let zhHant: [NightKey: String] = [
        .cancel: "取消", .confirm: "確認", .more: "更多", .send: "傳送",
        .stay: "留下", .leave: "離開",
        .follow: "追蹤", .followed: "已追蹤", .following: "追蹤中",
        .followers: "粉絲", .friends: "好友",
        .chatting: "私訊", .video: "動態", .liveNow: "直播中",
        .audience: "觀眾", .host: "房主",
        .settings: "設定", .settingsKicker: "帳號、安全與偏好",
        .blacklist: "黑名單", .blacklistHint: "你封鎖的使用者", .empty: "空",
        .language: "語言", .languageHint: "切換應用顯示語言",
        .chooseLanguage: "選擇 NightChat 的顯示語言",
        .languageNote: "選單與按鈕會切換成你選擇的語言。",
        .confirmLanguage: "確定要切換語言嗎？",
        .community: "社群規範", .communityHint: "一起維持友善氛圍",
        .privacy: "隱私權協議", .privacyHint: "我們如何保護你的資料",
        .agreement: "使用者協議", .agreementHint: "使用條款",
        .logOut: "登出", .logOutHint: "下次再回來",
        .deleteAccount: "刪除帳號", .deleteAccountHint: "刪除這個帳號",
        .safety: "安全", .houseScrolls: "協議", .preferences: "偏好", .account: "帳號",
        .customerSupport: "客服", .inviteCode: "邀請碼",
        .feedback: "回饋", .backpack: "我的背包",
        .all: "全部", .live: "直播", .fresh: "最新", .followTab: "追蹤", .music: "音樂",
        .featuredCreators: "精選創作者", .liveRooms: "直播間",
        .newVideo: "新影片", .followCreators: "追蹤的人", .nightTracks: "夜間曲目",
        .global: "全球", .europe: "歐洲", .eastAsia: "東亞", .latin: "拉美", .africa: "非洲",
        .party: "派對", .recent: "最近",
        .liveVoiceRooms: "語音直播間", .followedRooms: "追蹤的房間",
        .recentlyJoined: "最近加入",
        .roomsFollow: "你追蹤的人有 %d 個房間",
        .roomsRecent: "你最近造訪過 %d 個房間",
        .roomsActive: "%d 個進行中的房間",
        .noFollowedRooms: "還沒有追蹤的房間。",
        .noRecentRooms: "還沒有最近造訪的房間。",
        .noLiveRooms: "現在沒有正在直播的房間。",
        .noRoomsInList: "這個列表還沒有房間。",
        .message: "訊息", .chatWithFriends: "和好友聊天",
        .tellOpinion: "說點什麼…",
        .deleteConversation: "刪除對話",
        .newMessage: "新訊息",
        .followSomeoneFirst: "先追蹤一個人。\n互相關注後就可以傳訊息。",
        .noPostsYet: "還沒有動態。",
        .noChatsYet: "還沒有聊天。\n打開主頁，互關之後就可以傳訊息。",
        .noFollowsYet: "你還沒有追蹤任何人。",
        .fans: "粉絲", .followStat: "追蹤",
        .sendGift: "送禮物", .liveRoomDetails: "直播間詳情",
        .roomRank: "房間排名", .region: "地區",
        .viewers: "觀眾", .likes: "讚", .gifts: "禮物", .liveDuration: "時長",
        .leaveRoom: "離開這個房間？",
        .leaveRoomBody: "你會放下麥克風，回到派對。",
        .audienceWatching: "%d 人正在觀看",
        .addFriend: "加好友", .asked: "已申請",
        .plusFollow: "+ 追蹤", .unfollow: "取消追蹤",
        .editProfile: "編輯資料", .save: "儲存",
        .name: "暱稱", .bio: "簡介", .gender: "性別",
        .birthday: "生日", .country: "國家", .interests: "興趣標籤",
        .changeCover: "點擊更換背景圖", .changePhoto: "更換頭像",
        .female: "女", .male: "男", .nonbinary: "非二元", .preferNot: "不願透露",
    ]

    private static let ja: [NightKey: String] = [
        .cancel: "キャンセル", .confirm: "確認", .more: "その他", .send: "送信",
        .stay: "残る", .leave: "退出",
        .follow: "フォロー", .followed: "フォロー中", .following: "フォロー",
        .followers: "フォロワー", .friends: "フレンド",
        .chatting: "チャット", .video: "投稿", .liveNow: "ライブ配信中",
        .audience: "視聴者", .host: "ホスト",
        .settings: "設定", .settingsKicker: "アカウントと表示",
        .blacklist: "ブロックリスト", .blacklistHint: "非表示にしたユーザー", .empty: "なし",
        .language: "言語", .languageHint: "アプリの表示言語",
        .chooseLanguage: "NightChat の表示言語を選ぶ",
        .languageNote: "メニューとボタンが選んだ言語に切り替わります。",
        .confirmLanguage: "言語を変更しますか？",
        .community: "コミュニティガイドライン", .communityHint: "やさしい場を保つために",
        .privacy: "プライバシー", .privacyHint: "データの取り扱い",
        .agreement: "利用規約", .agreementHint: "本サービスの条件",
        .logOut: "ログアウト", .logOutHint: "次回また戻る",
        .deleteAccount: "アカウント削除", .deleteAccountHint: "このデスクを消す",
        .safety: "安全", .houseScrolls: "規約", .preferences: "設定", .account: "アカウント",
        .customerSupport: "サポート", .inviteCode: "招待コード",
        .feedback: "フィードバック", .backpack: "バックパック",
        .all: "すべて", .live: "ライブ", .fresh: "新着", .followTab: "フォロー", .music: "音楽",
        .featuredCreators: "注目のクリエイター", .liveRooms: "ライブルーム",
        .newVideo: "新しい動画", .followCreators: "フォロー中", .nightTracks: "ナイトトラック",
        .global: "グローバル", .europe: "ヨーロッパ", .eastAsia: "東アジア", .latin: "ラテン", .africa: "アフリカ",
        .party: "パーティー", .recent: "最近",
        .liveVoiceRooms: "ボイスルーム", .followedRooms: "フォロー中のルーム",
        .recentlyJoined: "最近参加",
        .roomsFollow: "フォロー中のルーム %d",
        .roomsRecent: "最近のルーム %d",
        .roomsActive: "進行中のルーム %d",
        .noFollowedRooms: "フォロー中のルームはまだありません。",
        .noRecentRooms: "最近のルームはまだありません。",
        .noLiveRooms: "配信中のルームはありません。",
        .noRoomsInList: "このリストにルームはありません。",
        .message: "メッセージ", .chatWithFriends: "フレンドとチャット",
        .tellOpinion: "メッセージを入力…",
        .deleteConversation: "会話を削除",
        .newMessage: "新しいメッセージ",
        .followSomeoneFirst: "先に誰かをフォローしてください。",
        .noPostsYet: "投稿はまだありません。",
        .noChatsYet: "チャットはまだありません。",
        .noFollowsYet: "まだ誰もフォローしていません。",
        .fans: "ファン", .followStat: "フォロー",
        .sendGift: "ギフトを送る", .liveRoomDetails: "ルーム詳細",
        .roomRank: "ルームランク", .region: "地域",
        .viewers: "視聴者", .likes: "いいね", .gifts: "ギフト", .liveDuration: "配信",
        .leaveRoom: "このルームを出ますか？",
        .leaveRoomBody: "マイクを置いてパーティーに戻ります。",
        .audienceWatching: "%d人が視聴中",
        .addFriend: "フレンド追加", .asked: "申請済み",
        .plusFollow: "+ フォロー",
    ]

    private static let ko: [NightKey: String] = [
        .cancel: "취소", .confirm: "확인", .more: "더보기", .send: "전송",
        .stay: "머물기", .leave: "나가기",
        .follow: "팔로우", .followed: "팔로잉", .following: "팔로잉",
        .followers: "팔로워", .friends: "친구",
        .chatting: "채팅", .video: "게시물", .liveNow: "라이브 중",
        .audience: "시청자", .host: "호스트",
        .settings: "설정", .settingsKicker: "계정과 표시 언어",
        .blacklist: "차단 목록", .blacklistHint: "숨긴 사용자", .empty: "없음",
        .language: "언어", .languageHint: "앱 표시 언어",
        .chooseLanguage: "NightChat 표시 언어 선택",
        .languageNote: "메뉴와 버튼이 선택한 언어로 바뀝니다.",
        .confirmLanguage: "언어를 변경할까요?",
        .community: "커뮤니티 규칙", .communityHint: "안전한 공간 만들기",
        .privacy: "개인정보 처리방침", .privacyHint: "데이터 보호 방법",
        .agreement: "이용약관", .agreementHint: "서비스 약관",
        .logOut: "로그아웃", .logOutHint: "다음에 다시 오기",
        .deleteAccount: "계정 삭제", .deleteAccountHint: "이 계정 지우기",
        .safety: "안전", .houseScrolls: "약관", .preferences: "환경설정", .account: "계정",
        .customerSupport: "고객지원", .inviteCode: "초대 코드",
        .feedback: "피드백", .backpack: "내 가방",
        .all: "전체", .live: "라이브", .fresh: "신규", .followTab: "팔로우", .music: "음악",
        .featuredCreators: "추천 크리에이터", .liveRooms: "라이브 룸",
        .newVideo: "새 영상", .followCreators: "팔로우 중", .nightTracks: "나이트 트랙",
        .global: "글로벌", .europe: "유럽", .eastAsia: "동아시아", .latin: "라틴", .africa: "아프리카",
        .party: "파티", .recent: "최근",
        .liveVoiceRooms: "음성 룸", .followedRooms: "팔로우한 룸",
        .recentlyJoined: "최근 참여",
        .roomsFollow: "팔로우한 룸 %d개",
        .roomsRecent: "최근 방문한 룸 %d개",
        .roomsActive: "진행 중인 룸 %d개",
        .noFollowedRooms: "팔로우한 룸이 없습니다.",
        .noRecentRooms: "최근 룸이 없습니다.",
        .noLiveRooms: "지금 라이브 룸이 없습니다.",
        .noRoomsInList: "이 목록에 룸이 없습니다.",
        .message: "메시지", .chatWithFriends: "친구와 채팅",
        .tellOpinion: "메시지를 입력하세요…",
        .deleteConversation: "대화 삭제",
        .newMessage: "새 메시지",
        .followSomeoneFirst: "먼저 누군가를 팔로우하세요.",
        .noPostsYet: "아직 게시물이 없습니다.",
        .noChatsYet: "아직 채팅이 없습니다.",
        .noFollowsYet: "아직 아무도 팔로우하지 않았습니다.",
        .fans: "팬", .followStat: "팔로우",
        .sendGift: "선물 보내기", .liveRoomDetails: "룸 정보",
        .roomRank: "룸 순위", .region: "지역",
        .viewers: "시청자", .likes: "좋아요", .gifts: "선물", .liveDuration: "방송",
        .leaveRoom: "이 룸을 나갈까요?",
        .leaveRoomBody: "마이크를 내려놓고 파티로 돌아갑니다.",
        .audienceWatching: "%d명이 시청 중",
        .addFriend: "친구 추가", .asked: "요청됨",
        .plusFollow: "+ 팔로우",
    ]

    private static let es: [NightKey: String] = [
        .cancel: "Cancelar", .confirm: "Confirmar", .more: "Más", .send: "ENVIAR",
        .stay: "Quedarme", .leave: "Salir", .follow: "Seguir", .followed: "Siguiendo",
        .following: "Siguiendo", .followers: "Seguidores", .friends: "Amigos",
        .chatting: "Chat", .video: "publicaciones", .liveNow: "En vivo",
        .audience: "Audiencia", .host: "Anfitrión", .settings: "Ajustes",
        .settingsKicker: "Cuenta e idioma", .blacklist: "Lista negra", .empty: "Vacío",
        .language: "Idioma", .languageHint: "Idioma de la app",
        .chooseLanguage: "Elige el idioma de NightChat",
        .languageNote: "Menús y botones cambiarán al idioma elegido.",
        .confirmLanguage: "¿Seguro que quieres\ncambiar el idioma?",
        .community: "Normas de la comunidad", .privacy: "Privacidad",
        .agreement: "Términos", .logOut: "Cerrar sesión", .deleteAccount: "Eliminar cuenta",
        .safety: "Seguridad", .preferences: "Preferencias", .account: "Cuenta",
        .customerSupport: "Soporte", .inviteCode: "Código de invitación",
        .feedback: "Comentarios", .backpack: "Mochila",
        .all: "TODO", .live: "Live", .fresh: "Nuevo", .followTab: "Seguir", .music: "Música",
        .featuredCreators: "Creadores destacados", .liveRooms: "Salas en vivo",
        .party: "Fiesta", .recent: "Reciente",
        .liveVoiceRooms: "Salas de voz", .followedRooms: "Salas seguidas",
        .recentlyJoined: "Unidas recientemente",
        .roomsFollow: "%d salas de creadores que sigues",
        .roomsRecent: "%d salas que visitaste",
        .roomsActive: "%d salas activas",
        .noFollowedRooms: "Aún no hay salas seguidas.",
        .noRecentRooms: "Aún no hay salas recientes.",
        .noLiveRooms: "No hay salas en vivo ahora.",
        .message: "Mensajes", .chatWithFriends: "Chatea con amigos",
        .tellOpinion: "Dime tu opinión...", .deleteConversation: "Eliminar conversación",
        .newMessage: "Mensaje nuevo", .noPostsYet: "Aún no hay publicaciones.",
        .fans: "Fans", .followStat: "Seguir", .sendGift: "Enviar regalo",
        .liveRoomDetails: "Detalles de la sala", .leaveRoom: "¿Salir de esta sala?",
        .leaveRoomBody: "Dejarás el micrófono y volverás a Fiesta.",
        .plusFollow: "+ Seguir",
    ]

    private static let fr: [NightKey: String] = [
        .cancel: "Annuler", .confirm: "Confirmer", .more: "Plus", .send: "ENVOYER",
        .stay: "Rester", .leave: "Quitter", .follow: "Suivre", .followed: "Suivi",
        .following: "Abonnements", .followers: "Abonnés", .friends: "Amis",
        .chatting: "Discussion", .video: "publications", .liveNow: "En direct",
        .audience: "Audience", .host: "Hôte", .settings: "Réglages",
        .language: "Langue", .languageHint: "Langue de l’app",
        .chooseLanguage: "Choisir la langue de NightChat",
        .languageNote: "Menus et boutons passent à la langue choisie.",
        .confirmLanguage: "Voulez-vous vraiment\nchanger de langue ?",
        .community: "Règles de la communauté", .privacy: "Confidentialité",
        .agreement: "Conditions", .logOut: "Se déconnecter", .deleteAccount: "Supprimer le compte",
        .customerSupport: "Assistance", .inviteCode: "Code d’invitation",
        .feedback: "Avis", .backpack: "Sac",
        .all: "TOUT", .live: "Live", .fresh: "Nouveau", .followTab: "Suivre", .music: "Musique",
        .party: "Soirée", .recent: "Récent",
        .liveVoiceRooms: "Salons vocaux", .followedRooms: "Salons suivis",
        .noFollowedRooms: "Pas encore de salons suivis.",
        .message: "Messages", .tellOpinion: "Dis-moi ce que tu en penses...",
        .deleteConversation: "Supprimer la conversation",
        .noPostsYet: "Pas encore de publications.",
        .sendGift: "Envoyer un cadeau", .leaveRoom: "Quitter ce salon ?",
        .plusFollow: "+ Suivre",
    ]

    private static let de: [NightKey: String] = [
        .cancel: "Abbrechen", .confirm: "Bestätigen", .more: "Mehr", .send: "SENDEN",
        .stay: "Bleiben", .leave: "Verlassen", .follow: "Folgen", .followed: "Gefolgt",
        .following: "Folgst du", .followers: "Follower", .friends: "Freunde",
        .chatting: "Chat", .video: "Beiträge", .liveNow: "Live",
        .audience: "Zuschauer", .host: "Host", .settings: "Einstellungen",
        .language: "Sprache", .languageHint: "App-Sprache",
        .chooseLanguage: "Sprache für NightChat wählen",
        .languageNote: "Menüs und Buttons wechseln in die gewählte Sprache.",
        .confirmLanguage: "Sprache wirklich ändern?",
        .community: "Community-Regeln", .privacy: "Datenschutz",
        .agreement: "Nutzungsbedingungen", .logOut: "Abmelden", .deleteAccount: "Konto löschen",
        .customerSupport: "Support", .inviteCode: "Einladungscode",
        .feedback: "Feedback", .backpack: "Rucksack",
        .all: "ALLE", .live: "Live", .fresh: "Neu", .followTab: "Folgen", .music: "Musik",
        .party: "Party", .recent: "Zuletzt",
        .liveVoiceRooms: "Voice-Räume", .followedRooms: "Gefolgte Räume",
        .noFollowedRooms: "Noch keine gefolgten Räume.",
        .message: "Nachrichten", .tellOpinion: "Sag mir deine Meinung...",
        .deleteConversation: "Chat löschen", .noPostsYet: "Noch keine Beiträge.",
        .sendGift: "Geschenk senden", .leaveRoom: "Diesen Raum verlassen?",
        .plusFollow: "+ Folgen",
    ]

    private static let ar: [NightKey: String] = [
        .cancel: "إلغاء", .confirm: "تأكيد", .more: "المزيد", .send: "إرسال",
        .stay: "بقاء", .leave: "خروج", .follow: "متابعة", .followed: "متابَع",
        .following: "المتابَعون", .followers: "المتابِعون", .friends: "أصدقاء",
        .chatting: "دردشة", .video: "المنشورات", .liveNow: "مباشر",
        .audience: "الجمهور", .host: "المضيف", .settings: "الإعدادات",
        .language: "اللغة", .languageHint: "لغة التطبيق",
        .chooseLanguage: "اختر لغة NightChat",
        .languageNote: "ستتحول القوائم والأزرار إلى اللغة المختارة.",
        .confirmLanguage: "هل تريد تغيير اللغة؟",
        .community: "قواعد المجتمع", .privacy: "الخصوصية",
        .agreement: "الاتفاقية", .logOut: "تسجيل الخروج", .deleteAccount: "حذف الحساب",
        .customerSupport: "الدعم", .inviteCode: "رمز الدعوة",
        .feedback: "ملاحظات", .backpack: "الحقيبة",
        .all: "الكل", .live: "مباشر", .fresh: "جديد", .followTab: "متابعة", .music: "موسيقى",
        .party: "حفلة", .recent: "الأخير",
        .liveVoiceRooms: "غرف صوتية", .followedRooms: "الغرف المتابَعة",
        .noFollowedRooms: "لا توجد غرف متابَعة بعد.",
        .message: "الرسائل", .tellOpinion: "قل رأيك...",
        .deleteConversation: "حذف المحادثة", .noPostsYet: "لا منشورات بعد.",
        .sendGift: "إرسال هدية", .leaveRoom: "مغادرة هذه الغرفة؟",
        .plusFollow: "+ متابعة",
    ]

    private static let pt: [NightKey: String] = [
        .cancel: "Cancelar", .confirm: "Confirmar", .more: "Mais", .send: "ENVIAR",
        .stay: "Ficar", .leave: "Sair", .follow: "Seguir", .followed: "Seguindo",
        .following: "Seguindo", .followers: "Seguidores", .friends: "Amigos",
        .chatting: "Chat", .video: "publicações", .liveNow: "Ao vivo",
        .settings: "Ajustes", .language: "Idioma",
        .chooseLanguage: "Escolha o idioma do NightChat",
        .languageNote: "Menus e botões mudam para o idioma escolhido.",
        .confirmLanguage: "Tem certeza de que quer\nmudar o idioma?",
        .logOut: "Sair", .deleteAccount: "Excluir conta",
        .customerSupport: "Suporte", .inviteCode: "Código de convite",
        .all: "TUDO", .live: "Ao vivo", .fresh: "Novo", .followTab: "Seguir", .music: "Música",
        .party: "Festa", .recent: "Recente",
        .noFollowedRooms: "Ainda não há salas seguidas.",
        .message: "Mensagens", .tellOpinion: "Diga sua opinião...",
        .deleteConversation: "Excluir conversa", .noPostsYet: "Ainda não há publicações.",
        .sendGift: "Enviar presente", .leaveRoom: "Sair desta sala?",
        .plusFollow: "+ Seguir",
    ]

    private static let it: [NightKey: String] = [
        .cancel: "Annulla", .confirm: "Conferma", .more: "Altro", .send: "INVIA",
        .stay: "Resta", .leave: "Esci", .follow: "Segui", .followed: "Seguito",
        .following: "Seguiti", .followers: "Follower", .friends: "Amici",
        .chatting: "Chat", .video: "post", .liveNow: "In diretta",
        .settings: "Impostazioni", .language: "Lingua",
        .chooseLanguage: "Scegli la lingua di NightChat",
        .languageNote: "Menu e pulsanti passano alla lingua scelta.",
        .confirmLanguage: "Vuoi davvero cambiare lingua?",
        .logOut: "Esci", .deleteAccount: "Elimina account",
        .all: "TUTTO", .live: "Live", .fresh: "Nuovo", .followTab: "Segui", .music: "Musica",
        .party: "Party", .recent: "Recenti",
        .noFollowedRooms: "Nessuna stanza seguita.",
        .message: "Messaggi", .tellOpinion: "Dimmi la tua opinione...",
        .deleteConversation: "Elimina conversazione", .noPostsYet: "Nessun post ancora.",
        .sendGift: "Invia un regalo", .leaveRoom: "Lasciare questa stanza?",
        .plusFollow: "+ Segui",
    ]

    private static let ru: [NightKey: String] = [
        .cancel: "Отмена", .confirm: "Подтвердить", .more: "Ещё", .send: "ОТПРАВИТЬ",
        .stay: "Остаться", .leave: "Выйти", .follow: "Подписаться", .followed: "Вы подписаны",
        .following: "Подписки", .followers: "Подписчики", .friends: "Друзья",
        .chatting: "Чат", .video: "посты", .liveNow: "В эфире",
        .settings: "Настройки", .language: "Язык",
        .chooseLanguage: "Выберите язык NightChat",
        .languageNote: "Меню и кнопки переключатся на выбранный язык.",
        .confirmLanguage: "Точно сменить язык?",
        .logOut: "Выйти", .deleteAccount: "Удалить аккаунт",
        .all: "ВСЕ", .live: "Эфир", .fresh: "Новое", .followTab: "Подписки", .music: "Музыка",
        .party: "Вечеринка", .recent: "Недавние",
        .noFollowedRooms: "Пока нет комнат из подписок.",
        .message: "Сообщения", .tellOpinion: "Напишите сообщение...",
        .deleteConversation: "Удалить переписку", .noPostsYet: "Пока нет публикаций.",
        .sendGift: "Отправить подарок", .leaveRoom: "Покинуть комнату?",
        .plusFollow: "+ Подписка",
    ]

    private static let hi: [NightKey: String] = [
        .cancel: "रद्द करें", .confirm: "पुष्टि करें", .more: "और", .send: "भेजें",
        .stay: "रहें", .leave: "बाहर जाएँ", .follow: "फ़ॉलो", .followed: "फ़ॉलो किया",
        .following: "फ़ॉलोइंग", .followers: "फ़ॉलोअर्स", .friends: "दोस्त",
        .chatting: "चैट", .video: "पोस्ट", .liveNow: "लाइव",
        .settings: "सेटिंग्स", .language: "भाषा",
        .chooseLanguage: "NightChat की भाषा चुनें",
        .languageNote: "मेनू और बटन चुनी भाषा में बदल जाएँगे।",
        .confirmLanguage: "क्या आप भाषा बदलना चाहते हैं?",
        .logOut: "लॉग आउट", .deleteAccount: "खाता हटाएँ",
        .all: "सभी", .live: "लाइव", .fresh: "नया", .followTab: "फ़ॉलो", .music: "संगीत",
        .party: "पार्टी", .recent: "हाल ही",
        .noFollowedRooms: "अभी कोई फ़ॉलो किया कमरा नहीं।",
        .message: "संदेश", .tellOpinion: "अपनी बात लिखें...",
        .deleteConversation: "चैट हटाएँ", .noPostsYet: "अभी कोई पोस्ट नहीं।",
        .sendGift: "गिफ़्ट भेजें", .leaveRoom: "यह रूम छोड़ें?",
        .plusFollow: "+ फ़ॉलो",
    ]

    private static let tr: [NightKey: String] = [
        .cancel: "İptal", .confirm: "Onayla", .more: "Daha fazla", .send: "GÖNDER",
        .stay: "Kal", .leave: "Çık", .follow: "Takip et", .followed: "Takipte",
        .following: "Takip", .followers: "Takipçi", .friends: "Arkadaşlar",
        .chatting: "Sohbet", .video: "gönderiler", .liveNow: "Canlı",
        .settings: "Ayarlar", .language: "Dil",
        .chooseLanguage: "NightChat dilini seç",
        .languageNote: "Menüler ve düğmeler seçilen dile geçer.",
        .confirmLanguage: "Dili değiştirmek istiyor musun?",
        .logOut: "Çıkış yap", .deleteAccount: "Hesabı sil",
        .all: "TÜMÜ", .live: "Canlı", .fresh: "Yeni", .followTab: "Takip", .music: "Müzik",
        .party: "Parti", .recent: "Son",
        .noFollowedRooms: "Henüz takip edilen oda yok.",
        .message: "Mesajlar", .tellOpinion: "Fikrini yaz...",
        .deleteConversation: "Sohbeti sil", .noPostsYet: "Henüz gönderi yok.",
        .sendGift: "Hediye gönder", .leaveRoom: "Bu odadan çıkılsın mı?",
        .plusFollow: "+ Takip et",
    ]

    private static let th: [NightKey: String] = [
        .cancel: "ยกเลิก", .confirm: "ยืนยัน", .more: "เพิ่มเติม", .send: "ส่ง",
        .stay: "อยู่ต่อ", .leave: "ออก", .follow: "ติดตาม", .followed: "กำลังติดตาม",
        .following: "กำลังติดตาม", .followers: "ผู้ติดตาม", .friends: "เพื่อน",
        .chatting: "แชท", .video: "โพสต์", .liveNow: "กำลังไลฟ์",
        .settings: "การตั้งค่า", .language: "ภาษา",
        .chooseLanguage: "เลือกภาษาของ NightChat",
        .languageNote: "เมนูและปุ่มจะเปลี่ยนเป็นภาษาที่เลือก",
        .confirmLanguage: "ต้องการเปลี่ยนภาษาหรือไม่?",
        .logOut: "ออกจากระบบ", .deleteAccount: "ลบบัญชี",
        .all: "ทั้งหมด", .live: "ไลฟ์", .fresh: "ใหม่", .followTab: "ติดตาม", .music: "เพลง",
        .party: "ปาร์ตี้", .recent: "ล่าสุด",
        .noFollowedRooms: "ยังไม่มีห้องที่ติดตาม",
        .message: "ข้อความ", .tellOpinion: "พิมพ์ข้อความ...",
        .deleteConversation: "ลบแชท", .noPostsYet: "ยังไม่มีโพสต์",
        .sendGift: "ส่งของขวัญ", .leaveRoom: "ออกจากห้องนี้?",
        .plusFollow: "+ ติดตาม",
    ]

    private static let vi: [NightKey: String] = [
        .cancel: "Hủy", .confirm: "Xác nhận", .more: "Thêm", .send: "GỬI",
        .stay: "Ở lại", .leave: "Rời", .follow: "Theo dõi", .followed: "Đã theo dõi",
        .following: "Đang theo dõi", .followers: "Người theo dõi", .friends: "Bạn bè",
        .chatting: "Nhắn tin", .video: "bài đăng", .liveNow: "Đang live",
        .settings: "Cài đặt", .language: "Ngôn ngữ",
        .chooseLanguage: "Chọn ngôn ngữ NightChat",
        .languageNote: "Menu và nút sẽ đổi sang ngôn ngữ đã chọn.",
        .confirmLanguage: "Bạn chắc muốn đổi ngôn ngữ?",
        .logOut: "Đăng xuất", .deleteAccount: "Xóa tài khoản",
        .all: "TẤT CẢ", .live: "Live", .fresh: "Mới", .followTab: "Theo dõi", .music: "Nhạc",
        .party: "Tiệc", .recent: "Gần đây",
        .noFollowedRooms: "Chưa có phòng đang theo dõi.",
        .message: "Tin nhắn", .tellOpinion: "Nhập tin nhắn...",
        .deleteConversation: "Xóa cuộc trò chuyện", .noPostsYet: "Chưa có bài đăng.",
        .sendGift: "Tặng quà", .leaveRoom: "Rời phòng này?",
        .plusFollow: "+ Theo dõi",
    ]

    private static let id: [NightKey: String] = [
        .cancel: "Batal", .confirm: "Konfirmasi", .more: "Lainnya", .send: "KIRIM",
        .stay: "Tetap", .leave: "Keluar", .follow: "Ikuti", .followed: "Mengikuti",
        .following: "Mengikuti", .followers: "Pengikut", .friends: "Teman",
        .chatting: "Obrolan", .video: "kiriman", .liveNow: "Live",
        .settings: "Pengaturan", .language: "Bahasa",
        .chooseLanguage: "Pilih bahasa NightChat",
        .languageNote: "Menu dan tombol akan beralih ke bahasa yang dipilih.",
        .confirmLanguage: "Yakin ingin mengganti bahasa?",
        .logOut: "Keluar", .deleteAccount: "Hapus akun",
        .all: "SEMUA", .live: "Live", .fresh: "Baru", .followTab: "Ikuti", .music: "Musik",
        .party: "Pesta", .recent: "Terbaru",
        .noFollowedRooms: "Belum ada ruang yang diikuti.",
        .message: "Pesan", .tellOpinion: "Tulis pesan...",
        .deleteConversation: "Hapus percakapan", .noPostsYet: "Belum ada kiriman.",
        .sendGift: "Kirim hadiah", .leaveRoom: "Keluar dari ruang ini?",
        .plusFollow: "+ Ikuti",
    ]

    private static let nl: [NightKey: String] = [
        .cancel: "Annuleren", .confirm: "Bevestigen", .more: "Meer", .send: "VERZENDEN",
        .stay: "Blijven", .leave: "Verlaten", .follow: "Volgen", .followed: "Volgend",
        .following: "Volgend", .followers: "Volgers", .friends: "Vrienden",
        .chatting: "Chat", .video: "berichten", .liveNow: "Live",
        .settings: "Instellingen", .language: "Taal",
        .chooseLanguage: "Kies de taal van NightChat",
        .languageNote: "Menu’s en knoppen schakelen naar de gekozen taal.",
        .confirmLanguage: "Weet je zeker dat je\nde taal wilt wijzigen?",
        .logOut: "Uitloggen", .deleteAccount: "Account verwijderen",
        .all: "ALLES", .live: "Live", .fresh: "Nieuw", .followTab: "Volgen", .music: "Muziek",
        .party: "Feest", .recent: "Recent",
        .noFollowedRooms: "Nog geen gevolgde kamers.",
        .message: "Berichten", .tellOpinion: "Zeg wat je denkt...",
        .deleteConversation: "Gesprek verwijderen", .noPostsYet: "Nog geen berichten.",
        .sendGift: "Cadeau sturen", .leaveRoom: "Deze kamer verlaten?",
        .plusFollow: "+ Volgen",
    ]

    private static let pl: [NightKey: String] = [
        .cancel: "Anuluj", .confirm: "Potwierdź", .more: "Więcej", .send: "WYŚLIJ",
        .stay: "Zostań", .leave: "Wyjdź", .follow: "Obserwuj", .followed: "Obserwujesz",
        .following: "Obserwowani", .followers: "Obserwujący", .friends: "Znajomi",
        .chatting: "Czat", .video: "posty", .liveNow: "Na żywo",
        .settings: "Ustawienia", .language: "Język",
        .chooseLanguage: "Wybierz język NightChat",
        .languageNote: "Menu i przyciski zmienią się na wybrany język.",
        .confirmLanguage: "Na pewno zmienić język?",
        .logOut: "Wyloguj", .deleteAccount: "Usuń konto",
        .all: "WSZYSTKO", .live: "Live", .fresh: "Nowe", .followTab: "Obserwuj", .music: "Muzyka",
        .party: "Impreza", .recent: "Ostatnie",
        .noFollowedRooms: "Brak obserwowanych pokoi.",
        .message: "Wiadomości", .tellOpinion: "Napisz wiadomość...",
        .deleteConversation: "Usuń rozmowę", .noPostsYet: "Brak postów.",
        .sendGift: "Wyślij prezent", .leaveRoom: "Opuścić ten pokój?",
        .plusFollow: "+ Obserwuj",
    ]

}
