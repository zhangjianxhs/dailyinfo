//
//  TagCell.m
//  XinHuaDailyXib
//
//  Created by apple on 14/11/13.
//
//

#import "TagCell.h"
@implementation TagCell{
    NSString *_tag;
    UILabel *tag_lbl;
}
- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        tag_lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0, frameRect.size.width, frameRect.size.height)];
        tag_lbl.backgroundColor = [UIColor clearColor];
        tag_lbl.text = @"";
        tag_lbl.textAlignment=NSTextAlignmentCenter;
        tag_lbl.textColor = [UIColor blackColor];
        tag_lbl.font = [UIFont fontWithName:@"Arial" size:15];
        [[self contentView] addSubview:tag_lbl];
        self.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth=1.0;
    }
    return self;
}
-(NSString *)tag{
    return _tag;
}
-(void)setTag:(NSString *)tag{
    if(_tag==nil||![_tag isEqualToString:tag]){
        _tag=tag;
        tag_lbl.text=tag;
    }
}

@end
