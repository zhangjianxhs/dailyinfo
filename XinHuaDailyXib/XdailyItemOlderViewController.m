//
//  XdailyItemOlderViewControllerViewController.m
//  XinHuaNewsIOS
//
//  Created by apple on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XdailyItemOlderViewController.h"
#import "NewslistRemoteViewController.h"
#import "ExpressRemoteViewController.h"
@interface XdailyItemOlderViewController ()

@end

@implementation XdailyItemOlderViewController
@synthesize webView;
@synthesize channel_id;
@synthesize channel_title;
@synthesize indicator;
@synthesize waitingView;
@synthesize emptyinfo_view;
@synthesize type;
@synthesize url;
@synthesize outURL;
@synthesize channel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewDidLayoutSubviews {
    // only works for iOS 7+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        
        // snaps the view under the status bar (iOS 6 style)
        viewBounds.origin.y = topBarOffset*-1;
        
        // shrink the bounds of your view to compensate for the offset
        //viewBounds.size.height = viewBounds.size.height -20;
        self.view.bounds = viewBounds;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];  
    self.navigationController.navigationBar.hidden = YES;
    UIImageView* bimgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    bimgv.userInteractionEnabled = YES;
    bimgv.image = [UIImage imageNamed:@"ext_navbar.png"];
    UIButton* butb = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 35, 35)];
    butb.showsTouchWhenHighlighted=YES;
    [butb addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [butb setBackgroundImage:[UIImage imageNamed:@"backheader.png"] forState:UIControlStateNormal];
    [bimgv addSubview:butb];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 40)];
    [self.view addSubview:lab];
    lab.text = self.channel_title;
    lab.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor clearColor];
    lab.textColor = [UIColor blackColor];
    [bimgv addSubview:lab];
    [self.view addSubview:bimgv];    
     webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416+(iPhone5?88:0))];
        [self.view addSubview:webView];
        for (UIView* sv in [self.webView subviews])        
       {
           NSLog(@"first layer: %@", sv);        
         for (UIView* s2 in [sv subviews])            
      {            
           NSLog(@"second layer: %@ *** %@", s2, [s2 class]);            
            for (UIGestureRecognizer *recognizer in s2.gestureRecognizers) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){                    
                   recognizer.enabled = NO;                    
               }                
           }
       }        
   }
    [self makeWaitingView];
    [self showWaitingView];
    [self makeEmptyInfo];
     self.webView.delegate=self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[self makeURL]]];
    
	// Do any additional setup after loading the view.
}
-(void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];   
}
-(NSURL *)makeURL{
    
    if([self.type isEqualToString:@"file"]){
        return  [NSURL fileURLWithPath:self.url];
    }else if([self.type isEqualToString:@"http"]){
        return  [NSURL URLWithString:self.url];  
    }
    return nil;
}

-(void)makeWaitingView{
    waitingView=[[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 460+(iPhone5?88:0))];
    waitingView.backgroundColor=[UIColor colorWithWhite:1 alpha:1];
    waitingView.hidden=true;
    indicator=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 100, 32, 32)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(40, 150, 231, 65)];
    imageView.image=[UIImage imageNamed:@"logo.png"];
    [waitingView addSubview:imageView];

    [waitingView addSubview:indicator];
    [self.view addSubview:waitingView];
}
-(void)showWaitingView{
    [indicator startAnimating];
    waitingView.hidden=false;
}
-(void)hideWaitingView{
    [indicator stopAnimating];
    waitingView.hidden=true;
}

-(void)showEmptyInfo{
    self.emptyinfo_view.hidden=NO;
}
-(void)makeEmptyInfo{
    UIView *emptyView=[[UIView alloc]initWithFrame:CGRectMake(0,44,320,416+(iPhone5?88:0))];
    //    emptyView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"1.png"]];
    UILabel* labtext = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 300, 100)];
    labtext.backgroundColor = [UIColor clearColor];
    labtext.text = @"联网失败，请查看网络连接";
    labtext.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    labtext.textAlignment=NSTextAlignmentCenter;
    labtext.textColor=[UIColor grayColor];
    labtext.backgroundColor = [UIColor clearColor];
    [emptyView addSubview:labtext];
    self.emptyinfo_view=emptyView;
    self.emptyinfo_view.hidden=YES;
    [self.view  addSubview:emptyView];
}
-(void)hideEmptyInfo{
    self.emptyinfo_view.hidden=YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideWaitingView];
    [self showEmptyInfo];
}
- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString* check = [[request URL] absoluteString];
    NSRange rag = [check rangeOfString:@"htm"];
    NSLog(@"ExpressRemoteViewController %@",self.channel_id);
    if(rag.location!=NSNotFound){
        if([check rangeOfString:@"index.htm"].location==NSNotFound){
            self.outURL=check;
            ExpressRemoteViewController *aController = [[ExpressRemoteViewController alloc] init];
            aController.url=self.outURL;
            aController.type=@"http";  
            aController.channel_title=self.channel_title;
            aController.channel_id=self.channel_id;
            NSLog(@"ExpressRemoteViewController url%@",aController.url);
            [self.navigationController pushViewController:aController animated:YES];
            return NO;
        }else{
            self.outURL=check;
            NewslistRemoteViewController *aController = [[NewslistRemoteViewController alloc] init];
            aController.url=self.outURL;
            aController.type=@"http";  
            aController.channel_title=self.channel_title;
            aController.channel_id=self.channel_id;
            NSLog(@"NewslistRemoteViewController url%@",aController.url);
            [self.navigationController pushViewController:aController animated:YES];
            return NO;
        }
    }
        [self showWaitingView];
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideWaitingView];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
