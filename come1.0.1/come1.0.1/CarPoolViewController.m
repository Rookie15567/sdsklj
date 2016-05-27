//
//  CarPoolViewController.m
//  come
//
//  Created by qianfeng on 16/5/14.
//  Copyright © 2016年 qianfeng. All rights reserved.
//

#import "CarPoolViewController.h"
#import "MyDesTableViewCell.h"
#import "PlubicInfo.h"
#import "MyRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "UIScrollView+MJRefresh.h"
@interface CarPoolViewController ()<UITableViewDataSource,UITableViewDelegate,MyRequestDelegate,EGORefreshTableDelegate,EGORefreshTableHeaderDelegate>
{
    CGSize _sss;
    UITableView * _tableView;
    NSMutableArray *_dataSource;
    int _pag ;
    int _tag_id ; //
    int _lastPosition;
    DesModel * _desmodel;
    MyDesTableViewCell * _cell;
    BOOL isrefresh;
}
@property (nonatomic,strong)MyRequest * myRequest;
@property (nonatomic,strong)EGORefreshTableHeaderView * reheadView;

@end

@implementation CarPoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [NSMutableArray array];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.backgroundColor = [UIColor whiteColor];
    _pag = 0;
    _tag_id = 1;
    isrefresh = YES;
    
    NSString * path = [NSString stringWithFormat:COMPATH,_pag,_tag_id,[self takeTimeIn]];
    
    _myRequest = [[MyRequest alloc]initWithUrlString:path delegate:self];
    
    [self crateTableView];
    [self createEGOheaderView];
    [self example11];
}

-(void)finishRequest:(MyRequest *)myRuquest
{
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:myRuquest.sucData options:NSJSONReadingMutableContainers error:nil];
    NSArray * arr = dict[@"data"][@"trends_list"];
    NSArray * array = [DesModel arrayOfModelsFromDictionaries:arr error:nil];
    for (DesModel * desModel in array)
    {
        [_dataSource addObject:desModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
    
}
#pragma mark - 获取时间戳
-(CGFloat)takeTimeIn
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    
    return a;
    
}
//tableview
-(void)crateTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, S_W, S_H-150) style:UITableViewStylePlain];
    _tableView.delegate =self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
     _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [_tableView registerClass:[MyDesTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:_tableView];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(_dataSource.count>0)
    {
        DesModel * desModel = _dataSource[indexPath.row];
        cell.desModel = desModel;
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // NSLog(@"");
    return _dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MyDesTableViewCell height];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //self.tabBarController.tabBar.hidden = YES;
}
#pragma mark - scrolle
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self.reheadView egoRefreshScrollViewDidScroll:_tableView];
    
}  -(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isrefresh = NO;
    [self.reheadView egoRefreshScrollViewDidEndDragging:_tableView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}
#pragma mark - 创建下拉
-(void)createEGOheaderView
{
    if(self.reheadView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, -200,[UIScreen mainScreen].bounds.size.width, 200)];
        view.delegate = self;
        self.reheadView = view;
    }
    [self.reheadView refreshLastUpdatedDate];
    [_tableView addSubview:self.reheadView];
}
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isrefresh = YES;
    //[self downs];
    [self performSelector:@selector(downs) withObject:self afterDelay:1];
    
}

-(void)downs
{
    _pag = 0;
    if(_dataSource.count > 0)
    {
        [_dataSource removeAllObjects];
    }
    NSString * path = [NSString stringWithFormat:COMPATH,_pag,_tag_id,[self takeTimeIn]];
    
    _myRequest = [[MyRequest alloc]initWithUrlString:path delegate:self];
    
    [self.reheadView  egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    isrefresh = NO;
    
}
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isrefresh;
}
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}


#pragma  mark - foot
- (void)example11
{
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_tableView.mj_footer endRefreshing];
            [self loadMoreData];
        });
    }];
}

- (void)loadMoreData
{
    _pag ++;
    NSString * path = [NSString stringWithFormat:COMPATH,_pag,_tag_id,[self takeTimeIn]];
    _myRequest = [[MyRequest alloc]initWithUrlString:path delegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

@end
