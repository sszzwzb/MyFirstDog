//
//  MusicListTableViewController.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/5.
//  Copyright (c) 2015年 zhangkayi. All rights reserved.
//

#import "MusicListTableViewController.h"
#import "MusicPlayViewController.h"


@interface MusicListTableViewController () <MusicPlayViewDelegate_name>

@property(nonatomic,strong)NSMutableArray *musicListArray;
@property(nonatomic,strong)NSArray *dataArray;

@end

@implementation MusicListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"回到当前歌曲" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarButtonAction:)];
    
    //  注册
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicListTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    //  用于 解析网络数据
    [[GetDataTools shareGetData] getDataWithURL:kURL PassValue:^(NSArray *array) {
        self.dataArray = array;     //  单例过来的方法，里面的值
        
        //  获取主线程(让子线程当主线程读)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];    ///  重新刷新数据，否则显示不出来
        });
        // 花括号里的代码实际上再子线程中执行的.
        // 子线程中严禁更新UI.
        // 通过这种方式返回到主线程执行reloadata的操作.
        // 注意:面试时,问线程间的通信方法/方式有哪些.  这个算一种.
        
        
        
#pragma mark  -  改变高度  但是有问题     ////   更改tabelView 默认高度
//        CGRect  rect = self.tableView.frame;
//        
//        rect.size.height -= 100;
//        
//        self.tableView.frame = rect;
//        
        
    }];
    
    [self p_bgImage];
    
    //  自己写的 URL
//    [self p_data];
}

-(void)p_bgImage{
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    bgImage.image = [UIImage imageNamed:@"bg2.jpg"];
    [self.tableView setBackgroundView:bgImage];
    
    UIView *bgImageBlur = [[UIView alloc]initWithFrame:self.view.frame];
    bgImageBlur.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [bgImage addSubview:bgImageBlur];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)p_data{ //  自己写的
    ///  URL
    self.musicListArray = [NSMutableArray array]; 
    //  请求方式:
    NSArray *array = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:kURL]];
    for (NSDictionary *dict in array)
    {
        MusicList *musicModel = [MusicList new];
        [musicModel setValuesForKeysWithDictionary:dict];
        [self.musicListArray addObject:musicModel];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MusicList *m = self.dataArray[indexPath.row];
    
    [cell.Image sd_setImageWithURL:[NSURL URLWithString:m.picUrl]];  //  图片
    cell.Label1.text = m.name;  //  歌曲名
    cell.Label2.text = m.singer; //  歌手
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ///  单例 返回
    MusicPlayViewController *musicVC = [MusicPlayViewController shareMusic];
    
    musicVC.index = indexPath.row;
    musicVC.dataArr_count = self.dataArray.count;

    //  代理
    musicVC.delegate = self;
    
    ///  取消按键效果  按中后会返回成没有安过的效果
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:musicVC animated:YES];
}

-(void)rightBarButtonAction:(UIBarButtonItem *)sender{
    MusicPlayViewController *musicVC = [MusicPlayViewController shareMusic];  //   返回单例  >>>>  就是返回我要唱的歌(执行单例的内容)
    
//    __block NSInteger temp = 0;
//    musicVC.mBlock = ^(NSInteger index) {
//        temp = index;
//    };
//    musicVC.index = temp;
    
    //  代理
    musicVC.delegate = self;
    [self.navigationController pushViewController:musicVC animated:YES];
}

-(void)delegate_name:(NSString *)aString{
    self.navigationItem.title = aString;
//    NSLog(@"%@",aString);  //  代理传过来的歌曲名
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
