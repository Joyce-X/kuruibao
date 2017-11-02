//
//  XMFMView.m
//  kuruibao
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMFMView.h"
#import "XMColumn_x.h"
#import "XMCustomItemView.h"
#import "UIImageView+WebCache.h"
#import "NSString+extention.h"
#define lineMargin 40

#define itemMargin 10

@interface XMFMView ()<UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *itemViews;//!< save itemView

@property (weak, nonatomic) UIScrollView *scroll;

@property (weak, nonatomic) UILabel *itemNameLabel;//!< show the item name

@property (weak, nonatomic) UIView *backView;//!< slider backView

@property (weak, nonatomic) UIImageView *playImageView;//!< show play image

@property (weak, nonatomic) UIButton *playBtn;

@property (weak, nonatomic) UILabel *nameLabel;//!< show detail view

@property (weak, nonatomic) UIButton *resetBtn;

@property (copy, nonatomic) NSString *recordTitle; //!< record last click title

//@property (weak, nonatomic) UIButton *playBtn;//!< play button

@end


@implementation XMFMView


-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        [self setSubViews];
        
    }
    
    return self;

}


#pragma mark ------- setSubviews

- (void)setSubViews
{
    

    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add refresh button
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [refreshBtn setImage:[UIImage imageNamed:@"carLife_refresh"] forState:UIControlStateNormal];
    
    [refreshBtn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:refreshBtn];
    
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self).offset(-16);
        
        make.top.equalTo(self).offset(6);
        
        make.size.equalTo(CGSizeMake(30, 30));
        
    }];
    
    
    
    //!< reset  Btn
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    resetBtn.clipsToBounds = YES;
    
    resetBtn.frame = CGRectMake(20, 0, 260, 45);
    
    [self addSubview:resetBtn];
    
    self.resetBtn = resetBtn;

    
    UILabel *nameLabel = [UILabel new];
    
    nameLabel.textColor = [UIColor whiteColor];
    
    nameLabel.font = [UIFont systemFontOfSize:16];
    
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    nameLabel.frame = CGRectMake(0, 0, 260, 45);
    
     [resetBtn addSubview:nameLabel];

    self.nameLabel = nameLabel;
    
    self.resetBtn = resetBtn;
    
    resetBtn.hidden = YES;
    
   
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add scroll
    UIScrollView *scroll = [[UIScrollView alloc]init];
    
    scroll.delegate = self;
    
    scroll.showsVerticalScrollIndicator = NO;
    
    scroll.showsHorizontalScrollIndicator = NO;
    
    scroll.pagingEnabled = YES;
    
    scroll.contentSize = CGSizeMake(mainSize.width * 2, 0);
    
    [self addSubview: scroll];
    
    self.scroll = scroll;
    
    CGFloat itemW = (mainSize.width-60)/3;
    
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self);
        
        make.right.equalTo(self);
        
        make.top.equalTo(self).offset(45);
        
        make.height.equalTo(itemW);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add line
    UIImageView *line = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_line"]];
    
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self);
        
        make.height.equalTo(1);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add customView
    XMCustomItemView *tem = nil;
    
    __weak typeof(self) wself = self;
    
    CGFloat view_W = itemW;
    
    
    for (int i = 0; i < 6; i++)
    {
        
        XMCustomItemView *itemView = [XMCustomItemView new];
        
        itemView.tag = i;
        
        [self.itemViews addObject:itemView];
        
        itemView.completion = ^(XMCustomItemView *view)
        {
        
            [wself itemViewDidClick:view];
        
        };
        
        [scroll addSubview:itemView];
        
        if (tem == nil)
        {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(scroll).offset(20);
                
                make.top.equalTo(scroll);
                
                make.size.equalTo(CGSizeMake(view_W, view_W));
                
                
            }];
            
        }else
        {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                

                make.left.equalTo(tem.mas_right).offset(i == 3 ? 40 : 10);
                
                make.top.equalTo(tem);
                
                make.size.equalTo(CGSizeMake(view_W, view_W));
                
                
            }];
        
        }
        
        tem = itemView;
       
     }
    
    //-----------------------------seperate line----------www.Joyce.com-------------------------//
    
    //!< add play view
    UIImageView *backView = [UIImageView new];
    
    backView.image = [UIImage imageNamed:@"background_bottom"];
    
    backView.userInteractionEnabled = YES;
    
    [self addSubview:backView];
    
    _backView = backView;
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self);
        
        make.top.equalTo(self).offset(1);
        
        make.bottom.equalTo(self).offset(-2);
        
    }];
    
    
    //!< backBtn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_backBtnImage"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    [backView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(20);
        
        make.top.equalTo(backView).offset(11);
        
        make.size.equalTo(CGSizeMake(30, 30));
        
     }];
    
    //!< imageView
    
    UIImageView *circleVimageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carlife_circle"]];
    
    [backView addSubview:circleVimageView];
    
    if (mainSize.width == 320)
    {
        [circleVimageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(backView).offset(40);
            
            make.top.equalTo(backView).offset(45);
            
            //        make.centerY.equalTo(backView.mas_centerY);
            
            make.size.equalTo(CGSizeMake(80, 80));
            
            
        }];
        
    }else
    {
        [circleVimageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(backView).offset(48);
            
            make.top.equalTo(backView).offset(32);
            
            //        make.centerY.equalTo(backView.mas_centerY);
            
            make.size.equalTo(CGSizeMake(116, 116));
            
            
        }];
    
    }
    
    UIImageView *playImageView = [UIImageView new];
    
    playImageView.image = [UIImage imageNamed:@"cirLIfe_placeholder"];
    
    [backView addSubview:playImageView];
    
    _playImageView = playImageView;
    
    playImageView.clipsToBounds = YES;
    
    playImageView.layer.cornerRadius = 33;
    
    [playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(circleVimageView);
        
        make.width.height.equalTo(66);
        
    }];
    
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    anima.duration = 7;
    
    anima.removedOnCompletion = NO;
    
    anima.repeatCount = MAXFLOAT;
    
    anima.toValue = @(M_PI *2);
    
    NSString *key = @"animation";
    
    [playImageView.layer addAnimation:anima forKey:key];
    
    
    //!< add play button
    
    //!< next
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nextBtn setImage:[UIImage imageNamed:@"cirLIfe_next"] forState:UIControlStateNormal];
    
    nextBtn.tag = 3;
    
    [nextBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:nextBtn];
    
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(backView).offset(-15);
        
        make.top.equalTo(backView).offset(65);
        
        make.size.equalTo(CGSizeMake(37, 37));
        
    }];
    
    //!< paly/pause
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [playBtn setImage:[UIImage imageNamed:@"cirLIfe_pause"] forState:UIControlStateNormal];
    
    [playBtn setImage:[UIImage imageNamed:@"cirLIfe_play"] forState:UIControlStateSelected];
    
    playBtn.tag = 2;
    
    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:playBtn];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(nextBtn.mas_left).offset(-32);
        
        make.top.equalTo(nextBtn);
        
        make.size.equalTo(CGSizeMake(37, 37));
        
    }];
    
    self.playBtn = playBtn;
    
    //!< last
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [lastBtn setImage:[UIImage imageNamed:@"cirLIfe_last"] forState:UIControlStateNormal];
    
    lastBtn.tag = 1;
    
    [lastBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:lastBtn];
    
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(playBtn.mas_left).offset(-32);
        
        make.bottom.equalTo(nextBtn);
        
        make.size.equalTo(CGSizeMake(37, 37));
        
        
        
    }];
    
    
 
    backView.transform = CGAffineTransformMakeTranslation(mainSize.width, 0);
    
    backView.alpha = 0;
    
    //!< add gestureRecognizer
    UISwipeGestureRecognizer *swip_back = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backgesture)];
    
    swip_back.direction = UISwipeGestureRecognizerDirectionRight;
    
    [backView addGestureRecognizer:swip_back];
    
    //-----------------------------seperate line-------wwwwww----------------------------//
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add gestureRecognizer
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipTrigger:)];
    
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:swip];
    
    
    UISwipeGestureRecognizer *swipL = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipLTrigger:)];
    
    swipL.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self addGestureRecognizer:swipL];
    
}


- (void)showPlayView
{
    
    if (_backView.alpha == 1)
    {
        return;
    }
    
    //!< show paly view
    _backView.alpha = 0;
    
    [UIView animateWithDuration:.5 animations:^{
        
        _backView.transform = CGAffineTransformIdentity;
        
        _backView.alpha = 1;
        
        
    }];
    

}

- (void)stopPlay
{

    [self playBtnClick:self.playBtn];

}



#pragma mark ------- lazy

- (NSMutableArray *)itemViews
{
    if (!_itemViews)
    {
        _itemViews = [NSMutableArray array];
    }
    
    return _itemViews;
    
}


#pragma mark ------- setter

- (void)setItems:(NSArray *)items
{
    
    _items = items;
    
    if (self.scroll)
    {
        [_scroll setContentOffset:CGPointZero animated:YES];
    }

    for (int i = 0; i < 6; i++)
    {
        XMCustomItemView *view = _itemViews[i];
        
        XMColumn_x *model = items[i];
        
        view.title = model.column_title;
        
        [view.imageView sd_setImageWithURL:[NSURL URLWithString:model.cover_url_small] placeholderImage:[UIImage imageNamed:@"cirLIfe_placeholder"]];
    }
    
 
}

- (void)setTrack:(XMTrack *)track
{
    _track = track;
    
    [_playImageView sd_setImageWithURL:[NSURL URLWithString:track.coverUrlSmall] placeholderImage:[UIImage imageNamed:@"cirLIfe_placeholder"]];
 
    
    NSString *title = track.trackIntro;
    
    if (title.length == 0 || title.length == NSNotFound)
    {
        title = @"正在播放的专辑";
    }
    
    _nameLabel.text = title;
    
   
    
    CGFloat width = [_nameLabel.text getWidthWith:15];
    
    CGFloat width_btn = CGRectGetWidth(_resetBtn.frame);

    
    [_nameLabel.layer removeAnimationForKey:@"nameLabel"];
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"position"];
    
    anima.duration = 10;
    
    anima.removedOnCompletion = NO;
    
    anima.repeatCount = MAXFLOAT;
    
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(width/2 + 230 ,22.5)];
    
    anima.toValue = [NSValue valueWithCGPoint:CGPointMake(- width/2,22.5)];
    
    [_nameLabel.layer addAnimation:anima forKey:@"nameLabel"];
    

}

#pragma mark ------- btn click
 
- (void)resetBtnClick:(UIButton *)sender
{
    
    //!< hide btn , show play view
 
    [UIView animateWithDuration:.3 animations:^{
        
       self.backView.transform = CGAffineTransformIdentity;
        
         self.backView.alpha = 1;
    }];
    
    
    sender.hidden = YES;
    
   
}


// back gesturerecgnizer
- (void)backgesture
{

    [self backBtnClick];

}

//!< refresh btn click
- (void)refreshBtnClick:(UIButton *)sender
{
    XMLOG(@"refresh btn click");
    
    //!< invoke delegate to update
    if (self.delegate && [self.delegate respondsToSelector:@selector(fmViewShouldRefreshItem:)])
    {
        [self.delegate fmViewShouldRefreshItem:self];
    }
    
}


//!< itemView click
- (void)itemViewDidClick:(XMCustomItemView *)view
{
    
    XMLOG(@"itemView Click tag=%d",(int)view.tag);
    
    
    
    if ([self.recordTitle isEqualToString:view.title])
    {
        [self showPlayView];
        
        return;
        
        
        
    }
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(fmView:itemClick:)])
    {
    
        [self.delegate fmView:self itemClick:view];
    
        self.recordTitle = view.title;
    
    }
    
    
    
}

//!< click back btn , slider to right
- (void)backBtnClick
{
    XMLOG(@"backBtnClick");
    
    //!< hide the backView
    [UIView animateWithDuration:.3 animations:^{
        
        _backView.transform = CGAffineTransformMakeTranslation(mainSize.width, 0);
   
        _backView.alpha = 0;
        
        
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            
            _resetBtn.hidden = NO;
            
        }];
    });
}


//!< play button click
- (void)playBtnClick:(UIButton *)sender
{
    //!< tag: 1 - last  2 - play/pause  3 - next
    
    switch (sender.tag)
    {
        case 1:
            //!< last
            if (self.delegate && [self.delegate respondsToSelector:@selector(fmViewDidClickLastItem)])
            {
                [self.delegate fmViewDidClickLastItem];
            }
            
            _playBtn.selected = NO;
            
             [self addAnimation];
            
            break;
            
        case 2:
            //!< play/pause
            
            if(sender.selected)
            {
                CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                
                anima.duration = 7;
                
                anima.removedOnCompletion = YES;
                
                anima.repeatCount = MAXFLOAT;
                
                anima.toValue = @(M_PI *2);
                
                NSString *key = @"animation";
                
                [_playImageView.layer addAnimation:anima forKey:key];
            
            }else
            {
            
                [_playImageView.layer removeAnimationForKey:@"animation"];
              
            }
            
            sender.selected = !sender.selected;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(fmViewDidClickPlayButton:)])
            {
                
                [self.delegate fmViewDidClickPlayButton:!sender.selected];
                
            }
            
            break;
            
        case 3:
            //!< next
            if (self.delegate && [self.delegate respondsToSelector:@selector(fmViewDidClickNextItem)])
            {
                [self.delegate fmViewDidClickNextItem];
            }
            
            [self addAnimation];
            
            _playBtn.selected = NO;
            
            break;
            
        default:
            break;
    }
    
    
}


- (void)addAnimation
{
    [_playImageView.layer removeAnimationForKey:@"animation"];
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    anima.duration = 7;
    
    anima.removedOnCompletion = NO;
    
    anima.repeatCount = MAXFLOAT;
    
    anima.toValue = @(M_PI *2);
    
    NSString *key = @"animation";
    
    [_playImageView.layer addAnimation:anima forKey:key];

    
    
}



#pragma mark ------- swip gestureRecognizer

//!< right gestureRecgnizer
- (void)swipTrigger:(UISwipeGestureRecognizer *)sender
{
    
        //!< scroll to right
        if (_scroll.contentOffset.x == mainSize.width)
        {
            [_scroll setContentOffset:CGPointZero animated:YES];
            
            
        }else
        {
        
            return;
            
        }
    
}


//!< left gesturerecgnizer
- (void)swipLTrigger:(UISwipeGestureRecognizer *)sender
{
    
    //!< scroll to left
    if (_scroll.contentOffset.x == mainSize.width)
    {
        return;
        
    }else
    {
        
        [_scroll setContentOffset:CGPointMake(mainSize.width, 0) animated:YES];
        
    }

}

#pragma mark ------- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

//    XMLOG(@"***%f",scrollView.contentOffset.x);
    
    if (scrollView.contentOffset.x > 430)
    {
        
 
        
        [scrollView setContentOffset:CGPointMake(430, 0) animated:NO];
 
    }else if (scrollView.contentOffset.x < - 60)
    {
        
        [scrollView setContentOffset:CGPointMake(-60, 0) animated:NO];
        

        
    }


}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{

    if (scrollView.contentOffset.x >= 430)
    {
        [scrollView setContentOffset:CGPointMake(375, 0) animated:YES];
        
    }
    
    if (scrollView.contentOffset.x <= - 60)
    {
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    if (scrollView.contentOffset.x >= 430)
    {
        [scrollView setContentOffset:CGPointMake(375, 0) animated:YES];
        
    }
    
    if (scrollView.contentOffset.x <= - 60)
    {
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    });

}


@end
