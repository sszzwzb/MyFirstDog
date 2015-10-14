//
//  MusicPlayViewController.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef void(^myBllock)(NSInteger index);
@protocol MusicPlayViewDelegate_name <NSObject>

-(void)delegate_name:(NSString *)aString;

@end


@interface MusicPlayViewController : UIViewController

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)NSInteger dataArr_count; //  一共有多少收歌

//  单例
+(instancetype)shareMusic;

-(CGFloat)valueToString2:(NSString *)value;


////  Block 用于index
//@property(nonatomic,copy)myBllock mBlock;

//  delegate
@property(nonatomic,assign)id <MusicPlayViewDelegate_name>delegate;

@end
