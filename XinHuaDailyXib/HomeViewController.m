//
//  AggregateChannelViewController.m
//  XinHuaDailyXib
//
//  Created by 刘 静 on 14-10-10.
//
//

#import "HomeViewController.h"
#import "HomeHeader.h"
#import "ChannelHeader.h"
#import "ListCell.h"
#import "MJRefresh.h"
#import "NavigationController.h"
@interface HomeViewController ()
@property(nonatomic,strong)HomeHeader *headerView;
@property (nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)ChannelsForHVC *channels_for_hvc;
@property(nonatomic,strong)Service *service;
@end

@implementation HomeViewController
@synthesize channel=_channel;
@synthesize service=_service;
@synthesize tableView=_tableView;
@synthesize headerView=_headerView;

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)buildUI{
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.headerView=[[HomeHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    self.headerView.articles=self.channels_for_hvc.header_channel.articles;
    self.headerView.delegate=self;
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadArticlesFromDB) name:kNotificationArticleReceived object:nil];
    [self.tableView addHeaderWithTarget:self action:@selector(reloadArticlesFromNET)];
    [self reloadArticlesFromDB];
}
-(void)reloadArticlesFromNET{
    [self.service fetchHomeArticlesFromNET:^(NSArray *channels) {
        [self reloadArticlesFromDB];
    } errorHandler:^(NSError *error) {
        //<#code#>
    }];
}
-(void)reloadArticlesFromDB{
    if(self.channels_for_hvc.header_channel.articles!=nil){
        if(self.tableView.tableHeaderView==nil) self.tableView.tableHeaderView=[[HomeHeader alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 160)];
        ((HomeHeader *)self.tableView.tableHeaderView).articles=self.channels_for_hvc.header_channel.articles;
        ((HomeHeader *)self.tableView.tableHeaderView).delegate=self;
    }else{
        self.tableView.tableHeaderView=nil;
    }
    self.channels_for_hvc=[self.service fetchHomeArticlesFromDB];
    [self.tableView reloadData];
}
NSString *HomeListCellID = @"HomeListCellID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell *cell=nil;
    cell = [tableView dequeueReusableCellWithIdentifier:HomeListCellID];
    if(cell==nil){
        cell=[[ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HomeListCellID];
    }
    Channel *channel=[self.channels_for_hvc.other_channels objectAtIndex:indexPath.section];
    Article *article = [channel.articles objectAtIndex:indexPath.row];
    cell.article=article;
    return (UITableViewCell *)cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    headerView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.6];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(3, 1, 300, 18)];
    titleLabel.text=((Channel *)[self.channels_for_hvc.other_channels objectAtIndex:section]).channel_name;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.font=[UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.channels_for_hvc.other_channels count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return ((Channel *)[self.channels_for_hvc.other_channels objectAtIndex:section]).channel_name;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return [((Channel *)[self.channels_for_hvc.other_channels objectAtIndex:section]).articles count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    Channel *channel=(Channel *)[self.channels_for_hvc.other_channels objectAtIndex:section];
    if([channel.articles count]==0){
        return 0;
    }else{
        return 30;
    }
}
-(void)clicked{
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Channel *channel=[self.channels_for_hvc.other_channels objectAtIndex:indexPath.section];
    Article *article = [channel.articles objectAtIndex:indexPath.row];
    [AppDelegate.main_vc presentArtilceContentVCWithArticle:article channel:channel];
}
-(void)triggerRefresh{
    [self reloadArticlesFromNET];
}
@end
