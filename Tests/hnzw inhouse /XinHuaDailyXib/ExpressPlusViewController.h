//
//  ExpressPlusViewController.h
//  XinHuaDailyXib
//
//  Created by apple on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface ExpressPlusViewController : UIViewController<UIWebViewDelegate>
@property (retain, nonatomic) UIWebView *previousWebView;
@property (retain, nonatomic) UIWebView *nextWebView;
@property (retain, nonatomic) UIWebView *topWebView;
@property (retain,nonatomic)UIView *waitingView;
@property (retain,nonatomic)UIActivityIndicatorView *indicator;

@property (retain,nonatomic)NSMutableArray *siblings;
@property (retain,nonatomic)NSMutableArray *newslist;
@property (retain,nonatomic)NSString *baseURL;
@property (retain,nonatomic)NSString *type;
@property (retain,nonatomic)NSString *channel_title;
@property int index;
- (void)swipeLeftAction:(id)sender;
- (void)swipeRightAction:(id)sender;
-(void)backAction:(id)sender;
@end
