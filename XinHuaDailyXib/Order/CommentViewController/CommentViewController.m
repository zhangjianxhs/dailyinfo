//
//  CommentViewController.m
//  YourOrder
//
//  Created by 胡世骞 on 14/11/25.
//  Copyright (c) 2014年 cn.XinHuaShe. All rights reserved.
//

#import "CommentViewController.h"
#import "HeadView.h"
#import "UIColor+Hex.h"
#import "SayContentCell.h"
#import "CommentView.h"
#import "ASIFormDataRequest.h"
#import "NSString+Addtions.h"

@interface CommentViewController ()<UITextViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>
{
    UILabel *contentHint;
    NSString *contentString;
    NSMutableArray *_DataSouceArray;
    UITextView *contentTextView;
    NSString *hintString;
}
@end

@implementation CommentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _DataSouceArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)createView
{
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(10,10, 260, 200)];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    [self.view addSubview:contentView];
    
    contentHint = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 200, 20)];
    contentHint.backgroundColor = [UIColor clearColor];
    contentHint.font = [UIFont systemFontOfSize:20];
    contentHint.textColor = [UIColor colorWithHexString:@"#c7c5d0"];
    contentHint.text = @"请文明发言";
    [contentView addSubview:contentHint];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10,5, contentView.frame.size.width-10, contentView.frame.size.height-20)];
    contentTextView.delegate = self;
    contentTextView.backgroundColor = [UIColor clearColor];
    //    contentTextView.p
    contentTextView.font = [UIFont systemFontOfSize:20];
    [contentView addSubview:contentTextView];
    
    UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y+contentView.frame.size.height+30, 100, 12)];
    hintLabel.text = @"最多输入160个字";
    hintLabel.font = [UIFont systemFontOfSize:12];
    hintLabel.textColor = [UIColor colorWithHexString:@"#c7c5d0"];
    [self.view addSubview:hintLabel];
    
    UIButton *sendButton = [[UIButton alloc]initWithFrame:CGRectMake(175, contentView.frame.origin.y+contentView.frame.size.height+15, 95, 45)];
    sendButton.layer.cornerRadius = 5;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.backgroundColor = [UIColor colorWithHexString:@"#1063c9"];
    [self.view addSubview:sendButton];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.#f0eff5
    self.title = @"写评论";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
    [self createView];
}

#pragma sendButtonClick 发送事件点击
-(void)sendButtonClick:(UIButton*)sender
{
    [contentTextView endEditing:YES];
    if (contentString.length==0) {
        return;
    }
//    NSString *sn = [[NSUserDefaults standardUserDefaults]objectForKey:@"SN"];
    NSString *requestString = [NSString stringWithFormat:@"http://mis.xinhuanet.com/SXTV2/Mobile/Interface/Common_SetLiterMemoComment.ashx"];
    NSURL *url = [NSURL URLWithString:requestString];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    [request setPostValue:UUID forKey:@"imei"];
    [request setPostValue:@"MRCJ_18601196685"   forKey:@"sn"];
    [request setPostValue:self.commentID    forKey:@"mid"];
    [request setPostValue:contentString    forKey:@"content"];
    [request setPostValue:@"MRCJ"    forKey:@"appid"];
    
    NSLog(@"requestString=%@?imei=%@&sn=MRCJ_18601196685&mid=%@&content=%@&appid=MRCJ",requestString,UUID,self.commentID,contentString);
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //解析网络json解析
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[jsonDict[@"error"]URLDecodedString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alter.delegate = self;
        [alter show];
 }

- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -
#pragma UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        contentHint.text = @"请填写正文内容...";
    }else{
        contentHint.text = @"";
    }
}

//隐藏键盘，实现UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }else if (textView.text.length>159)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    contentString = textView.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end