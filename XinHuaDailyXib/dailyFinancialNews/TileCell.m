//
//  TileCell.m
//  XinHuaDailyXib
//
//  Created by apple on 14/10/11.
//
//

#import "TileCell.h"
#import "ALImageView.h"
#import "YLLabel.h"
@implementation TileCell{
    Article *_article;
    UIView *bg_view;
    ALImageView *alImageView;
    UILabel *title;
    YLLabel *summary_label;
    UILabel *keywords_label;
    UILabel *comments_label;
    UILabel *time_label;
    UIImageView *comment_icon;
    
    CGSize keywords_size;
    CGSize image_size;
    CGSize title_size;
    CGSize summary_size;
    
    
}
@synthesize type=_type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bg_view=[[UIView alloc] initWithFrame:CGRectMake(10, 5, 300, 100)];
        bg_view.backgroundColor=[UIColor whiteColor];
        [[self contentView] addSubview:bg_view];
        

        
        alImageView = [[ALImageView alloc] initWithFrame:CGRectMake(10,0 , 320-20 , 180)];
        alImageView.placeholderImage = [UIImage imageNamed:@"placeholder"];
        alImageView.imageURL = @"";
        [bg_view addSubview:alImageView];
        
        time_label = [[UILabel alloc] initWithFrame:CGRectMake(10,180, 90, 20)];
        time_label.backgroundColor = [UIColor clearColor];
        time_label.text = @"";
        time_label.textColor = [UIColor grayColor];
        time_label.font = [UIFont fontWithName:@"Arial" size:15];
        [bg_view addSubview:time_label];
        
        keywords_label = [[UILabel alloc] initWithFrame:CGRectMake(300-5-20-40-150,0 , 150, 20)];
        keywords_label.backgroundColor = [UIColor clearColor];
        keywords_label.text = @"";
        keywords_label.textAlignment=NSTextAlignmentRight;
        keywords_label.textColor = [UIColor grayColor];
        keywords_label.font = [UIFont fontWithName:@"Arial" size:15];
        [bg_view addSubview:keywords_label];
        
        
        
        comments_label = [[UILabel alloc] initWithFrame:CGRectMake(300-5-20-40 ,0,40, 20)];
        comments_label.backgroundColor = [UIColor clearColor];
        comments_label.text = @"";
        comments_label.textColor = [UIColor grayColor];
        comments_label.font = [UIFont fontWithName:@"Arial" size:15];
        comments_label.textAlignment=NSTextAlignmentRight;
        [bg_view addSubview:comments_label];
        comment_icon=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_review_default.png"]];
        comment_icon.frame=CGRectMake(300-5-20, 0, 20, 20);
        [bg_view addSubview:comment_icon];
        title = [[UILabel alloc] initWithFrame:CGRectMake(10,200 , 320-20, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.text = @"";
        title.textColor = [UIColor blackColor];
        title.font = [UIFont fontWithName:@"Arial" size:28];
        title.numberOfLines=2;
        [bg_view addSubview:title];
        summary_label = [[YLLabel alloc] initWithFrame:CGRectMake(10, 220, 320-20, 20)];
        summary_label.backgroundColor = [UIColor clearColor];
        summary_label.font = [UIFont fontWithName:@"Arial" size:22];
        summary_label.textColor=[UIColor grayColor];
        [bg_view addSubview:summary_label];
        self.backgroundColor=[UIColor clearColor];
    }

    self.selectionStyle =UITableViewCellSelectionStyleNone;
    return self;
}
-(Article *)article{
    return _article;
}
-(void)setArticle:(Article *)article{
    if(_article==nil||![_article.article_id isEqualToString:article.article_id]){
        _article=article;
        if(article.key_words.length!=0){
            NSArray *keywords= [article.key_words componentsSeparatedByString:NSLocalizedString(@",", nil)];
            NSMutableString *temp_str=[NSMutableString stringWithFormat:@"[%@]",[keywords componentsJoinedByString:@"]["]];
            [temp_str replaceOccurrencesOfString:@"[]" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, temp_str.length)];
            keywords_label.text=temp_str;
            keywords_size=CGSizeMake(290, 20);
        }else{
            keywords_size=CGSizeMake(0, 0);
        }
        if(self.type==Normal_Date){
            time_label.text=article.publish_date;
        }else if(self.type==Wraped_Date){
            time_label.text=[self wrapedTime:article.publish_date];
        }else{
            time_label.text=@"";
        }
        comments_label.text=[NSString stringWithFormat:@"%d",article.comments_number.intValue];
        title.text=article.article_title;
        title_size= [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(290, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        if(article.summary==nil||[article.summary isEqualToString:@""]){
            summary_label.text=@"";
            summary_size=CGSizeMake(0, 0);
        }else{
            summary_label.text=article.summary;
            summary_size= [article.summary sizeWithFont:summary_label.font constrainedToSize:CGSizeMake(290, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        }
        if(article.cover_image_url==nil&&article.thumbnail_url==nil){
            alImageView.hidden=YES;
            image_size=CGSizeMake(0, 0);
        }else{
            alImageView.hidden=NO;
            image_size=CGSizeMake(300, 180);
            if(article.cover_image_url==nil){
                alImageView.imageURL=article.thumbnail_url;
            }else{
                alImageView.imageURL=article.cover_image_url;
            }
        }
        
        if(image_size.height>0){
            alImageView.frame=CGRectMake(0, 0, image_size.width, image_size.height);
        }else{
            alImageView.frame=CGRectMake(0, 0, 0, 0);
        }
        keywords_label.frame=CGRectMake(100, image_size.height==0?0:image_size.height+5, 150, 20);
        time_label.frame=CGRectMake(10,image_size.height==0?0:image_size.height+5, 90, 20);
        comments_label.frame=CGRectMake(300-5-20-40 ,image_size.height==0?0:image_size.height+5,40, 20);
        comment_icon.frame=CGRectMake(300-5-20, image_size.height==0?0:image_size.height+5, 20, 20);
        if(title_size.height>0){
            title.frame=CGRectMake(5, keywords_label.frame.origin.y+keywords_size.height+5, title_size.width, title_size.height);
        }else{
            title.frame=CGRectMake(5, keywords_label.frame.origin.y+keywords_size.height+5, 0, 0);
        }
        if(summary_size.height>0){
            summary_label.frame=CGRectMake(5, title_size.height==0?title.frame.origin.y:title.frame.origin.y+title_size.height+5, summary_size.width, summary_size.height);
        }else{
            summary_label.frame=CGRectMake(5, title_size.height==0?title.frame.origin.y:title.frame.origin.y+title_size.height+5, 0, 0);
        }
        bg_view.frame=CGRectMake(10, 5, 300, summary_label.frame.origin.y+summary_size.height+5);
       
    }
    bg_view.layer.shadowColor = [UIColor grayColor].CGColor;//shadowColor阴影颜色
    bg_view.layer.shadowOffset = CGSizeMake(0.1,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    bg_view.layer.shadowOpacity = 0.8;//阴影透明度，默认0
}
-(float)preferHeight{
    return bg_view.frame.size.height+10;
}
-(NSString *)wrapedTime:(NSString *)date{
    NSDateFormatter *df=[[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate * d = [df dateFromString:date];
    
    NSTimeInterval late = [d timeIntervalSince1970]*1;
    
    NSString * timeString = nil;
    
    NSDate * dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now = [dat timeIntervalSince1970]*1;
    
    NSTimeInterval cha = now - late;
    if (cha/3600 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        int num= [timeString intValue];
        
        if (num <= 1) {
            
            timeString = [NSString stringWithFormat:@"刚刚"];
            
        }else{
            
            timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
            
        }
        
    }
    
    if (cha/3600 > 1 && cha/86400 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        timeString = [NSString stringWithFormat:@"%@小时前", timeString];
        
    }
    
    if (cha/86400 > 1)
        
    {
        
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        int num = [timeString intValue];
        
        if (num < 2) {
            
            timeString = [NSString stringWithFormat:@"昨天"];
            
        }else if(num == 2){
            
            timeString = [NSString stringWithFormat:@"前天"];
            
        }else if (num > 2 && num <7){
            
            timeString = [NSString stringWithFormat:@"%@天前", timeString];
            
        }else if (num >= 7 && num <= 10) {
            
            timeString = [NSString stringWithFormat:@"1周前"];
            
        }else if(num > 10){
            
            timeString = [NSString stringWithFormat:@"n天前"];
            
        }
        
    }
    return timeString;
}
@end
