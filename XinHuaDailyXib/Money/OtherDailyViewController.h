//
//  DemoSubViewController.h
//  NLScrollPagination
//
//  Created by noahlu on 14-8-11.
//  Copyright (c) 2014年 noahlu<codedancerhua@gmail.com>. All rights reserved.
//

#import "NLSubTableViewController.h"

@interface OtherDailyViewController : NLSubTableViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong)Service *service;
@property(nonatomic,strong)NSString *date;
@property(nonatomic, strong)DailyArticles *daily_articles;
-(void)loadThisDailyFromDB;
@end
