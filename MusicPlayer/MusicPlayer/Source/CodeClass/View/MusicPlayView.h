//
//  MusicPlayView.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicPlayViewDelegate <NSObject>

-(void)lastSongAction;

@end

@interface MusicPlayView : UIView

@property(nonatomic,strong)UILabel *titleLabel;  ///  标题  暂时没用到

@property(nonatomic,strong)UIScrollView *mainScrollView;
@property(nonatomic,strong)UIImageView *headImageView;
@property(nonatomic,strong)UITableView *lyricTabelView;

@property(nonatomic,strong)UILabel *currentTimeLabel;
@property(nonatomic,strong)UISlider *progressSilder;
@property(nonatomic,strong)UILabel *totleTimeLabel;

@property(nonatomic,strong)UIButton *lastSongButton;
@property(nonatomic,strong)UIButton *playPauseButton;
@property(nonatomic,strong)UIButton *nextSongButton;

@property(nonatomic,strong)UIButton *randomButton;  ///  随机换歌
@property(nonatomic,strong)UIButton *randomRunButton;  //  随机循环播放
@property(nonatomic,strong)UIButton *nextRunButton;  //  顺序播放


@property(nonatomic,weak)id<MusicPlayViewDelegate>delegate;

@end
