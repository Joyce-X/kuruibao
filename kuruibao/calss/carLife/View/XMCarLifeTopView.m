//
//  XMCarLifeTopView.m
//  喜马拉雅测试
//
//  Created by x on 17/4/11.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLifeTopView.h"


@interface XMCarLifeTopView ()<UIScrollViewDelegate>

@property (strong, nonatomic) NSTimer *timer;//!< 定时器

@property (assign, nonatomic) BOOL finishInit;//!< 是否完成初始化

@property (weak, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) UIPageControl *pageControl;

@end


@implementation XMCarLifeTopView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        UIScrollView *scrollView = [UIScrollView new];
        
        scrollView.showsVerticalScrollIndicator = NO;
        
        scrollView.showsHorizontalScrollIndicator = NO;
        
        scrollView.pagingEnabled = YES;
        
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        
        self.scrollView = scrollView;
        
        
        
    }
    return self;
}


- (void)setImageNames:(NSArray<NSString *> *)imageNames
{
    _imageNames = imageNames;
    
    self.scrollView.frame = self.bounds;
    
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * imageNames.count, self.bounds.size.height);
    
    for(int i = 0; i<imageNames.count;i++)
    {
        CGFloat scroll_x = i * self.bounds.size.width;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scroll_x, 0, self.bounds.size.width, self.bounds.size.height)];
        
        imageView.image = [UIImage imageNamed:imageNames[i]];
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        [self.scrollView addSubview:imageView];
        
    }
    
    CGFloat scroll_x = imageNames.count * self.bounds.size.width;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scroll_x, 0, self.bounds.size.width, self.bounds.size.height)];
    
    imageView.image = [UIImage imageNamed:imageNames[0]];
    
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.scrollView addSubview:imageView];
    
    
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.bounds.size.width - 60)/2, self.bounds.size.height - 20, 60, 20)];
    
    pageControl.numberOfPages = imageNames.count;
    
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    
    [self addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    [self startTimer];
    
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    float offset_x = scrollView.contentOffset.x;
    
    
    offset_x += (scrollView.bounds.size.width * 0.5);
    
    int index = offset_x / scrollView.bounds.size.width;
    
    
   
    if (index == _pageControl.numberOfPages)
    {
        index = 0;
    }
    
    self.pageControl.currentPage = index;
    
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
    
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        
        CGPoint currentOffset = self.scrollView.contentOffset;
        
        
        currentOffset.x += self.bounds.size.width;
        
        if (currentOffset.x >= _scrollView.bounds.size.width * _imageNames.count)
        {
            
            _pageControl.currentPage = 0;
            
            [self.scrollView setContentOffset:currentOffset animated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.scrollView.contentOffset = CGPointZero;
            });
            
        }else
        {
            [self.scrollView setContentOffset:currentOffset animated:YES];
            
            
            int index = currentOffset.x /self.bounds.size.width;
            
            _pageControl.currentPage = index;
            
        }
        
        
        
        
        
    }];
    
    
    
}

- (void)stopTimer
{
    [self.timer invalidate];
    
    self.timer = nil;
    
}



@end
