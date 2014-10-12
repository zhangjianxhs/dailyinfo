//
//  Service.m
//  XinHuaDailyXib
//
//  Created by apple on 14/10/8.
//
//

#import "Service.h"
#import "Communicator.h"
#import "Parser.h"
#import "DBManager.h"
#import "DBOperator.h"
#import "URLDefine.h"
#import "DeviceInfo.h"
#import "UserDefaults.h"
#import "NotificationCenter.h"
#import "FileSystem.h"
#import "Command.h"
@implementation Service{
    Communicator *_communicator;
    Parser *_parser;
    DBManager *_db_manager;
}
-(id)init{
    if(self=[super init]){
        _communicator=[[Communicator alloc]init];
        _db_manager=[[DBManager alloc] init];
        _parser=[[Parser alloc] init];
    }
    return self;
}
-(void)registerDevice:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kBindleDeviceURL,[DeviceInfo udid],[DeviceInfo phoneModel],[DeviceInfo osVersion]];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OLD"].location!=NSNotFound){
            if(responseStr.length>3){
                NSString *snStr=[responseStr substringFromIndex:4];
                [UserDefaults defaults].sn=snStr;
            }
            if(successBlock){
                successBlock(YES);
            }
        }else if([responseStr rangeOfString:@"NEW"].location!=NSNotFound){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(successBlock){
                successBlock(NO);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)registerSNWithSN:(NSString *)SN successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *tempURL=[NSString stringWithFormat:kBindleSNURL,[DeviceInfo udid],SN,[DeviceInfo osVersion]];
    NSString *url=[tempURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"SUCCESSED"].location!=NSNotFound){
            [UserDefaults defaults].sn=SN;
            if(successBlock){
                successBlock(YES);
            }
        }else{
            [[NotificationCenter center] postMessageNotificationWithMessage:responseStr];
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchAppInfo:(void (^)(AppInfo *))successBlock errorHandler:(void (^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kAppInfoURL,[DeviceInfo udid]];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        AppInfo *app_info=[_parser parseAppInfo:responseStr];
        [UserDefaults defaults].appInfo=app_info;
        if(successBlock){
            successBlock(app_info);
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchChannelsFromNET:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kChannelsURL,[DeviceInfo udid]];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *channels=[_parser parseChannels:responseStr];
            DBOperator *db_operator=[_db_manager aOperator];
            if([channels count]>0){
                [db_operator removeAllChannels];
            }
            for(Channel *channel in channels){
                [db_operator addChannel:channel];
            }
            [db_operator save];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    successBlock(channels);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchArticlesFromNETWithChannel:(Channel *)channel successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kLatestArticlesURL,[DeviceInfo udid],10,channel.channel_id];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *articles=[_parser parseArticles:responseStr];
            DBOperator *db_operator=[_db_manager aOperator];
            for(Article *article in articles){
                [db_operator addArticle:article];
            }
            [db_operator save];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    successBlock(articles);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}



-(void)executeServerCommands:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kCommandsURL,[DeviceInfo udid]];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *commands=[_parser parseCommands:responseStr];
            DBOperator *db_operator=[_db_manager aOperator];
            BOOL modified=NO;
            for(Command *command in commands){
                if([self executeCommand:command db_operator:db_operator]){
                    modified=YES;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    successBlock(modified);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(BOOL)executeCommand:(Command *)command db_operator:(DBOperator *)db_operator{
        if([db_operator doesArticleExistWithArtilceID:command.f_id]){
            if([command.f_state isEqualToString:@"2"]){
                [db_operator deleteArticleWithArticleID:command.f_id];
                [[FileSystem system] removeArticle:[db_operator fetchArticleWithArticleID:command.f_id]];
            }else if([command.f_state isEqualToString:@"1"]){
                [db_operator updateArticleTimeWithArticleID:command.f_id newTime:command.f_inserttime];
            }
            [db_operator save];
            return YES;
        }else{
            return NO;
        }
}
-(void)fetchArticlesForHomeVC:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    
}
-(void)reportUserActions:(NSString *)postJSON succcessHander:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=kUserActionsURL;
    NSDictionary *variables=[NSDictionary dictionaryWithObject:postJSON forKey:@"json"];
    [_communicator postVariablesToURL:url variables:variables successHandler:^(NSString *responseStr) {
        if(successBlock){
            if([responseStr rangeOfString:@"SUCCESS"].location!=NSNotFound){
                successBlock(YES);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

-(void)fetchOneArticleWithArticleID:(NSString *)articleID successHandler:(void(^)(Article *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kOneArticleURL,articleID,[DeviceInfo udid]];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        Article *article=[_parser parseOneArticle:responseStr];
        DBOperator *db_operator=[_db_manager aOperator];
        [db_operator addArticle:article];
        [db_operator save];
        if(successBlock){
            successBlock(article);
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

//本地
-(NSArray *)fetchFavorArticlesFromDB{
    NSArray *articles=[[_db_manager aOperator] fetchFavorArticles];
    return articles;
}
-(NSArray *)fetchTrunkChannelsFromDB{
    NSArray * channels=[[_db_manager aOperator] fetchTrunkChannels];
    NSMutableArray *res=[[NSMutableArray alloc]init];
    for (Channel* ch in channels) {
        [res addObject:ch];
    }
    return res;
}
-(NSArray *)fetchLeafChannelsFromDBWithTrunkChannel:(Channel *)channel{
    
}
-(NSArray *)fetchArticlesFromDBWithChannel:(Channel *)channel topN:(int)topN{
    NSArray *articles=[[_db_manager aOperator] fetchMutiCoverImageArticlesWithChannel:channel topN:2];
    NSMutableArray *array_ids=[[NSMutableArray alloc] init];
    for(KidsArticle *article in articles){
        [array_ids addObject:article.article_id];
    }
    if(exceptArticleID!=nil&&![exceptArticleID isEqual:@""]){
        [array_ids insertObject:exceptArticleID atIndex:0];
    }
    NSArray * articles_only_thumail=[[_db_manager aOperator] fetchArticlesWithChannel:channel exceptArticleID:array_ids topN:topN];
    NSMutableArray *res=[[NSMutableArray alloc] init];
    [res addObjectsFromArray:articles_only_thumail];
    if(articles!=nil&&[articles count]>0){
        if([res count]>=5)
            [res insertObject:articles[0] atIndex:5];
        else
            [res addObject:articles[0]];
    }
    if(articles!=nil&&[articles count]>1){
        if([res count]>=10)
            [res insertObject:articles[1] atIndex:10];
        else
            [res addObject:articles[1]];
        
    }
    return res;
}
-(void)markArticleFavorInDB:(Article *)article favor:(BOOL)favor{
    if(favor){
        [[UserActionsController sharedInstance] enqueueACollecionAction:article];
    }
    DBOperator *db_operator=[_db_manager aOperator];
    [db_operator markArticleFavorWithArticleID:article.article_id favor:favor];
    [db_operator save];
}
-(void)markArticleReadWithArticleInDB:(Article *)article{
    [[UserActionsController sharedInstance] enqueueAReadAction:article];
    KidsDBOperator *db_operator=[_db_manager aOperator];
    [db_operator markArticleReadWithArticleID:article.article_id];
    [db_operator save];
}
-(Article *)fetchADArticleFromDB{
    DBOperator *db_operator=[_db_manager aOperator];
    Channel* channel=[db_operator fetchADInContentChannel];
    NSArray *articles=[db_operator fetchArticlesWithChannel:channel exceptArticle:nil topN:1];
    if([articles count]>0){
        return [articles objectAtIndex:0];
    }else{
        return nil;
    }
}
-(NSArray *)fetchPushArticlesFromDB{
    KidsChannel* channel=[[_db_manager aOperator] fetchNotificationChannel];
    return channel;
}

//配置

@end
