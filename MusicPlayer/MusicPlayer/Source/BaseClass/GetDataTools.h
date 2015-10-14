//
//  GetDataTools.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/6.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PassValue)(NSArray *array);


@interface GetDataTools : NSObject

//  作为单例的属性，这个数组可以在任何位置，任何时间被访问（）
@property(nonatomic,strong)NSMutableArray *dataArry;
//  单例
+(instancetype)shareGetData;

//  重点 !!!
//  获取数据的方法
//  根据传入的UR，通过Block返回一个数组。
//  工作之后,有些单位专门编写SDK(既我们使用的第三方),这些三方现在基本都支持这种形式.
-(void)getDataWithURL:(NSString *)URL PassValue:(PassValue)passValue;

//  获取玩数据后 给一个index 而不是所有数据的方法  ？？？？？
-(MusicList *)getModelWithIndex:(NSInteger)index;

@end
