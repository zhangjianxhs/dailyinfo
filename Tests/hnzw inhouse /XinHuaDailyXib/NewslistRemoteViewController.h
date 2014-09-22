//
//  NewslistRemoteViewController.h
//  XinHuaDailyXib
//
//  Created by apple on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NewslistRemoteViewController : UIViewController<UIWebViewDelegate>
@property (retain, nonatomic) UIWebView *webView;
@property (retain,nonatomic)UIView *waitingView;
@property (retain,nonatomic)UIActivityIndicatorView *indicator;
//输入变量
@property (retain,nonatomic)NSString *url;
@property (retain,nonatomic)NSString *type;
@property (retain,nonatomic)NSString *channel_title;
@property (retain,nonatomic)NSString *channel_id;
//输出变量
@property (retain,nonatomic)NSMutableArray *newslist;
@property (retain,nonatomic)NSString *baseURL;
@property int index;

@end
