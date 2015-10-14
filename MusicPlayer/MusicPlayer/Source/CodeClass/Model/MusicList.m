//
//  MusicList.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import "MusicList.h"

@implementation MusicList

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
    if ([key isEqualToString:@"lyric"]) {
        self.timeLyric = [value componentsSeparatedByString:@"\n"];  //  截取字符串放在数组里
        
        //  歌词       [01.13.22]我是歌词\n[01.13.23]我是歌词2\n
    }
}

@end
