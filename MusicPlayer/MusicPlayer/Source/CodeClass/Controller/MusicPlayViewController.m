//
//  MusicPlayViewController.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import "MusicPlayViewController.h"
#import "MusicPlayView.h"


//   定义一个静态
static MusicPlayViewController *musicHandler = nil;

@interface MusicPlayViewController ()<MusicPlayToolsDelegate , MusicPlayViewDelegate , UITableViewDataSource , UITableViewDelegate>  ///  111111

@property(nonatomic,strong)MusicPlayView *rv;
@property(nonatomic,assign)BOOL tag;  //  判断播放按键
@property(nonatomic,assign)BOOL musicPag;  //  判断播放方式

@property(nonatomic,strong)NSArray *lyricArray;

@end

@implementation MusicPlayViewController

////   实现单例  (多线程)
+(instancetype)shareMusic{
    if (musicHandler == nil) {
        static dispatch_once_t once_token;
        dispatch_once(&once_token, ^{
             musicHandler = [[MusicPlayViewController alloc]init];
        });
    }
    return musicHandler;
}

-(void)loadView {
    self.rv = [[MusicPlayView alloc]init];
    self.view = _rv;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"播放列表" style:(UIBarButtonItemStylePlain) target:self action:@selector(leftBarButtonItemAction)];
    
#pragma mark  去除 Bar 第一位置在 （0，0）上  （搜索 去掉 改为）
    // ios7以后,原点是(0,0)点, 而我们希望是ios7之前的(0,64)处,也就是navigationController导航栏的下面作为(0,0)点. 下面的设置就是做这个的.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone; //  保护方法，用来设置前面默认初始位置在Bar下面开始（不在最左上角）（ios7后出来的）
    
    }
    
    // 222222222222 设置单例 的代理
    [MusicPlayTools shareMusiPlay].delegate = self;
    
    self.rv.lyricTabelView.delegate = self;
    self.rv.lyricTabelView.dataSource = self;
    
    ////   代码
    [self p_button];    ///  按键
    
    //  切割封面
    self.rv.headImageView.layer.cornerRadius = (kScreenWidth - 40) / 2 ;
    self.rv.headImageView.layer.masksToBounds = YES;  //  让图片强行匹配相框
    //  22222
    self.rv.delegate = self;
    
    //  初始第一次 顺序播放
    self.musicPag = YES;
}

//  将要出现  (生命周期)
-(void)viewWillAppear:(BOOL)animated{

    [self p_play];
    
    //  盟友  暂时
//    [self p_btnDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(UmengActio:)];
}

//   每次进来
-(void)p_play{
    //  Block 传值 (index)
//    self.mBlock ( self.index );
    NSLog(@" 第几首歌 =  %ld",self.index);
    
    //  代理
    [self.delegate delegate_name:[MusicPlayTools shareMusiPlay].model.name];
    
    //
    if ([[MusicPlayTools shareMusiPlay].model isEqual:[[GetDataTools shareGetData] getModelWithIndex:self.index]]) {  //  判断是不同一首歌，是的话就继续
        return;
    }
    
    //
    [MusicPlayTools shareMusiPlay].model = [[GetDataTools shareGetData] getModelWithIndex:self.index];
    
    [[MusicPlayTools shareMusiPlay] musicPrePlay];
    
    //  设置歌曲封面
    [self.rv.headImageView sd_setImageWithURL:[NSURL URLWithString:[MusicPlayTools shareMusiPlay].model.picUrl]];
    
#pragma mark    滑轮  调歌
    [self.rv.progressSilder addTarget:self action:@selector(signalAction:) forControlEvents:(UIControlEventValueChanged)];  ///  立刻改变,时刻改变
//    [self.rv.progressSilder addTarget:self action:@selector(signalAction:) forControlEvents:UIControlEventTouchUpInside];  //  点击
    
    
    //  设置歌词  初始化
    self.lyricArray = [[MusicPlayTools shareMusiPlay]getMusicLyricArray];
    [self.rv.lyricTabelView reloadData];
    
    //  每次换歌的时候,自动回到最顶端
    self.rv.lyricTabelView.contentOffset = CGPointMake(0, 0);
   
}

////   代理  实现  调用   33333333333
-(void)getCurTiem:(NSString *)curTime Totle:(NSString *)totleTime Progress:(CGFloat)progress{
    //  播放时间
    self.rv.currentTimeLabel.text = curTime;
    //  总时间
    self.rv.totleTimeLabel.text = totleTime;
    //  进度条
    self.rv.progressSilder.value = progress;
    
    //  1s 执行 10 次
    
    //  转图片  2D变化
    self.rv.headImageView.transform = CGAffineTransformRotate(self.rv.headImageView.transform, M_PI / 360);
    
    ///  返回歌词在数组中的位置,然后根据这个位置,将tableView跳到对应的那一行.
    NSInteger index = [[MusicPlayTools shareMusiPlay] getIndexWithCurTime];
    if (index == -1) {
        return;
    }
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.rv.lyricTabelView selectRowAtIndexPath:tempIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
#pragma mark  歌词的 字体颜色大小
    for (int i = 0; i < self.lyricArray.count-1; i++) {
        NSString *string = [self.lyricArray[i] valueForKey:@"lyricTime"];  //  歌词对应的时间
        if ([string rangeOfString:curTime].location != NSNotFound) {  //  loacation 位置
            
            [self.rv.lyricTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i-1 inSection:0]].textLabel.textColor = [UIColor whiteColor];
            [self.rv.lyricTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i-1 inSection:0]].textLabel.font = [UIFont systemFontOfSize:17.0];
            
            [self.rv.lyricTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].textLabel.textColor = [UIColor colorWithRed:1.000 green:0.967 blue:0.263 alpha:0.920];
            [self.rv.lyricTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].textLabel.font = [UIFont systemFontOfSize:19.5];
            
            [self.rv.lyricTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
    
    //  判断歌曲循环方式
    if (self.musicPag == YES) {
        self.rv.nextRunButton.hidden = YES;
        self.rv.randomRunButton.hidden = NO;
    }else{
        self.rv.randomRunButton.hidden = YES;
        self.rv.nextRunButton.hidden = NO;
    }
    
}

//  滑轮  根据调歌时间
-(void)signalAction:(UISlider *)sender   {
    [[MusicPlayTools shareMusiPlay]seekToTimeWithValue:sender.value];
}




-(void)p_button{
//    //  上一首
//    [self.rv.lastSongButton addTarget:self action:@selector(lastSongButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    //  下一首
    [self.rv.nextSongButton addTarget:self action:@selector(nextSongButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //  随机换歌
    [self.rv.randomButton addTarget:self action:@selector(randomSongButtonAction:) forControlEvents:UIControlEventTouchUpInside];
#pragma mark  - 添加观察者  的暂停
    ///  暂停
    [self.rv.playPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.rv.playPauseButton addTarget:self action:@selector(playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.tag = YES;
    
    //  添加观察者  用于看登陆状态
    // 为播放器添加观察者,观察播放速率"rate".
    // 因为AVPlayer没有一个内部属性来标识当前的播放状态.所以我们可以通过rate变相的得到播放状态.
    // 这里观察播放速率rate,是为了获得播放/暂停的触发事件,作出相应的响应事件(比如更改button的文字).
    [[MusicPlayTools shareMusiPlay].player addObserver:self forKeyPath:@"rate" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    
    //  随机下一首播放
    [self.rv.randomRunButton addTarget:self action:@selector(randomRunSongButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //  顺序下一首播放
    [self.rv.nextRunButton addTarget:self action:@selector(nextRunSongButtonAction:) forControlEvents:UIControlEventTouchUpInside];

}
// 观察播放速率的相应方法: 速率==0 表示没有暂停.
// 速率不为0 表示播放中.

//  添加观察者  用于看登陆状态
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"rate"]) {
        if ([[change valueForKey:@"new"]integerValue] == 0) {
            [self.rv.playPauseButton setTitle:@"播放1" forState:UIControlStateNormal];
//            self.tag = NO;
        }else{
            [self.rv.playPauseButton setTitle:@"暂停1" forState:UIControlStateNormal];
//            self.tag = YES;
        }
    }    
}

////  上一首
//-(void)lastSongButtonAction:(UIButton *)sender{
//    if (self.index == 0) {
//        self.index = self.dataArr_count - 1;
//    }else{
//        self.index = self.index - 1;
//    }
//    //
//    [self p_play];
//}
-(void)lastSongAction{  ///   用代理写按键  
    if (self.index == 0) {
        self.index = self.dataArr_count - 1;
    }else{
        self.index = self.index - 1;
    }
    //
    [self p_play];
}
//  下一首
-(void)nextSongButtonAction:(UIButton *)sender{
    if (self.index == self.dataArr_count - 1) {  //  单例 [GetDataTools shareGetData].dataArry.count
        self.index = 0;
    }else{
        self.index = self.index + 1;
    }
    //
    [self p_play];
}
//  随机换歌
-(void)randomSongButtonAction:(UIButton *)sender{
    NSInteger a = arc4random() % self.dataArr_count;
    if (self.index == a) {
        [self nextSongButtonAction:nil]; //  碰到相同时换下一首
    }else{
        self.index = a;
    }    
    //
    [self p_play];
}
//  暂停
-(void)playPauseButtonAction:(UIButton *)sender{
//    if (self.tag == YES) {
    if ([MusicPlayTools shareMusiPlay].player.rate == 1) {
        [[MusicPlayTools shareMusiPlay] musicPause];  //  暂停
//        self.tag = NO;
        [self.rv.playPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    }
    else{
        [[MusicPlayTools shareMusiPlay] musicPlay];   //  播放
//        self.tag = YES;
        [self.rv.playPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
//  随机下一首歌按键
-(void)randomRunSongButtonAction:(UIButton *)sender{
    self.musicPag = NO;
    self.rv.nextRunButton.hidden = NO;
    self.rv.randomRunButton.hidden = YES;
}
//  顺序下一首按键
-(void)nextRunSongButtonAction:(UIButton *)sender{
    self.musicPag = YES;
    self.rv.nextRunButton.hidden = YES;
    self.rv.randomRunButton.hidden = NO;
}
#pragma mark
//   播放结束后会播下一曲
-(void)endOfPlayAction{
    if (self.musicPag == YES) {  //  顺序播放
        [self nextSongButtonAction:nil];
    }
    if (self.musicPag == NO) {
        [self randomSongButtonAction:nil];  //  随机播放
    }
    
    [MusicPlayTools shareMusiPlay].player.rate = 1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 歌词  tabelView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lyricArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.lyricArray[indexPath.row]valueForKey:@"lyricStr"];//  KVC
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.title = [MusicPlayTools shareMusiPlay].model.name;
    
    //  设置前面 table 为 clearColor 好让后面的图片显出来
    cell.backgroundColor = [UIColor clearColor];
#pragma mark  -  添加背景图片  (不能写在cell 里)
    UIImageView *image = [[UIImageView alloc]init];
    [image sd_setImageWithURL:[NSURL URLWithString:[MusicPlayTools shareMusiPlay].model.blurPicUrl]];
    [self.rv.lyricTabelView setBackgroundView:image];
    
    //  添加按键效果
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    cell.selectedBackgroundView = bgColorView;
    
    //  添加字体颜色
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    
#pragma mark  -  添加字体颜色   2222222
//    cell.selectedTextColor = [UIColor redColor];  、、缺点，按哪，都变色
    
    ///  可以写在这里  是否添加颜色
    
    //  看看
    
    return cell;
}

#pragma mark  -  用table快进歌曲
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //  tabel  调歌
    MusicList *m = [MusicPlayTools shareMusiPlay].getMusicLyricArray[indexPath.row];
    //  按键的时间 / 总时间
    CGFloat time = [self valueToString2:m.lyricTime] / [self valueToString2:self.rv.totleTimeLabel.text];
    [[MusicPlayTools shareMusiPlay]seekToTimeWithValue:time];
    
    
}

///   可以用scrollView 来写tabel的变化  然后有一种滑动的效果
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}
//   12:34:456 转换成  1234
-(CGFloat)valueToString2:(NSString *)value{
    CGFloat a = [[value substringWithRange:NSMakeRange(0, 2)] floatValue] * 60;
    CGFloat b = [[value substringWithRange:NSMakeRange(3, 2)] floatValue];
    return a + b;
}

#pragma mark  友盟
-(void)UmengActio:(UIButton *)sender{
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"Myappkey"
                                      shareText:@"你要分享的文字"
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToFacebook,UMShareToFacebook,UMShareToQQ,UMShareToSms,UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToEmail,nil]//  分享的目的地
                                       delegate:nil];
    
//  http://dev.umeng.com/social/ios/quick-integration  友盟页面
    
//    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];
    // 由于苹果审核政策需求，建议大家对未安装客户端平台进行隐藏，在设置QQ、微信AppID之后调用下面的方法
}


-(void)leftBarButtonItemAction{
    //  代理 写了2次，还有一个自己跳转过去的
    [self.delegate delegate_name:[MusicPlayTools shareMusiPlay].model.name];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
