//
//  MusicPlayTools.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/6.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import "MusicPlayTools.h"

static MusicPlayTools *mp = nil;

@interface MusicPlayTools()  //  延展

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation MusicPlayTools

///   单例
+(instancetype)shareMusiPlay{
    if (mp == nil) {
        static dispatch_once_t once_token;
        dispatch_once(&once_token, ^{
            mp = [[MusicPlayTools alloc]init];
        });
    }
    return mp;
}
//// 这里为什么要重写init方法呢?
// 因为,我们应该得到 "某首歌曲播放结束" 这一事件,之后由外界来决定"播放结束之后采取什么操作".
// AVPlayer并没有通过block或者代理向我们返回这一状态(事件),而是向通知中心注册了一条通知(AVPlayerItemDidPlayToEndTimeNotification),我们也只有这一条途径获取播放结束这一事件.
// 所以,在我们创建好一个播放器时([[AVPlayer alloc] init]),应该立刻为通知中心添加观察者,来观察这一事件的发生.
// 这个动作放到init里,最及时也最合理.
-(instancetype)init{
    self = [super init];
    if (self) {
        _player = [[AVPlayer alloc]init];
        //  通知  (发生变化后走这个方法)
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    return self;
}


//   播放结束后的方法，由代理具体实现行为
-(void)endPlay:(NSNotification *)sender{
    // 为什么要先暂停一下呢?
    // 看看 musicPlay方法, 第一个if判断,你能明白为什么吗?
    [self musicPause];
    
    [self.delegate endOfPlayAction];
}

// 准备播放    ,我们在外部调用播放器播放时,不会调用"直接播放",而是调用这个"准备播放",当它准备好时,会直接播放.
//  准备播放
-(void)musicPrePlay{
    // 通过下面的逻辑,只要AVPlayer有currentItem,那么一定被添加了观察者.
    // 所以上来直接移除之.
    if (self.player.currentItem) {   // currentItem 系统 的 当前状态
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.model.mp3Url]];
    //  为item的status添加观察者
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld )context:nil];
    
    // 用新创建的item,替换AVPlayer之前的item.新的item是带着观察者的哦.
    [self.player replaceCurrentItemWithPlayerItem:item];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        switch ([[change valueForKey:@"new"]integerValue]) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"不知道什么错误");
                break;
            case AVPlayerItemStatusReadyToPlay:
                // 只有观察到status变为这种状态,才会真正的播放.
                [self musicPlay];
                break;
            case AVPlayerItemStatusFailed:
                // mini设备不插耳机或者某些耳机会导致准备失败.
                NSLog(@"准备失败");
                break;
                
            default:
                break;
        }
    }
}

//  播放音乐
-(void)musicPlay{
    if (self.timer != nil) {  //  如果有在运行的就返回空就好
        return;
    }
    
    // 播放后,我们开启一个计时器.  （计时器）
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    [self.player play];
}
///   代理    (重要 的方法，计时器里的代理走计时器的功能,将播放进度返回出去)
-(void)timerAction:(NSTimer *)sender{  ///    当前时间  总时间  播放进度时间
    [self.delegate getCurTiem:[self valueToString:[self getCurTime]] Totle:[self valueToString:[self getTotleTime]] Progress:[self getProgress]];
}
//  获取当前的播放时间
-(NSInteger)getCurTime{
    if (self.player.currentItem) {
        return self.player.currentTime.value / self.player.currentTime.timescale;
    }
    return 0;
}
//  获取总时长
-(NSInteger)getTotleTime{
    CMTime totleTime = [self.player.currentItem duration];
    
    if (totleTime.timescale == 0) {
        return 1;
    }else{
        return totleTime.value / totleTime.timescale;
    }
    
}
//  获取当前进度
-(CGFloat)getProgress{
    return (CGFloat)[self getCurTime] / (CGFloat)[self getTotleTime];
}
//   12:34:456 转换成  1234
-(NSString *)valueToString:(NSInteger)value{
    return [NSString stringWithFormat:@"%.2ld:%.2ld",value/60,value%60];
}


//  暂停音乐
-(void)musicPause{
    [self.timer invalidate];  //  暂停计时器
    self.timer = nil;
    [self.player pause];    
}


//  跳转
-(void)seekToTimeWithValue:(CGFloat)value{
    //  先暂停
    [self musicPause];  //  如果不暂停的话会出现错误（跳转之后不播放）
    
    //  跳转
    [self.player seekToTime:CMTimeMake(value *[self getTotleTime], 1) completionHandler:^(BOOL finished) {  //  系统的
        if (finished == YES) {
            [self musicPlay];  //  播放
        }
    }];
}



////  歌词    [01.13.22]我是歌词\n[01.13.23]我是歌词2\n  //  有其他情况
-(NSMutableArray *)getMusicLyricArray{
    NSMutableArray *array = [NSMutableArray array];
    
    for(NSString *str in self.model.timeLyric){
        if(str.length == 0){
            continue;
        }
        for (int i = 0; i < str.length; i++) {
            if([[str substringWithRange:NSMakeRange(i,1)]isEqualToString:@"]"]){
                
                MusicList *model=[[MusicList alloc]init];
                model.lyricTime=[str substringWithRange:NSMakeRange(1,i-1)];
                model.lyricStr=[str substringFromIndex:i+1];
                [array addObject:model];
            }
        }
    }
    return array;
}

//  根据当前播放时间,返回 对应歌词 在 数组 中的位置.
-(NSInteger)getIndexWithCurTime{
    NSInteger index = 0;
    NSString *curTime = [self valueToString:[self getCurTime]];
    
    for (NSString *str in self.model.timeLyric) {
        if (str.length == 0) {
            continue;
        }
        if ([curTime isEqualToString:[str substringWithRange:NSMakeRange(1, 5)]]) {
            return index;
        }
        index ++;
    }
    return -1;  //  如果没找到
}


//  根据当前播放时间,返回 对应歌词 在 进度条上 中的位置.


@end
