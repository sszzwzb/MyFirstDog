//
//  MusicPlayTools.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/6.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>   //  引入AVplayer   @@@@@@@@@@@@@@@@@@@@@@@@@@@@
//  后面的都在调用 这里的 model 和 player （单例）


// 重点!!!!!!与block回传值作比较!!!!
// 定义协议.
// 如果外界想使用本类,必须遵循和实现协议中的两个方法
@protocol MusicPlayToolsDelegate <NSObject>

//  播放时间  总时间
-(void)getCurTiem:(NSString *)curTime Totle:(NSString *)totleTime Progress:(CGFloat)progress;   //  block 出生在堆里，要放到栈里

//   结束播放 的 动作  
-(void)endOfPlayAction;  //  单例 外面实现，然后回调后，外面再用

@end

@interface MusicPlayTools : NSObject

@property(nonatomic,strong)AVPlayer *player;   //  *本类的播放指针
@property(nonatomic,strong)MusicList *model;
@property(nonatomic,weak)id<MusicPlayToolsDelegate>delegate; //  代理
 
//  单例
+(instancetype)shareMusiPlay;

//  播放音乐
-(void)musicPlay;

//  暂停音乐
-(void)musicPause;

//  准备播放
-(void)musicPrePlay;

//  跳转
-(void)seekToTimeWithValue:(CGFloat)value;

//  获取  歌词
-(NSMutableArray *)getMusicLyricArray;

//  根据当前播放时间,返回 对应歌词 在 数组 中的位置.
-(NSInteger)getIndexWithCurTime;


@end
