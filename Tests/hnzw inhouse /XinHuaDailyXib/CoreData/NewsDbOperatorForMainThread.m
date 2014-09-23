//
//  NewsDbOperatorForMainThread.m
//  CampusNewsLetter
//
//  Created by apple on 13-1-9.
//
//

#import "NewsDbOperatorForMainThread.h"
#import <CoreData/CoreData.h>
#import "SharedCoordinator.h"
#import "XDailyItem.h"
#import "DailyNews.h"
#import "Favor.h"
#import "Label.h"
#import "NewsChannel.h"

@implementation NewsDbOperatorForMainThread
-(id)init{
    [self managedObjectContext];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChangesForNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    return self;
}
- (void)mergeContextChangesForNotification:(NSNotification *)aNotification
{
     [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:aNotification];
}
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil)
    {
		return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [[SharedCoordinator sharedInstance] persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}
- (BOOL)SaveDb
{
    BOOL result = NO;
    NSError *error;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges])
        {
            result = [managedObjectContext save:&error];
            if(!result)
            {
                // Handle error
                Logger(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
            Logger(@"Youlu SQLLite Saved");
        }
    }
    return YES;
}

-(void)addChannel:(NewsChannel *)item
{
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelID = %@",item.channel_id];
    NSArray* result =  [self  getObjectsByName:LabelName predicate:p limited:1];
    Label *data;
    if (result.count == 1)
    {
        data = [result objectAtIndex:0];
    }
    else
    {
        data = [NSEntityDescription insertNewObjectForEntityForName:LabelName inManagedObjectContext: managedObjectContext];
    }
    data.name = item.title;
    data.level =item.level;
    data.des = item.description;
    data.sub = item.subscribe;
    data.channelID = item.channel_id;
    data.generate = item.generate;
    data.sort = item.sort;
    data.imgPath = item.imgPath;
}
-(NSMutableArray*)allChannels
{
    
    NSArray* result = [self getObjectsByName:LabelName sortKey:@"sort" sortAscending:YES  limited:0];
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    
    for(Label* label in result)
    {
        NewsChannel* channel = [NewsChannel  NewsChannelFromLabel:label];
        [newArray addObject:channel];
    }
    return newArray;
    
    
}
-(NSMutableArray*)ChannelsSubscrib
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"sub > 0"];
    NSArray* result = [self searchObjectsByName:LabelName predicate:p sortKey:@"sort" sortAscending:YES limited:0];
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    
    for(Label* label in result)
    {
        NewsChannel* channel = [NewsChannel  NewsChannelFromLabel:label];
        [newArray addObject:channel];
        NSLog(@"%@",channel.sort);
    }
    return newArray;
}

- (void)addXDailyItem:(XDailyItem*)item
{
    
    NSDate* date = [NSDate dateFromString:item.dateString withFormat:@"yyyy－MM-dd"];
    NSPredicate* p = [NSPredicate predicateWithFormat:@"key = %@",item.key];
    NSArray* result = [self  getObjectsByName:KDailyNewsData predicate:p   limited:1];
    DailyNews* data;
    if (result.count == 1)
    {
        data = [result objectAtIndex:0];
    }
    else
    {
        data = [NSEntityDescription insertNewObjectForEntityForName:@"DailyNews" inManagedObjectContext: managedObjectContext];
        data.date = [NSNumber numberWithInt:[date timeIntervalSince1970]];
        data.read =[NSNumber numberWithBool:item.isRead];
    }
    data.newsDate = item.dateString;
    data.newsTitle = item.title;
    data.pageurl = item.pageurl;
    data.zipurl = item.zipurl;
    data.key = item.key;
    data.channelid = item.channelId;
    data.channeltitle= item.channelTitle;
    data.item_id = item.item_id;
    data.attachments = item.attachments;
    
    
}

- (DailyNews*)dailyNewsByDate:(NSTimeInterval)date
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"date = %f",date];
    NSArray* result = [self getObjectsByName:@"DailyNews" predicate:p limited:1];
    DailyNews* data = nil;
    if (result.count == 1)
    {
        data = [result objectAtIndex:0];
    }
    return data;
    
}
//entityname:表名
//predicate:参数
//sorAscending:排序
//limited:限制记录数量
- (NSArray*)searchObjectsByName: (NSString*)entityName  predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey sortAscending:(BOOL)sortAscending  limited:(NSUInteger)limit
{
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	if (limit > 0)
	{
		[request setFetchLimit:limit];
	}
	
	// If a predicate was passed, pass it to the query
	if(predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
	// If a sort key was passed, use it for sorting.
	if(sortKey != nil)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptors release];
		[sortDescriptor release];
	}
	
	NSError *error;
	
	[request autorelease];
    NSArray* result = [managedObjectContext executeFetchRequest:request error:&error];
    
	return result;
}


- (NSArray *)getObjectsByName: (NSString*)entityName sortKey:(NSString*)sortKey sortAscending:(BOOL)sortAscending limited:(NSUInteger)limit
{
    return [self searchObjectsByName:entityName  predicate:nil sortKey:sortKey sortAscending:sortAscending limited:limit];
    
}
- (NSArray *)getObjectsByName: (NSString*)entityName predicate:(NSPredicate*)predict limited:(NSUInteger)limit
{
    return [self searchObjectsByName:entityName  predicate:predict sortKey:nil sortAscending:NO limited:limit];
}

-(NSMutableArray*)GetNewsByChannelID:(NSString *) channelId
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelid = %@",channelId];
    NSArray*  array = [self searchObjectsByName:@"DailyNews" predicate:p sortKey:@"item_id" sortAscending:NO limited:0];
    NSMutableArray*  newArray =[[[NSMutableArray alloc] init] autorelease];
    for(DailyNews * daily in array)
    {
        XDailyItem * item = [XDailyItem XDailyItemFromDailyNews:daily];
        [newArray addObject:item];
    }
    return newArray;
}
-(NSMutableArray*) GetAllNews
{
    
    
    NSArray* result = [self getObjectsByName: @"DailyNews" sortKey:@"item_id" sortAscending:NO  limited:0];
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    
    for(DailyNews* label in result)
    {
        XDailyItem* channel = [XDailyItem  XDailyItemFromDailyNews:label];
        [newArray addObject:channel];
        
    }
    // [result release];
    return newArray;
    
}

//获取所有Genertypy为0的新闻
-(NSMutableArray*) GetAllNewsExceptImgAndKuaiXun
{
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"generate <> %d",2];
    NSArray* channels= [self getObjectsByName: LabelName predicate:p   limited:0];  
    NSArray* result = [self getObjectsByName: @"DailyNews" sortKey:@"item_id" sortAscending:NO  limited:0];
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    
    for(DailyNews* news in result)
    {
        
        for(Label* label in channels)
        {
            if([news.channelid isEqualToString:label.channelID])
            {
                XDailyItem* channel = [XDailyItem  XDailyItemFromDailyNews:news];
                
                [newArray addObject:channel];
                break;
            }
        }
        
        
    }
    return newArray;
    
}

//获取所有Genertypy为0的新闻
-(NSMutableArray*) GetAllNewsSub
{
    
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"sub > 0 and generate <>2"];
    NSArray* channels= [self getObjectsByName: LabelName predicate:p   limited:0];   
    NSArray* result = [self getObjectsByName: @"DailyNews" sortKey:@"item_id" sortAscending:NO  limited:0];
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    
    for(DailyNews* news in result)
    {
        
        for(Label* label in channels)
        {
            if([news.channelid isEqualToString:label.channelID])
            {
                XDailyItem* channel = [XDailyItem  XDailyItemFromDailyNews:news];
                
                [newArray addObject:channel];
                break;
            }
        }
        
        
    }
    return newArray;
    
}

-(void)ModifyChannelSubscribe:(NSString*) channelid sub:(NSNumber*)sub
{
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelID = %@", channelid];
    NSArray* result = [self getObjectsByName:@"Label" predicate:p limited:1];
    if(result.count==1)
    {
        Label* label = [result objectAtIndex:0];
        label.sub = sub;
    }
}

//修改用户排列顺序
-(void)ModifyChannelCustomOrder:(NSString*) channelid order:(NSNumber*)order{}

-(void)ModifyChannel:(NewsChannel*)channel
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelID = %@",channel.channel_id];
    NSArray* result = [self getObjectsByName:@"Label" predicate:p limited:1];
    if(result.count==1)
    {
        Label* label = [result objectAtIndex:0];
        label.imgPath = channel.imgPath;
        label.sub = channel.subscribe;
    }
    
}
-(void)ModifyDailyNews:(XDailyItem*) daily
{
    NSLog(@"title=%@,isread=%d",daily.key,daily.isRead);
    NSPredicate* p = [NSPredicate predicateWithFormat:@"key = %@",daily.key];
    NSArray* result = [self getObjectsByName:@"DailyNews" predicate:p limited:1];
    //daily.isRead=true;
    if (result.count == 1)
    {
        DailyNews* data = [result objectAtIndex:0];
        
        data.read =  [NSNumber numberWithBool: daily.isRead ];
        
        
        NSLog(@"title=%@,%@",data.key,data.read);
    }
}

-(void)DelAllNews
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"generate <> %d",2];
    NSArray* channels= [self getObjectsByName: LabelName predicate:p   limited:0];
    NSArray* result = [self getObjectsByName: @"DailyNews" sortKey:@"item_id" sortAscending:NO  limited:0];
    for(DailyNews* news in result)
    {
        
        for(Label* label in channels)
        {
            if([news.channelid isEqualToString:label.channelID])
            {
                [managedObjectContext deleteObject:news];
            }
        }
        
        
    }
    
    
}

-(NSArray*)GetNewsByLastDaysNumber:(int) dayCount
{
    NSMutableArray*  newArray = [[[NSMutableArray alloc] init] autorelease];
    NSTimeInterval secondsPerDay = 24 * 60 * 60 * dayCount;
    
    
    NSDate *dayago = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    
    NSNumber* number = [NSNumber numberWithInt:[dayago timeIntervalSince1970]];
    [dayago release];
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"newsDate < %@", number];
    
    NSArray* result = [self getObjectsByName: @"DailyNews" predicate:p   limited:0];
    for(DailyNews* label in result)
    {
        XDailyItem* channel = [XDailyItem  XDailyItemFromDailyNews:label];
        [newArray addObject:channel];
        
    }
    return newArray;
}
-(void)DelNewsByLastDaysNumber:(int) dayCount
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60 * dayCount;
    
    
    NSDate *dayago = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    
    NSNumber* number = [NSNumber numberWithInt:[dayago timeIntervalSince1970]];
    [dayago release];
    NSPredicate* p = [NSPredicate predicateWithFormat:@"newsDate < %@", number];
    
    NSArray* result = [self getObjectsByName: @"DailyNews" predicate:p   limited:0];
    for (id basket in result)
        [managedObjectContext deleteObject:basket];
    
    
}

-(int)GetUnReadCountByChannelId:(NSString*) channelID
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"read = %d and channelid = %@",NO,channelID];
    NSArray*  array = [self searchObjectsByName:@"DailyNews" predicate:p sortKey:@"item_id" sortAscending:NO limited:0];
    return [array count];   
}
-(int)GetUnReadCount
{
    
    NSPredicate* p1 = [NSPredicate predicateWithFormat:@"sub > 0 and generate <> %d",2];
    
    NSArray* channels= [self getObjectsByName: LabelName predicate:p1   limited:0];
    if (!channels ||[channels count]==0) {
        return 0;
    }
    int result=0;
    for (Label* channel in channels) {
        int newsCountOfChannel = [self GetUnReadCountByChannelId:channel.channelID];
        result+=newsCountOfChannel;
    }
    return result;    
}
-(NSMutableArray*)GetImgNews
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"generate = %d",2];
    NSArray* channel= [self getObjectsByName: LabelName predicate:p   limited:1];
    NSMutableArray* result =  [[[NSMutableArray alloc] init] autorelease];
    if(channel.count==1)
    {
        Label* channlImg= [channel objectAtIndex:0];
        NSString* channleid =  channlImg.channelID;
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"channelid = %@",channleid];
        NSArray* newss = [self searchObjectsByName:@"DailyNews" predicate:p2 sortKey:@"item_id" sortAscending:NO limited:5];
        
        for(DailyNews* news in newss)
        {
            XDailyItem* item = [XDailyItem XDailyItemFromDailyNews:news];
            [result addObject:item];
        }
        
        return result;
    }
    return nil;
}

-(NSMutableArray*)GetKuaiXun

{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"generate = %d",1];
    NSArray* channel= [self getObjectsByName: LabelName predicate:p   limited:1];
    NSMutableArray* result =  [[[NSMutableArray alloc] init] autorelease];
    if(channel.count==1)
    {
        Label* channlImg= [channel objectAtIndex:0];
        NSString* channleid =  channlImg.channelID;
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"channelid = %@",channleid];
        NSArray* newss = [self searchObjectsByName:@"DailyNews" predicate:p2 sortKey:@"item_id" sortAscending:NO limited:5];
        
        for(DailyNews* news in newss)
        {
            XDailyItem* item = [XDailyItem XDailyItemFromDailyNews:news];
            [result addObject:item];
        }
        
        return result;
    }
    return nil;
}
-(BOOL)IsNewsInDb:(XDailyItem*) news
{
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"item_id = %d",news.item_id.intValue];
    NSArray* result = [self  getObjectsByName:KDailyNewsData predicate:p   limited:1];
    
    if (result.count == 1)
    {
        return true;
    }
    return false;
}
-(XDailyItem*)GetXdailyByItemId:(NSNumber*) itemid
{
    NSLog(@"GetXdailyByItemId %d",itemid.intValue);
    NSPredicate* p = [NSPredicate predicateWithFormat:@"item_id = %d", itemid.intValue];
    NSArray* result = [self  getObjectsByName:KDailyNewsData predicate:p   limited:1];
    
    if (result.count == 1)
    {
        return [XDailyItem XDailyItemFromDailyNews: [result objectAtIndex:0]];
    }
    return nil;
    
}

-(void)DelChannelByChannelID:(NSString*) channelID
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelID = %@", channelID];
    NSArray* result = [self getObjectsByName:LabelName predicate:p limited:1];
    if(result.count==1)
    {
        [managedObjectContext deleteObject:[result objectAtIndex:0] ];
    }
}
-(NSMutableArray*)DelNewsByRetainCount:(int) count
{
    NSArray* array = [self allChannels];
    NSMutableArray* itemsToDelete = [[[NSMutableArray alloc] init] autorelease];
    if(!array||array.count==0) return nil;
    for (NewsChannel* channel in array)
    {
        
        int countlocal =  [self GetCountByChannelId:channel.channel_id];
        if (countlocal<=count||countlocal==0)
        {
            continue;
        }
        else
        {
            int delcount = countlocal - count;
            
            
            NSPredicate* p = [NSPredicate predicateWithFormat:@"channelid = %@",channel.channel_id];
            NSArray*  newss = [self searchObjectsByName:@"DailyNews" predicate:p sortKey:@"item_id" sortAscending:YES limited:0];
            NSLog(@"%d",delcount);
            for (int i =0; i<delcount; i++)
            {
                [itemsToDelete addObject: [XDailyItem XDailyItemFromDailyNews: [newss objectAtIndex:i]]];
                [managedObjectContext deleteObject:[newss objectAtIndex:i]];
            }
        }
        
        
    }
    return itemsToDelete;
    
}

-(int)GetCountByChannelId:(NSString*) channelID
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"channelid = %@",channelID];
    NSArray*  array = [self searchObjectsByName:@"DailyNews" predicate:p sortKey:@"item_id" sortAscending:NO limited:0];
    return [array count];
}

@end