//
//  RemotePeriodicalSource.m
//  XinHuaDailyXib
//
//  Created by apple on 13-8-14.
//
//

#import "RemotePeriodicalSource.h"
#import "XDailyItem.h"
@implementation RemotePeriodicalSource
NSString *baseURL;
-(NSURL *)makeURLwith:(id)item{
    NSString* path_url = [((XDailyItem *)item).zipurl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSString* url=[((XDailyItem *)item).pageurl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSString* filename=[url lastPathComponent];
    NSString* dirName = [path_url lastPathComponent];
    NSString* filePath =[[CommonMethod fileWithDocumentsPath:dirName] stringByDeletingPathExtension];
    NSString* urlStr=[NSString stringWithFormat:@"%@/%@",[filePath stringByDeletingPathExtension],filename];
    return  [NSURL URLWithString:[baseURL stringByAppendingString:urlStr]];
}
@end