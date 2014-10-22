//
//  ChannelViewController.m
//  XinHuaDailyXib
//
//  Created by apple on 14/10/14.
//
//

#import "ChannelViewController.h"
#import "AuthorizationTouchView.h"
#import "NavigationController.h"
#import "RegisterViewController.h"
#import "Service.h"
@interface ChannelViewController ()
@property(nonatomic,strong)AuthorizationTouchView *authorization_cover_view;
@end

@implementation ChannelViewController
@synthesize channel=_channel;
@synthesize authorization_cover_view=_authorization_cover_view;
@synthesize service=_service;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=self.channel.channel_name;
    [self buildUI];
    _authorization_cover_view=[[AuthorizationTouchView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _authorization_cover_view.delegate=self;
    [self.view addSubview:_authorization_cover_view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCoverView) name:@"" object:nil];
    if(_channel.need_be_authorized){
        if([self.service hasAuthorized]){
            [_authorization_cover_view hide];
        }else{
            [_authorization_cover_view show];
        }
    }

    [((NavigationController *)self.navigationController) setLeftButtonWithImage:[UIImage imageNamed:@"title_menu_btn_normal.png"] target:self action:@selector(showLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    [((NavigationController *)self.navigationController) setRightButtonWithImage:[UIImage imageNamed:@"nav_func.png"] target:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showLeftMenu{
    [AppDelegate.main_vc toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)showMenu{
    [AppDelegate.main_vc toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

-(void)buildUI{
    
}
-(BOOL)authorize{
    return [_service authorize];
}
-(void)removeCoverView{
    [_authorization_cover_view hide];
}
-(void)touchViewClicked{
    [self pushRegisterVC];
}
-(void)pushRegisterVC{
    RegisterViewController *vc=[[RegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
