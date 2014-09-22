//
//  NewsListPlusViewController.m
//  XinHuaDailyXib
//
//  Created by apple on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsListPlusViewController.h"
#import "XDailyItem.h"
#import "NewsArticleViewController.h"
#import "XinHuaAppDelegate.h"
#import "NewsDbOperator.h"
@interface NewsListPlusViewController ()

@end

@implementation NewsListPlusViewController
@synthesize previousWebView;
@synthesize nextWebView;
@synthesize topWebView;
@synthesize waitingView;
@synthesize indicator;
@synthesize siblings;
@synthesize baseURL;
@synthesize type;
@synthesize index;
@synthesize channel_title;
@synthesize item_title;
@synthesize newslist;
UIButton * favor_yes_btn;
UIButton * favor_no_btn;
- (void)viewDidUnload
{
    [super viewDidUnload];
    [previousWebView release];
    [nextWebView release];
    [topWebView release];
    [waitingView release];
    [indicator release];
    [siblings release];
    [baseURL release];
    [type release];
    [channel_title release];
    [item_title release];
    [newslist release];
    [favor_yes_btn release];
    [favor_no_btn release];
    // Release any retained subviews of the main view.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    UIView* booktopView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320,416+(iPhone5?88:0))];
    booktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bigtablebg.png"]];
    [self.view addSubview:booktopView];
    [booktopView release];
    //UIwebView
    previousWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416+(iPhone5?88:0))];
    nextWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416+(iPhone5?88:0))];
    topWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416+(iPhone5?88:0))];
    
    previousWebView.backgroundColor= [UIColor whiteColor]; 
    nextWebView.backgroundColor= [UIColor whiteColor]; 
    topWebView.backgroundColor= [UIColor whiteColor]; 
    
      for (UIView* sv in [self.previousWebView subviews])        
       {      
            for (UIView* s2 in [sv subviews])            
            {                      
                for (UIGestureRecognizer *recognizer in s2.gestureRecognizers) {
                    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){                    
                       recognizer.enabled = NO;                    
                    }                
                }
            }        
       }
      for (UIView* sv in [self.nextWebView subviews])        
        {       
            for (UIView* s2 in [sv subviews])            
            {                      
                for (UIGestureRecognizer *recognizer in s2.gestureRecognizers) {
                    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){                    
                        recognizer.enabled = NO;                    
                    }                
                }
            }        
        }
       for (UIView* sv in [self.topWebView subviews])        
        {    
            for (UIView* s2 in [sv subviews])            
            {                       
                for (UIGestureRecognizer *recognizer in s2.gestureRecognizers) {
                    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){                    
                        recognizer.enabled = NO;                    
                    }                
                }
            }        
        }
    self.topWebView.delegate=self;
    self.previousWebView.delegate=self;
    self.nextWebView.delegate=self;
    
    UIPanGestureRecognizer* panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGest setMaximumNumberOfTouches:1];
    [panGest setMinimumNumberOfTouches:1];
    [topWebView addGestureRecognizer:panGest];
    [panGest release];
    
    
    UIPanGestureRecognizer* panGest1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGest1 setMaximumNumberOfTouches:1];
    [panGest1 setMinimumNumberOfTouches:1];
    [previousWebView addGestureRecognizer:panGest1];
    [panGest1 release];
    
    UIPanGestureRecognizer* panGest2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGest2 setMaximumNumberOfTouches:1];
    [panGest2 setMinimumNumberOfTouches:1];
    [nextWebView addGestureRecognizer:panGest2];
    [panGest2 release];
    
    [self.view addSubview:previousWebView];
    [self.view addSubview:nextWebView];
    [self.view addSubview:topWebView];
    
    UIImageView* bimgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    bimgv.userInteractionEnabled = YES;
    bimgv.image = [UIImage imageNamed:@"titlebg.png"];
    UIButton* butb = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 35, 35)];
    butb.showsTouchWhenHighlighted=YES;
    [butb addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [butb setBackgroundImage:[UIImage imageNamed:@"backheader.png"] forState:UIControlStateNormal];
    [bimgv addSubview:butb];
    [butb release];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 40)];
    [self.view addSubview:lab];
    lab.text = self.item_title;
    lab.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    lab.textAlignment = UITextAlignmentCenter;
    lab.backgroundColor = [UIColor clearColor];
    lab.textColor = [UIColor whiteColor];
    [bimgv addSubview:lab];
    [lab release];
    
    favor_no_btn = [[UIButton alloc] initWithFrame:CGRectMake(276, 5, 33,33)];     
    UIImage *favor_no_image=[UIImage imageNamed:@"favor_pressed.png"];
    [favor_no_btn setImage:favor_no_image forState:UIControlStateNormal];
    [favor_no_btn  addTarget:self action:@selector(colect:) forControlEvents:UIControlEventTouchUpInside];
    favor_no_btn.hidden=YES;
    [bimgv addSubview:favor_no_btn];
    
    favor_yes_btn = [[UIButton alloc] initWithFrame:CGRectMake(276, 5, 33,33)];     
    UIImage *favor_yes_image=[UIImage imageNamed:@"favor_normal.png"];
    [favor_yes_btn setImage:favor_yes_image forState:UIControlStateNormal];
    [favor_yes_btn  addTarget:self action:@selector(colect:) forControlEvents:UIControlEventTouchUpInside];
    favor_yes_btn.hidden=YES;
    [bimgv addSubview:favor_yes_btn];
    
    [self.view addSubview:bimgv];
    [bimgv release];
    [self makeWaitingView];
    NSLog(@"subview___%@",self.view.subviews);
    [[self.view.subviews objectAtIndex:3] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_current_news]]]];
    [[self.view.subviews objectAtIndex:1] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_previous_news]]]];
    [[self.view.subviews objectAtIndex:2] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_next_news]]]]; 
    
    self.item_title=((XDailyItem *)[self get_current_news]).title;
  
    [[NSNotificationCenter defaultCenter] postNotificationName: KUpdateWithMemory
                                                            object: self];
    UIButton* favorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 46, 40,40)]; 
    UIImage *favor_image=[UIImage imageNamed:@"clip.png"];
    [favorBtn setImage:favor_image forState:UIControlStateNormal];
    [self.view addSubview:favorBtn];
    [favorBtn release];
    
   [[NSNotificationCenter defaultCenter] postNotificationName: KUpdateInbox
                                                         object: self];
	// Do any additional setup after loading the view.
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint v =[recognizer velocityInView:recognizer.view];    
    if(recognizer.state==UIGestureRecognizerStateEnded){
        if(v.x>0&&abs(translation.x)>abs(translation.y)){
            [self swipeRightAction:nil];
        }else if(v.x<0&&abs(translation.x)>abs(translation.y)){
            [self swipeLeftAction:nil];
            
        }
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
}

-(void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)makeWaitingView{
    waitingView=[[UIView alloc] initWithFrame:CGRectMake(10, 60, 300, 390+(iPhone5?88:0))];
    waitingView.backgroundColor=[UIColor colorWithWhite:1 alpha:1];
    waitingView.hidden=true;
    indicator=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 100, 32, 32)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(40, 150, 231, 65)];
    imageView.image=[UIImage imageNamed:@"logo.png"];
    [waitingView addSubview:imageView];
    [imageView release];
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
-(NSURL *)makeURLwith:(XDailyItem *)item{
    NSString* path_url = [item.zipurl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];   
    NSString* url=[item.pageurl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]; 
    NSString* filename=[url lastPathComponent];
    NSString* dirName = [path_url lastPathComponent];
    NSString* filePath =[[CommonMethod fileWithDocumentsPath:dirName] stringByDeletingPathExtension];
    NSString* urlStr=[NSString stringWithFormat:@"%@/%@",[filePath stringByDeletingPathExtension],filename];  
    if([self.type isEqualToString:@"file"]){
        return  [NSURL fileURLWithPath:[self.baseURL stringByAppendingString:urlStr]];
    }else if([self.type isEqualToString:@"http"]){       
        return  [NSURL URLWithString:[self.baseURL stringByAppendingString:urlStr]];  
    }
    return nil;
}
-(NSString *)getPathURL{
    XDailyItem *item=[self get_current_news];
    NSString* path_url = [item.zipurl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];   
    NSString* dirName = [path_url lastPathComponent];
    NSString* filePath =[[[CommonMethod fileWithDocumentsPath:dirName] stringByDeletingPathExtension] stringByAppendingString:@"/"];
    return filePath;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [previousWebView release];
    [nextWebView release];
    [topWebView release];
    [super dealloc];
}
- (void)swipeLeftAction:(id)sender {
    NSLog(@"%@",@"swipeLeftAction");
    NSLog(@"%@",[[self.view.subviews objectAtIndex:2] stringByEvaluatingJavaScriptFromString:@"document.title"]);
    CATransition *animation = [CATransition animation];
    //animation.delegate = self;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
	animation.type = kCATransitionReveal;
	animation.subtype = kCATransitionFromRight;	
	[self.view.layer addAnimation:animation forKey:@"animation"];
	[self.view exchangeSubviewAtIndex:3 withSubviewAtIndex:2];
	[UIView commitAnimations]; 
    [self moveDownIndex];
    XDailyItem *item=[self get_current_news];
    self.item_title=item.title;
    if(!item.isRead){
        item.isRead  = YES;
        [AppDelegate.db ModifyDailyNews:item];
        [AppDelegate.db SaveDb];
        [[NSNotificationCenter defaultCenter] postNotificationName: KUpdateWithMemory
                                                            object: self];
    }
    [[self.view.subviews objectAtIndex:1] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_previous_news]]]];
    [[self.view.subviews objectAtIndex:2] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_next_news]]]];
    [self changeSiblingsList];
}

- (void)swipeRightAction:(id)sender {
    NSLog(@"%@",@"swipeRightAction");
    NSLog(@"%@",[[self.view.subviews objectAtIndex:2] stringByEvaluatingJavaScriptFromString:@"document.title"]);
    CATransition *animation = [CATransition animation];
    //animation.delegate = self;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
	animation.type = kCATransitionMoveIn;
	animation.subtype = kCATransitionFromLeft;	
	[self.view.layer addAnimation:animation forKey:@"animation"];
    [self.view exchangeSubviewAtIndex:3 withSubviewAtIndex:1];
    [UIView commitAnimations];
    [self moveUpIndex];
    XDailyItem *item=[self get_current_news];
    self.item_title=item.title;
    if(!item.isRead){
        item.isRead  = YES;
        [AppDelegate.db ModifyDailyNews:item];
        [AppDelegate.db SaveDb];
        [[NSNotificationCenter defaultCenter] postNotificationName: KUpdateWithMemory
                                                            object: self];
    }
    [[self.view.subviews objectAtIndex:1] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_previous_news]]]];
    [[self.view.subviews objectAtIndex:2] loadRequest:[NSURLRequest requestWithURL:[self makeURLwith:[self get_next_news]]]];
    [self changeSiblingsList];
    
}
-(int)moveDownIndex{
    if(self.index==[self.siblings count]-1){
        index=0;
    }else{
        index++;
    }
    return index;
}
-(int)moveUpIndex{
    if(self.index==0){
        index=[self.siblings count]-1;
    }else{
        index--;
    }
    return index;
}
-(XDailyItem *)get_current_news{
    return [self.siblings objectAtIndex:index];
}
-(XDailyItem *)get_previous_news{
    if(index==0){
        return [self.siblings objectAtIndex:[self.siblings count]-1]; 
    }
    else{
        return [self.siblings objectAtIndex:index-1]; 
    }
    return nil;
}
-(XDailyItem *)get_next_news{
    if(index==[self.siblings count]-1)return [self.siblings objectAtIndex:0];
    else return [self.siblings objectAtIndex:index+1];
    return nil;
}
-(void)changeSiblingsList{
    NSLog(@"%@",self.siblings);
    NSString *currentURL = [[self.view.subviews objectAtIndex:3] stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if([[currentURL lastPathComponent] isEqualToString:@"index.htm"]){
        NSString *urls=[[self.view.subviews objectAtIndex:3] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('li').length"];
        int urls_length=[urls intValue];
        self.newslist=[[[NSMutableArray alloc] initWithCapacity:urls_length] autorelease];
        for(int i=0;i<urls_length;i++){
            [self.newslist addObject:[[self.view.subviews objectAtIndex:3] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('li')[%d].firstChild.getAttribute(\"href\")",i]]];
            NSLog(@"%@",[self.newslist objectAtIndex:i]);
        }
        
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* check = [[request URL] absoluteString];
    NSLog(@"%@",check);
    NSRange rag = [check rangeOfString:@"index.htm"];
    if (rag.location !=NSNotFound) {
        NSLog(@"retain%@",check);
        return YES;

    }else{
        NSLog(@"out %@",self.newslist);
    if(self.newslist!=nil){
        [self hideWaitingView];
        NSString *base=@"";
        if([self.type isEqualToString:@"http"]){
            base=[[[[request URL] absoluteString]  stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
        }else{
            base=[self getPathURL];
        }
        
        NewsArticleViewController *aController = [[NewsArticleViewController alloc] init];        
        aController.siblings=self.newslist;   
        aController.index=[self getIndexOfNewslistWith:[[request URL] lastPathComponent]];
        aController.type=self.type;
        aController.baseURL=base; 
        aController.channel_title=self.channel_title;
        aController.item_title=self.item_title;
        NSLog(@"out %@",aController.baseURL);
        NSLog(@"out %@",aController.siblings);
        NSLog(@"out %@",aController.type);
        [self.navigationController pushViewController: aController animated:YES];        
        [aController release];
        return NO;
    }else{
        
        [self showWaitingView];
        return YES;
    }
    }
    return  YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideWaitingView];
    if(self.newslist==nil){
        [self changeSiblingsList];
    }

}
-(int)getIndexOfNewslistWith:(NSString *)str{
    int ind=-1;
    for(int i=0;i<[self.newslist count];i++){
        if([[self.newslist objectAtIndex:i] isEqualToString:str]){
            ind=i;
            break;
        }
    }
    return ind;
}

@end
