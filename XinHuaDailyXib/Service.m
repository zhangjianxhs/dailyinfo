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
#import "FSManager.h"
#import "URLDefine.h"
#import "DeviceInfo.h"
#import "UserDefaults.h"
#import "Command.h"
#import "UserActions.h"
#import "NetworkLostError.h"
#import "DefaultError.h"
#import "ParserFailedError.h"
#import "BindleLostError.h"
@implementation Service{
    Communicator *_communicator;
    Parser *_parser;
    DBManager *_db_manager;
    FSManager *_fs_manager;
    UserActions *_userActions;
}
@synthesize fs_manager=_fs_manager;
-(id)init{
    if(self=[super init]){
        _communicator=[[Communicator alloc]init];
        _db_manager=[[DBManager alloc] init];
        _fs_manager=[[FSManager alloc] init];
        _parser=[[Parser alloc] init];
        _userActions=[[UserActions alloc]initWithCommunicator:_communicator];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeAcitveHandler)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}
#ifdef DFN
-(void)fetchFirstRunData:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [self fetchChannelsFromNET:^(NSArray *channels) {
        AppDelegate.channel=[self fetchMRCJChannelFromDB];
        [self fetchLatestArticlesFromNETWithChannel:AppDelegate.channel successHandler:^(NSArray *articles) {
            if([articles count]>0){
                if(successBlock){
                    successBlock(YES);
                }
            }else{
                NSError *error;
                if(errorBlock){
                    errorBlock(error);
                }
            }
        } errorHandler:^(NSError *error) {
            if(errorBlock){
                errorBlock(error);
            }
        }];
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

-(void)becomeAcitveHandler{
    if(![self hasAuthorized])return;
    [self reportActionsToServer:^(BOOL ok) {
        //<#code#>
    } errorHandler:^(NSError *error) {
        // <#code#>
    }];
    [self fetchChannelsFromNET:^(NSArray *channels) {
        AppDelegate.channel=[self fetchMRCJChannelFromDB];
        [self fetchLatestArticlesFromNETWithChannel:AppDelegate.channel successHandler:^(NSArray *articles) {
          //  <#code#>
        } errorHandler:^(NSError *error) {
          //  <#code#>
        }];
    } errorHandler:^(NSError *error) {
        //
    }];
}
#endif
#ifdef LNFB
-(void)fetchFirstRunData:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
    } errorHandler:^(NSError *error) {
        //
    }];
}
-(void)becomeAcitveHandler{
    [self reportActionsToServer:^(BOOL ok) {
        //<#code#>
    } errorHandler:^(NSError *error) {
        // <#code#>
    }];
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
    } errorHandler:^(NSError *error) {
        //
    }];
}
#endif
#ifdef Ocean
-(void)fetchFirstRunData:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            if(successBlock){
                successBlock(YES);
            }
        } errorHandler:^(NSError *error) {
            if(errorBlock){
                errorBlock(error);
            }
        }];
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)becomeAcitveHandler{
    [self reportActionsToServer:^(BOOL ok) {
        //<#code#>
    } errorHandler:^(NSError *error) {
        // <#code#>
    }];
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
    } errorHandler:^(NSError *error) {
        //
    }];
}
#endif

#ifdef Money
-(void)fetchFirstRunData:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            if(successBlock){
                successBlock(YES);
            }
        } errorHandler:^(NSError *error) {
            if(errorBlock){
                errorBlock(error);
            }
        }];
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)becomeAcitveHandler{
    [self reportActionsToServer:^(BOOL ok) {
        //<#code#>
    } errorHandler:^(NSError *error) {
        // <#code#>
    }];
    [self fetchChannelsFromNET:^(NSArray *channels) {
        [self fetchHomeArticlesFromNET:^(NSArray *articles) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
    } errorHandler:^(NSError *error) {
        //
    }];
}
#endif

-(void)registerDevice:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kBindleDeviceURL,[DeviceInfo udid],[DeviceInfo phoneModel],[DeviceInfo osVersion],AppID];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OLD"].location!=NSNotFound){
            NSArray *comp=[responseStr componentsSeparatedByString:@":"];
            if([comp count]==2){
                NSLog(@"%@",AppDelegate.user_defaults.sn);
                if([[comp objectAtIndex:1] isEqualToString:AppDelegate.user_defaults.sn]){
                    if(successBlock){
                        successBlock(YES);
                    }
                }else{
                    AppDelegate.user_defaults.sn=@"";
                    if(errorBlock){
                        errorBlock([BindleLostError aError]);
                    }
                }
            }else{
                if(errorBlock){
                    errorBlock([BindleLostError aError]);
                }
            }
            
        }else if([responseStr rangeOfString:@"NEW"].location!=NSNotFound){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(errorBlock){
                errorBlock([DefaultError aErrorWithMessage:[responseStr substringFromIndex:3]]);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)registerPhoneNumberWithPhoneNumber:(NSString *)phone_number verifyCode:(NSString *)verify_code successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kBindleSNURL,phone_number,[DeviceInfo udid],verify_code,[DeviceInfo phoneModel],[DeviceInfo osVersion],AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OK"].location!=NSNotFound){
            AppDelegate.user_defaults.sn=[NSString stringWithFormat:@"%@_%@",AppID,phone_number];
            [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationBindSNSuccess object:nil];
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(errorBlock){
                errorBlock([DefaultError aErrorWithMessage:[responseStr substringFromIndex:3]]);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

-(ChannelsForHVC *)fetchHomeArticlesFromDB{
    ChannelsForHVC *channels_for_hvc=[[ChannelsForHVC alloc] init];
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    NSArray *home_channels=[db_operator fetchHomeChannels];
    for(Channel *channel in home_channels){
       channel.articles=[db_operator fetchArticlesWithChannel:channel exceptArticle:nil topN:channel.home_number];
    }
    Channel *pic_channel=[db_operator fetchPicChannel];
    int topN=(int)fabs(pic_channel.home_number);
    pic_channel.articles=[db_operator fetchArticlesWithChannel:pic_channel exceptArticle:nil topN:topN];
    channels_for_hvc.header_channel=pic_channel;
    channels_for_hvc.other_channels=home_channels;
    return channels_for_hvc;
}
-(void)fetchOceanHomeArticlesFromNETWithAritclesForHVC:(ArticlesForHVC *)aritclesForHVC successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [self registerDevice:^(BOOL isOK) {
        DBOperator *db_operator=[_db_manager theForegroundOperator];
        NSArray *channels=[db_operator fetchAllChannels];
        for(Channel *channel in channels){
            if(!channel.is_leaf)continue;
            if(channel.need_be_authorized&&!AppDelegate.user_defaults.is_authorized)continue;
            int topN=5;//默认下载5条
            if([channel.parent_id isEqualToString:@"-1"])topN=1;//广告下载1条
            NSString *time=[aritclesForHVC lastPublicDateInChannelWithChannelID:channel.channel_id];
            NSString *url=[NSString stringWithFormat:kLatestArticlesURL,[DeviceInfo udid],topN,channel.channel_id,time,AppID];
            [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    DBOperator *db_operator_background=[_db_manager aBackgroundOperator];
                    NSArray *articles=[_parser parseArticles:responseStr];
                    for(Article *article in articles){
                        if(![db_operator_background doesArticleExistWithArtilceID:article.article_id]){
                            [db_operator_background addArticle:article];
                            channel.receive_new_articles_timestamp=[db_operator_background markChannelReceiveNewArticlesTimeStampWithChannelID:channel.channel_id];
                            NSDictionary *dict = [NSDictionary dictionaryWithObject:channel.receive_new_articles_timestamp forKey:@"timestamp"];
                            if(channel.parent_id.intValue>0){
                                [db_operator_background markChannelReceiveNewArticlesTimeStampWithChannelID:channel.parent_id];
                                [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationNewArticlesReceived object: channel.parent_id userInfo:dict];
                            }else{
                                [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationNewArticlesReceived object: channel.channel_id userInfo:dict];
                            }
                        }
                        if(!article.is_cached&&channel.is_auto_cache){
                            [self fetchArticleContentWithArticle:article successHandler:^(BOOL ok){
                                // <#code#>
                                //TODO ssss
                            } errorHandler:^(NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(errorBlock){
                                        errorBlock(error);
                                    }
                                });
                            }];
                        }
                    }
                    [db_operator_background save];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(successBlock){
                            successBlock(articles);
                        }
                    });
                });
            } errorHandler:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(errorBlock){
                        errorBlock(error);
                    }
                });
            }];
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];

}
-(ArticlesForHVC *)fetchOceanHomeArticlesFromDBWithTopN:(int)topN{
    ArticlesForHVC *articles_for_hvc=[[ArticlesForHVC alloc] init];
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    Article *header_article=[db_operator fetchHeaderArticle];
    NSArray *other_articles=[db_operator fetchOtherArticlesWithExceptArticle:header_article topN:topN];
    articles_for_hvc.header_article=header_article;
    articles_for_hvc.other_articles=other_articles;
    return articles_for_hvc;
}
-(void)fetchHomeArticlesFromNET:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    NSArray *channels=[db_operator fetchAllChannels];
    for(Channel *channel in channels){
        if(!channel.is_leaf)continue;
        if(channel.need_be_authorized&&!AppDelegate.user_defaults.is_authorized)continue;
        int topN=5;//默认下载5条
        if([channel.parent_id isEqualToString:@"-1"])topN=1;//广告下载1条
        topN=(int)fabs(channel.home_number);//首页显示几条，下载几条
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *time=[formatter stringFromDate:[NSDate distantFuture]];
        NSString *url=[NSString stringWithFormat:kLatestArticlesURL,[DeviceInfo udid],topN,channel.channel_id,time,AppID];
        [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                DBOperator *db_operator_background=[_db_manager aBackgroundOperator];
                NSArray *articles=[_parser parseArticles:responseStr];
                for(Article *article in articles){
                    if(![db_operator_background doesArticleExistWithArtilceID:article.article_id]){
                        [db_operator_background addArticle:article];
                            channel.receive_new_articles_timestamp=[db_operator_background markChannelReceiveNewArticlesTimeStampWithChannelID:channel.channel_id];
                            NSDictionary *dict = [NSDictionary dictionaryWithObject:channel.receive_new_articles_timestamp forKey:@"timestamp"];
                            if(channel.parent_id.intValue>0){
                                [db_operator_background markChannelReceiveNewArticlesTimeStampWithChannelID:channel.parent_id];
                                [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationNewArticlesReceived object: channel.parent_id userInfo:dict];
                            }else{
                                [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationNewArticlesReceived object: channel.channel_id userInfo:dict];
                            }
                    }
                    if(!article.is_cached&&channel.is_auto_cache){
                        [self fetchArticleContentWithArticle:article successHandler:^(BOOL ok){
                            // <#code#>
                            //TODO ssss
                        } errorHandler:^(NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(errorBlock){
                                    errorBlock(error);
                                }
                            });
                        }];
                    }
                }
                [db_operator_background save];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(successBlock){
                        successBlock(articles);
                    }
                });
            });
        } errorHandler:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(errorBlock){
                    errorBlock(error);
                }
            });
        }];
    }
}

-(void)fetchAppInfo:(void (^)(AppInfo *))successBlock errorHandler:(void (^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kAppInfoURL,[DeviceInfo udid],AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        AppInfo *app_info=[_parser parseAppInfo:responseStr];
        AppDelegate.user_defaults.appInfo=app_info;
        [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationAppVersionReceived object: nil];
        if(app_info.gid!=nil||![app_info.gid isEqualToString:@""]){
            [self fetchOneArticleWithArticleID:app_info.gid successHandler:^(Article *article) {
                [self fetchArticleContentWithArticle:article successHandler:^(BOOL is_ok) {
                    app_info.advPagePath=article.page_path;
                    app_info.advPath=article.zip_path;
                    app_info.startImgUrl=article.cover_image_url;
                    AppDelegate.user_defaults.appInfo=app_info;
                    if(successBlock){
                        successBlock(app_info);
                    }
                } errorHandler:^(NSError *error) {
                    if(errorBlock){
                        errorBlock(error);
                    }
                }];
            } errorHandler:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(errorBlock){
                        errorBlock(error);
                    }
                });
            }];
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchChannelsFromNET:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kChannelsURL,[DeviceInfo udid],AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *channels=[_parser parseChannels:responseStr];
            DBOperator *db_operator=[_db_manager aBackgroundOperator];
//            if([channels count]>0){
//                [db_operator removeAllChannels];
//            }
            for(Channel *channel in channels){
                [db_operator addChannel:channel];
            }
            [db_operator save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationChannelsReceived object: nil];
                if(successBlock){
                    successBlock(channels);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(errorBlock){
                errorBlock(error);
            }
        });
    }];
}
-(void)fetchLatestArticlesFromNETWithChannel:(Channel *)channel successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *time=[formatter stringFromDate:[NSDate distantFuture]];
    [self fetchArticlesFromNETWithChannel:channel time:time successHandler:^(NSArray *articles) {
        [self executeServerCommandsWithChannel:channel successHandler:^(BOOL isOK) {
            if(successBlock){
                successBlock(articles);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationLatestDailyReceived object: nil];
        } errorHandler:^(NSError *error) {
            if(successBlock){
                successBlock(articles);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationLatestDailyReceived object: nil];
        }];
        
    } errorHandler:^(NSError *error){
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchArticlesFromNETWithChannel:(Channel *)channel time:(NSString *)time successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kLatestArticlesURL,[DeviceInfo udid],10,channel.channel_id,time,AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *articles=[_parser parseArticles:responseStr];
            DBOperator *db_operator=[_db_manager aBackgroundOperator];
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

-(void)fetchDailyArticlesFromNETWithChannel:(Channel *)channel date:(NSString *)date successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kDailyArticlesURL,[DeviceInfo udid],channel.channel_id,date,AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *articles=[_parser parseArticles:responseStr];
            DBOperator *db_operator=[_db_manager aBackgroundOperator];
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
-(void)fetchArticleContentWithArticle:(Article *)article successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [_communicator fetchFileAtURL:article.zip_url toPath:article.zip_path successHandler:^(BOOL is_ok) {
        if(is_ok){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            NSError *error;
            if(errorBlock){
                errorBlock(error);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

-(void)fetchCommentsNumberFromNETWith:(Article *)article successHandler:(void(^)(NSNumber *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kCommentsNumberURL,article.article_content_id];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSNumber *comments_number=[NSNumber numberWithInt:[responseStr intValue]];
            article.comments_number=comments_number;
            [self markArticleCommentsNumberWithArticle:article];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    successBlock(comments_number);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchCommentsFromNETWithArticle:(Article *)article time:(NSString *)time successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kCommentListURL,[DeviceInfo udid],AppDelegate.user_defaults.sn,AppID,20,article.article_content_id,time];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *comments=[_parser parseComments:responseStr];
            dispatch_async(dispatch_get_main_queue(), ^{     
                if(successBlock){
                    successBlock(comments);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)fetchLatestCommentsFromNETWithArticle:(Article *)article successHandler:(void(^)(NSArray *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *time=[formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:1000]];
    [self fetchCommentsFromNETWithArticle:article time:time successHandler:^(NSArray *comments) {
        if(successBlock){
            successBlock(comments);
        }
    } errorHandler:^(NSError *error){
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)executeServerCommandsWithChannel:(Channel *)channel successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kCommandsURL,[DeviceInfo udid],channel.channel_id,@"10",AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *commands=[_parser parseCommands:responseStr];
            DBOperator *db_operator=[_db_manager aBackgroundOperator];
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
               // [[FileSystem system] removeArticle:[db_operator fetchArticleWithArticleID:command.f_id]];
            }else if([command.f_state isEqualToString:@"1"]){
                [db_operator updateArticleTimeWithArticleID:command.f_id newTime:command.f_inserttime];
            }
            [db_operator save];
            return YES;
        }else{
            return NO;
        }
}

-(void)reportActionsToServer:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    [_userActions reportActionsToServer:successBlock errorHandler:errorBlock];
}

-(void)fetchOneArticleWithArticleID:(NSString *)articleID successHandler:(void(^)(Article *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kOneArticleURL,articleID,[DeviceInfo udid],AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            Article *article=[_parser parseOneArticle:responseStr];
            DBOperator *db_operator=[_db_manager aBackgroundOperator];
            [db_operator addArticle:article];
            [db_operator save];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    successBlock(article);
                }
            });
        });
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}

//本地
-(NSArray *)fetchFavorArticlesFromDB{
    NSArray *articles=[[_db_manager theForegroundOperator] fetchFavorArticles];
    return articles;
}
-(NSArray *)fetchTrunkChannelsFromDB{
    NSArray * channels=[[_db_manager theForegroundOperator] fetchTrunkChannels];
    NSMutableArray *res=[[NSMutableArray alloc]init];
    for (Channel* ch in channels) {
        [res addObject:ch];
    }
    return res;
}

-(NSDate *)markAccessTimeStampWithChannel:(Channel *)channel{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    NSDate *timestamp=[db_operator markChannelAccessTimeStampWithChannel:channel];
    [db_operator save];
    return timestamp;
}

-(NSArray *)fetchLeafChannelsFromDBWithTrunkChannel:(Channel *)channel{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    return [db_operator fetchLeafChannelsWithTrunkChannel:channel];
}


-(ArticlesForCVC *)fetchArticlesFromDBWithChannel:(Channel *)channel topN:(int)topN{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    Article *header_article=[db_operator fetchHeaderArticleWithChannel:channel];
    NSArray *other_articles=[db_operator fetchArticlesWithChannel:channel exceptArticle:header_article topN:topN];
    ArticlesForCVC *articles_for_cvc=[[ArticlesForCVC alloc]init];
    articles_for_cvc.header_article=header_article;
    articles_for_cvc.other_articles=other_articles;
    return articles_for_cvc;
}
-(DailyArticles *)fetchLatestDailyArticlesFromDBWithChannel:(Channel *)channel{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    NSString *date=[db_operator queryLatestAvailableDateWithChannel:channel];
    if(date.length!=0){
        return [self fetchDailyArticlesFromDBWithChannel:channel date:date];
    }else{
        return nil;
    }
}
-(NSArray *)fetchLatestDailyTagsFromDBWithChannel:(Channel *)channel{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    NSString *date=[db_operator queryLatestAvailableDateWithChannel:channel];
    NSArray *articles=[db_operator fetchDailyArticlesWithChannel:channel date:date];
    NSMutableArray *tags=[[NSMutableArray alloc] init];
    for(Article *article in articles){
        NSArray *keywords= [article.key_words componentsSeparatedByString:NSLocalizedString(@",", nil)];
        for(NSString *tag in keywords){
            BOOL has=NO;
            if([tag isEqualToString:@""])continue;
            for(NSString *item in tags){
                if([item isEqualToString:tag]){
                    has=YES;
                }
            }
            if(!has){
                [tags addObject:tag];
            }
        }
    }
    return tags;
}
-(NSArray *)fetchArticlesFromDBWithTag:(NSString *)tag{
   DBOperator *db_operator=[_db_manager theForegroundOperator];
    return  [db_operator fetchArticlesWithTag:tag];
}
-(DailyArticles *)fetchDailyArticlesFromDBWithChannel:(Channel *)channel date:(NSString *)date{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    DailyArticles *das=[[DailyArticles alloc] init];
    das.date=date;
    das.articles=[db_operator fetchDailyArticlesWithChannel:channel date:date];
    das.previous_date=[db_operator queryPreviousAvailableDateWithChannel:channel date:date];
    das.next_date=[db_operator queryNextAvailableDateWithChannel:channel date:date];
    return das;
}

-(void)markArticleCollectedWithArticle:(Article *)article is_collected:(BOOL)is_collected{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    [db_operator markArticleFavorWithArticleID:article.article_id is_collected:is_collected];
    [db_operator save];
}
-(void)markArticleReadWithArticle:(Article *)article{
    [_userActions enqueueAReadAction:article.article_id];
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    [db_operator markArticleReadWithArticleID:article.article_id];
    [db_operator save];
}
-(void)markArticleLikeWithArticle:(Article *)article{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    [db_operator markArticleLikeWithArticleID:article.article_id likeNumber:article.like_number];
    [db_operator save];
}
-(void)markArticleCommentsNumberWithArticle:(Article *)article{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    [db_operator markArticleCommentsNumberWithArticleID:article.article_id commentsNumber:article.comments_number];
    [db_operator save];
}
-(Article *)fetchADArticleFromDB{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    Channel* channel=[db_operator fetchADChannel];
    NSArray *articles=[db_operator fetchArticlesWithChannel:channel exceptArticle:nil topN:1];
    if([articles count]>0){
        return [articles objectAtIndex:0];
    }else{
        return nil;
    }
}
-(Channel *)fetchMRCJChannelFromDB{
    DBOperator *db_operator=[_db_manager theForegroundOperator];
    return [db_operator fetchMRCJChannel];
}
-(NSArray *)fetchPushArticlesFromDB{
    NSArray *articles=[[_db_manager theForegroundOperator] fetchArticlesThatIsPushed];
    return articles;
}
-(NSArray *)fetchArticlesThatIncludeCoverImage{
    NSArray *articles=[[_db_manager theForegroundOperator] fetchArticlesThatIncludeCoverImage];
    return articles;
}

-(BOOL)hasAuthorized{
    NSLog(@"%@",AppDelegate.user_defaults.sn);
    return AppDelegate.user_defaults.sn.length>0;
}
-(void)likeArticleWithArticle:(Article *)article successHandler:(void(^)(NSString *))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kLikeURL,[DeviceInfo udid],article.article_id,AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if(successBlock){
            successBlock(responseStr);
        }
        
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)shareArticleWithArticle:(Article *)article{
    
}
-(void)feedbackArticleWithContent:(NSString *)content article:(Article *)article successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kCommentURL,[DeviceInfo udid],[NSString stringWithFormat:@"%@_%@",AppID,AppDelegate.user_defaults.sn],article.article_content_id,content,AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OK"].location!=NSNotFound){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(errorBlock){
                errorBlock([DefaultError aErrorWithMessage:[responseStr substringFromIndex:3]]);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)feedbackAppWithContent:(NSString *)content email:(NSString *)email successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kAppFeedBack,[DeviceInfo udid],AppDelegate.user_defaults.sn,email,content,AppID,@"feedback"];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OK"].location!=NSNotFound){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(errorBlock){
                errorBlock([DefaultError aErrorWithMessage:[responseStr substringFromIndex:3]]);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock(error);
        }
    }];
}
-(void)requestVerifyCodeWithPhoneNumber:(NSString *)phone_number successHandler:(void(^)(BOOL))successBlock errorHandler:(void(^)(NSError *))errorBlock{
    NSString *url=[NSString stringWithFormat:kMMSVeriyCodeURL,[DeviceInfo udid],phone_number,AppID];
    [_communicator fetchStringAtURL:url successHandler:^(NSString *responseStr) {
        if([responseStr rangeOfString:@"OK"].location!=NSNotFound){
            if(successBlock){
                successBlock(YES);
            }
        }else{
            if(errorBlock){
                errorBlock([DefaultError aErrorWithMessage:[responseStr substringFromIndex:3]]);
            }
        }
    } errorHandler:^(NSError *error) {
        if(errorBlock){
            errorBlock([NetworkLostError aError]);
        }
    }];
}

@end
