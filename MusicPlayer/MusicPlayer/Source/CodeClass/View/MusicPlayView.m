//
//  MusicPlayView.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import "MusicPlayView.h"

@implementation MusicPlayView



-(instancetype)init{
    if (self == [super init]) {
        [self p_title];
        [self p_setup];
        [self p_setupOther];
    }
    return self;
}

-(void)p_title{
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,
                                                               250,
                                                               355,
                                                               50)];
    [self addSubview:_titleLabel];
}

-(void)p_setup{
    //  1.scrollView
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        kScreenWidth,
                                                                        kScreenHeight)];
    self.mainScrollView.contentSize = CGSizeMake(2 * kScreenWidth,
                                                 CGRectGetHeight(self.mainScrollView.frame));
    
    self.mainScrollView.pagingEnabled = YES;  //  翻页
    self.mainScrollView.alwaysBounceHorizontal = YES;  //  水平看滚动
    self.mainScrollView.alwaysBounceVertical = NO;  //  竖直不能滚动
#pragma mark  背景颜色设置  省内存方法
    //    self.mainScrollView.backgroundColor = [UIColor yellowColor];
    //    self.mainScrollView.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"bg.png"]];  //  UIColor  用系统的浪费内存建议用图片
    self.mainScrollView.layer.contents = (id)[UIImage imageNamed:@"bg.png"].CGImage;  //  减少旋转时的内存
    self.mainScrollView.bounces = NO;    //  不反弹
    
    [self addSubview:self.mainScrollView];
    self.backgroundColor = [UIColor whiteColor];
    
    /// Image
    self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20,
                                                                      20,
                                                                      kScreenWidth - 40,
                                                                      CGRectGetHeight(self.mainScrollView.frame) - 40)];
    [self.mainScrollView addSubview:_headImageView];    
    
    ////  tabel
    self.lyricTabelView = [[UITableView alloc]initWithFrame:CGRectMake(kScreenWidth,
                                                                       0,
                                                                       kScreenWidth,
                                                                       kScreenWidth)];
    [self.mainScrollView addSubview:_lyricTabelView];
//    self.lyricTabelView.backgroundColor = [UIColor whiteColor];
    self.lyricTabelView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
  
//    self.lyricTabelView.scrollEnabled = YES;  //  让UITable滚动
}


-(void)p_setupOther{
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,
                                                                     kScreenWidth + 10,
                                                                     50,
                                                                     25)];
//    self.currentTimeLabel.backgroundColor = [UIColor greenColor];
    self.currentTimeLabel.text = @"00:00";
    [self addSubview:_currentTimeLabel];
    
    self.progressSilder = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.currentTimeLabel.frame) + 20,
                                                                    kScreenWidth + 10,
                                                                    kScreenWidth - (CGRectGetWidth(self.currentTimeLabel.frame) * 2 + 40),
                                                                    25)];
//    self.progressSilder.backgroundColor = [UIColor orangeColor];
    [self addSubview:_progressSilder];
    
    self.totleTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 10 - CGRectGetWidth(self.currentTimeLabel.frame),
                                                                   kScreenWidth + 10,
                                                                   50,
                                                                   25)];
//    self.totleTimeLabel.backgroundColor = [UIColor greenColor];
    self.totleTimeLabel.text = @"00:00";
    [self addSubview:_totleTimeLabel];
    
    ///
    self.lastSongButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.lastSongButton.frame = CGRectMake(30,
                                           kScreenWidth + 80,
                                           70,
                                           35);
//    self.lastSongButton.backgroundColor = [UIColor orangeColor];
    self.lastSongButton.layer.borderWidth = 3;
    self.lastSongButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.lastSongButton setTitle:@"上一首" forState:(UIControlStateNormal)];
    [self addSubview:_lastSongButton];
#pragma mark  用代理写 上一曲 的按键
    [self.lastSongButton addTarget:self action:@selector(lastSongButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.playPauseButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.playPauseButton.frame = CGRectMake(CGRectGetMaxX(self.lastSongButton.frame) + 50,
                                            kScreenWidth + 80 - 10,
                                            60,
                                            60);
//    self.playPauseButton.backgroundColor = [UIColor orangeColor];
    self.playPauseButton.layer.cornerRadius = 30;
    self.playPauseButton.layer.borderWidth = 3;
    self.playPauseButton.layer.borderColor = [UIColor darkTextColor].CGColor;
    [self addSubview:_playPauseButton];
    
    self.nextSongButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.nextSongButton.frame = CGRectMake(CGRectGetMaxX(self.playPauseButton.frame) + 50,
                                           kScreenWidth + 80,
                                           70,
                                           35);
//    self.nextSongButton.backgroundColor = [UIColor orangeColor];
    self.nextSongButton.layer.borderWidth = 3;
    self.nextSongButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.nextSongButton setTitle:@"下一首" forState:(UIControlStateNormal)];
    [self addSubview:_nextSongButton];
    
//  换歌按键
    self.randomRunButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.randomRunButton.frame = CGRectMake(30,
                                            kScreenWidth + 80 + 70,
                                            70 ,
                                            35);
    //    self.lastSongButton.backgroundColor = [UIColor orangeColor];
    self.randomRunButton.layer.borderWidth = 3;
    self.randomRunButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.randomRunButton setTitle:@"随机播放" forState:(UIControlStateNormal)];
    [self addSubview:_randomRunButton];
    
    self.nextRunButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.nextRunButton.frame = CGRectMake(CGRectGetMaxX(self.lastSongButton.frame) + 40,
                                          kScreenWidth + 80 + 70,
                                          70 ,
                                          35);
    //    self.lastSongButton.backgroundColor = [UIColor orangeColor];
    self.nextRunButton.layer.borderWidth = 3;
    self.nextRunButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.nextRunButton setTitle:@"顺序播放" forState:(UIControlStateNormal)];
    [self addSubview:_nextRunButton];

    self.randomButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.randomButton.frame = CGRectMake(CGRectGetMaxX(self.playPauseButton.frame) + 50,
                                         kScreenWidth + 80 + 70,
                                         70,
                                         35);
    //    self.nextSongButton.backgroundColor = [UIColor orangeColor];
    self.randomButton.layer.borderWidth = 3;
    self.randomButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.randomButton setTitle:@"随机换歌" forState:(UIControlStateNormal)];
    [self addSubview:_randomButton];

}

#pragma mark  用代理写 上一曲 的按键
-(void)lastSongButtonAction:(UIButton *)sender{
    [self.delegate lastSongAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
