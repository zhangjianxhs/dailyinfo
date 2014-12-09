//
//  LeafChannelViewController.m
//  XinHuaDailyXib
//
//  Created by 刘 静 on 14-10-14.
//
//

#import "LeafChannelViewController.h"

@interface LeafChannelViewController ()

@end

@implementation LeafChannelViewController{
     NSDate *_time_stamp;
     int _refresh_interval_minutes;
}
@synthesize articles_for_cvc=_articles_for_cvc;
- (id)init
{
    self = [super init];
    if (self) {
        _time_stamp=[NSDate distantPast];
        _refresh_interval_minutes=5;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated{
    [self reloadArticlesFromDB];
    [super viewWillAppear:animated];
    if([self shouldTriggerRefresh]){
        [self triggerRefresh];
    }
}
-(void)reloadArticlesFromDB{
    self.articles_for_cvc=[self.service fetchArticlesFromDBWithChannel:self.channel topN:10];
    [self refreshUI];
}
-(void)reloadArticlesFromNET{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *time=[formatter stringFromDate:[NSDate distantFuture]];
    [self.service  fetchArticlesFromNETWithChannel:self.channel time:time successHandler:^(NSArray *articles) {
        [self reloadArticlesFromDB];
        [self endRefresh];
        _time_stamp=[NSDate date];
    } errorHandler:^(NSError *error) {
        [self endRefresh];
        [self.view.window showHUDWithText:error.localizedDescription Type:ShowPhotoNo Enabled:YES];
    }];
}
BOOL busy=NO;
-(void)loadMoreArticlesFromNET{
    if([self.articles_for_cvc.other_articles count]==0)return;
    if(busy)return;
    busy=YES;
    NSString *last_article_publishdate=((Article *)[self.articles_for_cvc.other_articles lastObject]).publish_date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *last_date=[dateFormatter dateFromString:last_article_publishdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *time=[formatter stringFromDate:last_date];
    NSLog(@"%@",time);
    [self.service  fetchArticlesFromNETWithChannel:self.channel time:time successHandler:^(NSArray *articles) {
        self.articles_for_cvc=[self.service fetchArticlesFromDBWithChannel:self.channel topN:[self.articles_for_cvc.other_articles count]+[articles count]];
        [self refreshUI];
        [self endLoadingMore];
        busy=NO;
    } errorHandler:^(NSError *error) {
        busy=NO;
        [self endLoadingMore];
        [self.view.window showHUDWithText:error.localizedDescription Type:ShowPhotoNo Enabled:YES];
        
    }];
}
-(void)beginLoadingMore{
    
}
-(void)endLoadingMore{
    
}
-(void)removeLoadingFooter{
    
}
-(BOOL)shouldTriggerRefresh{
    NSDate *now=[NSDate date];
    NSTimeInterval date1=[now timeIntervalSinceReferenceDate];
    NSTimeInterval date2=[_time_stamp timeIntervalSinceReferenceDate];
    NSTimeInterval interval=date1-date2;
    if(interval>_refresh_interval_minutes*60){
        return YES;
    }else{
        return NO;
    }
}
-(void)refreshUI{
   
}

-(void)triggerRefresh{
}
-(void)endRefresh{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
