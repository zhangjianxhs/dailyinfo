//
//  FileSystem.h
//  XinHuaDailyXib
//
//  Created by 刘 静 on 14-10-12.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
@interface FileSystem : NSObject
+(FileSystem *)system;
-(void)removeArticle:(Article *)article;
@end