//
//  RightViewController.m
//  XinHuaDailyXib
//
//  Created by apple on 14/11/13.
//
//

#import "RightViewController.h"
#import "RightFunctionCell.h"
#import "SettingViewController.h"
#import "NavigationController.h"
#import "ContactUsViewController.h"
#import "AboutViewController.h"
@interface RightViewController ()
@property(nonatomic,strong)UITableView *func_table;
@property(nonatomic,strong)UIView *user_view;
@property(nonatomic,strong)UIImageView *avatar;
@property(nonatomic,strong)UILabel *user_label;
@property(nonatomic,strong)UILabel *user_phone_label;
@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor grayColor];
    self.user_view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    self.user_view.backgroundColor=[UIColor whiteColor];
    self.avatar=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_avatar_nopic.png"]];
    self.avatar.frame=CGRectMake(10, 30, 80, 80);
    [self.user_view addSubview:self.avatar];
    self.user_label=[[UILabel alloc] initWithFrame:CGRectMake(100, 40, 120, 40)];
    self.user_label.text=@"授权用户";
    self.user_label.font = [UIFont fontWithName:@"Arial" size:24];
    [self.user_view addSubview:self.user_label];
    self.user_phone_label=[[UILabel alloc] initWithFrame:CGRectMake(100, 70, 180, 40)];
    self.user_phone_label.text=@"010-88689988";
    self.user_phone_label.textColor=[UIColor grayColor];
    [self.user_view addSubview:self.user_phone_label];
    [self.view addSubview:self.user_view];
    self.func_table=[[UITableView alloc]initWithFrame:CGRectMake(0, 120, 320, 44*4)];
    self.func_table.delegate=self;
    self.func_table.dataSource=self;
    self.func_table.backgroundColor=[UIColor clearColor];
    self.func_table.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.func_table];
}
-(void)viewWillAppear:(BOOL)animated{
    self.user_phone_label.text=AppDelegate.user_defaults.sn;
}
#pragma mark --UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* str = @"cellid";
    RightFunctionCell* cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[RightFunctionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if(indexPath.section==0){
        if (indexPath.row == 0){
            cell.icon_image=[UIImage imageNamed:@"button_feedback_default.png"];
            cell.label_text=@"反馈";    
        }else if(indexPath.row == 1){
            cell.icon_image=[UIImage imageNamed:@"button_set_right_default.png"];
            cell.label_text=@"设置";
        }else if(indexPath.row == 2){
            cell.icon_image=[UIImage imageNamed:@"button_help_default.png"];
            cell.label_text=@"帮助";
        }else if(indexPath.row==3){
            cell.icon_image=[UIImage imageNamed:@"button_aboutus_default.png"];
            cell.label_text=@"关于我们";
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if (indexPath.row == 0){
            ContactUsViewController *vc=[[ContactUsViewController alloc]init];
            NavigationController *nv=[[NavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nv animated:YES completion:nil];
        }else if(indexPath.row == 1){
            SettingViewController *vc=[[SettingViewController alloc]init];
            NavigationController *nv=[[NavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nv animated:YES completion:nil];
        }else if(indexPath.row ==2){
            
        }else if(indexPath.row==3){
            AboutViewController *vc=[[AboutViewController alloc]init];
            NavigationController *nv=[[NavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nv animated:YES completion:nil];
        }
    }
}
@end
