//
//  KidsContentViewController.h
//  kidsgarden
//
//  Created by apple on 14/6/10.
//  Copyright (c) 2014年 ikid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge_iOS.h"
#import "Service.h"
#import "WaitingView.h"
#import "PopupMenuView.h"
#import "ZSYPopoverListView.h"
#import "RefreshTouchView.h"
#import "ArticleViewDelegate.h"
@interface ArticleViewController : UIViewController<UIWebViewDelegate,FontAlertDelegate,TouchViewDelegate>
- (id)initWithAritcle:(Article *)article;
-(id)initWithPushArticleID:(NSString *)articleID;
@end
