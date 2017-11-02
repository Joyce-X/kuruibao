//
//  XMDownloadCell.m
//  kuruibao
//
//  Created by x on 16/9/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 自定义下载离线地图时候的tableviewCell
 
 
 ************************************************************************************************/
#import "XMDownloadCell.h"

#define Margin 15 //!< cell左右间距


@interface XMDownloadCell()


@property (nonatomic,weak)UILabel* progressLabel;//!< 显示下载进度的Label
@property (nonatomic,weak)UIProgressView* progress;//!< 下载进度条
@property (nonatomic,weak)UIButton* downLoadBtn;//!< 下载按钮
@end

@implementation XMDownloadCell


#pragma mark --- system method

+ (instancetype)dequeueResuableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"downLoadCell";
    XMDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        
        cell = [[XMDownloadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //!< cell样式 1 有Label显示下载地区的名称，2 progress显示下载进度 3 label显示下载信息（等待或者下载中，下载完毕）
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //!< 显示省市名称
        UILabel *nameLabel = [UILabel new];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        
        //!< 添加显示下载按钮
        UIButton *downLoadBtn = [UIButton new];
        [downLoadBtn setImage:[UIImage imageNamed:@"arrow_copyKaiLiDe"] forState:UIControlStateNormal];
        [downLoadBtn setImage:[UIImage imageNamed:@"arrow_copyKaiLiDe"] forState:UIControlStateHighlighted];
        [downLoadBtn addTarget:self action:@selector(downLoadBtnDidClick: event:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:downLoadBtn];
        self.downLoadBtn = downLoadBtn;
        downLoadBtn.hidden = YES;
        self.btn_download = downLoadBtn;
        
        
        //!< 添加显示下载进度发label
        UILabel *progressLabel = [UILabel new];
        progressLabel.textColor = XMGreenColor;
        progressLabel.font = [UIFont systemFontOfSize:12];
        progressLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:progressLabel];
        self.progressLabel = progressLabel;
        progressLabel.hidden = YES;
        
        //!< 进度条
        UIProgressView *progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        progress.trackTintColor = XMColor(239, 239, 239);
        progress.progressTintColor = XMGreenColor;
        [self.contentView addSubview:progress];
        self.progress = progress;
        progress.hidden = YES;
 
    }
    
    return self;
    

    
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    __weak typeof(self) wSelf = self;
 
    //!< 显示名称
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(wSelf).offset(Margin);
        make.width.equalTo(250);
        make.height.equalTo(25);
        make.centerY.equalTo(wSelf);
        
    }];
    
    //!< 显示下载按钮
    [_downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(24, 24));
        make.right.equalTo(wSelf).offset(-Margin);
        make.centerY.equalTo(_nameLabel);
        
    }];
    
    //!< 显示下载提示label
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(_nameLabel);
        make.right.equalTo(_downLoadBtn);
        make.height.equalTo(_nameLabel);
        make.width.equalTo(150);
        
    }];
    
    [_progress mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(wSelf);
        make.width.equalTo(mainSize.width - Margin * 2);
        make.height.equalTo(2);
        make.bottom.equalTo(wSelf).offset(-5);
        
    }];
    
    
    
}




#pragma mark - setter and getter  Method

//!< 设置填充色
- (void)setTintColor:(UIColor *)tintColor
{
    
    _progress.progressTintColor = tintColor;
    
    
}


//!< 设置未填充部分颜色
- (void)setTrackTintColor:(UIColor *)trackTintColor
{
  
    _progress.trackTintColor = trackTintColor;
    
}

//!< 设置标题
- (void)setAccessoryText:(NSString *)accessoryText
{
    _accessoryText = accessoryText;
    _progressLabel.text = accessoryText;
    _progressLabel.hidden = NO;
    _progressLabel.textColor = XMGrayColor;
    _downLoadBtn.hidden = YES;
}


#pragma mark --- 监控按钮的点击事件

//!< 监听下载按钮的点击事件
- (void)downLoadBtnDidClick:(UIButton *)sender event:(UIEvent *)event
{
    if (self.startDownloadBlock)
    {
//        _downLoadBtn.hidden = YES;
//        _progressLabel.hidden = NO;
//        _progressLabel.text = NSLocalizedString(@"等待中", nil);
//        _progressLabel.textColor = [UIColor grayColor];
        _startDownloadBlock(sender,event);//!< 调用外部tab开始下载
        
    }
    

}




#pragma mark --- 更新内容

/**
 *  更新辅助区域显示内容 按照地图的不同状态
 *
 *  @param item 对应地图
 */
- (void)updateAccessoryViewWithItem:(MAOfflineItem *)item
{
    
    
    
    //!< 判断是否是省对应的item
    if ([item isKindOfClass:[MAOfflineProvince class]])
    {
        
        switch (item.itemStatus)
        {
                /**
                 * 不存在   缓存   已安装  已过期
                 */
            case MAOfflineItemStatusInstalled:
                
                
                //!< 已安装 只显示Label显示文字：”已安装“
                _progressLabel.text = NSLocalizedString(@"已安装", nil);
                _progressLabel.textColor = [UIColor grayColor];
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                
                break;
                
            case MAOfflineItemStatusNone:
                
                //!< 不存在 :只显示下载按钮
                
                [self setAccessoryStatuslabel:YES progress:YES btn:NO];
                
                break;
                
            case MAOfflineItemStatusExpired:
                
                //!< 已过期：只显示下载按钮
                
                [self setAccessoryStatuslabel:YES progress:YES btn:NO];
                
                
                break;
                
         case MAOfflineItemStatusCached:
                
                //!< 正在缓存（属于暂停下载的情况）
                
                
                
                //!< 判断是否是省的信息
                //!< 如果是省份信息就只显示label显示文字:缓存中
                    
                    [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                    _progressLabel.text = [NSString stringWithFormat:@"缓存中 "];
                    _progressLabel.textColor = [UIColor grayColor];
                
                
                break;
                
            default:
                
                
                
                break;
        }

    
    }else
    {
        switch (item.itemStatus)
        {
                /**
                 * 不存在   缓存   已安装  已过期
                 */
            case MAOfflineItemStatusInstalled:
                
                //!< 已安装 只显示Label显示文字：”已安装“
                
                _progressLabel.text = NSLocalizedString(@"已安装", nil);
                _progressLabel.textColor = [UIColor grayColor];
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                
                break;
                
            case MAOfflineItemStatusNone:
                
                //!< 不存在 :只显示下载按钮
                
                [self setAccessoryStatuslabel:YES progress:YES btn:NO];
                
                break;
                
            case MAOfflineItemStatusExpired:
                
                //!< 已过期：只显示下载按钮
                
                [self setAccessoryStatuslabel:YES progress:YES btn:NO];
                
                
                break;
                
            case MAOfflineItemStatusCached:
                
                    //!< 如果是普通市信息，就显示文字和进度条，文字暂时设置为红色，进度条灰色
                    
                    [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                    
                    _progressLabel.textColor = XMGrayColor;
//                    _progress.progressTintColor = [UIColor lightGrayColor];
//                    double pro = item.downloadedSize * 1.0 / item.size;  //!< 比例
//                    _progress.progress = pro;
                _progressLabel.text = @"暂停下载";
 
                
                
                
                break;
                
            default:
                break;
        }

    
    
    }
    
   

}

/**
 *  更新区域名称
 *
 *  @param item 同上
 */

- (void)updateTitleWithItem:(MAOfflineItem *)item
{
    
   
    
    double size =  (item.size  / 1000.0 / 1000.0);

    if([item isKindOfClass:[MAOfflineProvince class]])
    {
         _nameLabel.text = [NSString stringWithFormat:@"%@(%.1lfM)",@"全省地图",size];
        return;
    }
    _nameLabel.text = [NSString stringWithFormat:@"%@(%.1fM)",item.name,size];
}


/**
 *  更新cell子控件显示的内容信息
 *
 *  @param item          当前下载地图
 *  @param info          下载过程的信息
 *  @param isDownloading 是否包含在正在下载的数组当中
 */
- (void)updateContentWithItem:(MAOfflineItem *)item infoDictionary:(NSMutableDictionary *)info contentInDownloading:(BOOL)isDownloading
{
 
    //isDownloading 参数现在废弃不用
    
    //!< 当地图属于正在下载的状态的时候对cell的数据进行更新
    MAOfflineMapDownloadStatus status = [[info objectForKey:DownloadStageIsRunningKey2] intValue];

    
    if ([item isKindOfClass:[MAOfflineProvince class]])
    {
        //!< 省份信息
        
        
        
//        //!< 设置显示控件
//        if (self.tag == 0)
//        {
//            //!< 只设置一次
//            [self setAccessoryStatuslabel:NO progress:NO btn:YES];
//            _progress.progressTintColor = XMGreenColor;
//            _progressLabel.textColor = XMGreenColor;
//            self.tag = 1;
//        }
        switch (status)
        {
                
            case MAOfflineMapDownloadStatusCancelled:
            {
                
                
                _progressLabel.text = @"暂停下载%d%%";
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                
                
                _progressLabel.text = NSLocalizedString(@"已安装", nil);
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                
                break;
            }
                
            case MAOfflineMapDownloadStatusError:
                _progressLabel.text = @"下载失败";
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                break;
                
            default:
                
                _progressLabel.text = @"缓存中";
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                break;
             
        }
        
    }else
    {
        //!< 普通市
        //!< 设置显示控件
//        if (self.tag == 0)
//        {
//            //!< 只设置一次
//            [self setAccessoryStatuslabel:NO progress:NO btn:YES];
//            _progress.progressTintColor = XMGreenColor;
//            _progressLabel.textColor = XMGreenColor;
//            self.tag = 1;
//        }
        switch (status)
        {
          case MAOfflineMapDownloadStatusWaiting:

                _progressLabel.text = @"等待下载";
                _progressLabel.textColor = XMGreenColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];

                break;
            case MAOfflineMapDownloadStatusStart:
                
                _progressLabel.text = @"开始下载";
                _progressLabel.textColor = XMGreenColor;
                [self setAccessoryStatuslabel:NO progress:NO btn:YES];
                
                break;
                
            case MAOfflineMapDownloadStatusProgress:
            {
                
                
                [self setAccessoryStatuslabel:NO progress:NO btn:YES];
                //!< 下载过程中
                NSDictionary *progressDict = [info objectForKey:DownloadStageInfoKey2];
                
                long long recieved = [[progressDict objectForKey:MAOfflineMapDownloadReceivedSizeKey] longLongValue];
                long long expected = [[progressDict objectForKey:MAOfflineMapDownloadExpectedSizeKey] longLongValue];
                
                double percentage = recieved * 1.0 / expected;
//
                _progressLabel.text = [NSString stringWithFormat:@"正在下载%d%%",(int)(percentage * 100)];
                _progressLabel.textColor = XMGreenColor;
                _progress.progress = percentage;
                _progress.progressTintColor = XMGreenColor;
                
                if (percentage >= 1.0)
                {
                    _progressLabel.text = NSLocalizedString(@"已安装", nil);
                    [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                    _progressLabel.textColor = XMGrayColor;
                    return;
                    
                }

                
                
                 break;
                
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                //!< 下载完成，删除进度条
                
                _progressLabel.text = NSLocalizedString(@"已安装", nil);
                 _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                //!< 取消下载的情况
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
  
                _progressLabel.textColor = XMGrayColor;
                _progressLabel.text = @"暂停下载";
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                _progressLabel.text = NSLocalizedString(@"正在解压", nil);
                _progressLabel.textColor = XMGreenColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                
                
                _progressLabel.text = NSLocalizedString(@"已安装", nil);
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                
                
                
                break;
            }
                
            case MAOfflineMapDownloadStatusError:
                _progressLabel.text = @"下载失败";
                _progressLabel.textColor = XMGrayColor;
                [self setAccessoryStatuslabel:NO progress:YES btn:YES];
                break;
            default:
             
                break;
             
        }
        
    
    }
    

  
 
  



}
 /**
 *  等待下载时候更新cell
 */
- (void)updateCellWhenWaitDownload
{
    
    _progressLabel.text = NSLocalizedString(@"等待中", nil);
    _progressLabel.hidden = NO;
    _progressLabel.textColor = XMGrayColor;
    _downLoadBtn.hidden = YES;
    _progress.hidden = NO;

}

/**
 *  当全省地图正在下载的时候，当前分区cell的用户交互
 */
- (void)turnOffUserInteraction
{
    _progress.hidden = YES;
    _progressLabel.hidden = YES;
    _downLoadBtn.hidden = NO;
    self.backgroundColor = XMGrayColor;


}

//!< 设置子控件显示与隐藏
- (void)setAccessoryStatuslabel:(BOOL)hidenLabel progress:(BOOL)hidenProgress btn:(BOOL)hidenBtn
{
    _progressLabel.hidden = hidenLabel;
    _progress.hidden = hidenProgress;
    _downLoadBtn.hidden = hidenBtn;

}

/**
 *  点击省份下载全部
 */
- (void)downloadAll
{
    _downLoadBtn.hidden = YES;
    _progressLabel.hidden = NO;
    _progressLabel.text = NSLocalizedString(@"等待中", nil);
    _progressLabel.textColor = [UIColor greenColor];
    _progress.hidden = NO;
    _progress.trackTintColor = XMColor(239, 239, 239);
    _progress.progress = 0;
    
    
}


/**
 
 //!< 缓存状态的情况 分期正在缓存，暂停缓存
 - (void)setInfoWhenCached:(MAOfflineItem *)item
 {
 
 _downLoadBtn.hidden = YES; //!< 隐藏下载按钮
 _progressLabel.hidden = NO;//!< 显示辅助文字
 _progress.hidden = NO;//!< 显示进度条并设置数值
 int progress_item = (int)(item.downloadedSize / item.size);
 [_progress setProgress:progress_item]; //!< 设置下载进度
 
 
 //!< 判断是否正在下载
 if ([[MAOfflineMap sharedOfflineMap] isDownloadingForItem:item])
 {
 //!< 正在下载  设置提示内容并用绿色表示
 _progressLabel.text = [NSString stringWithFormat:@"%%%d正在下载",progress_item];
 _progressLabel.textColor = [UIColor greenColor];//!< 绿色字体
 
 
 }else{
 //!< 暂停下载
 _progressLabel.text = [NSString stringWithFormat:@"%%%d暂停下载",progress_item];
 _progressLabel.textColor = [UIColor redColor];//!< 红色字体
 _progress.progressTintColor = [UIColor lightTextColor];//!< 灰色进度
 }
 
 
 
 }
 
 #warning --- 待开发
 //!< 过期的情况
 - (void)setInfoWhenExpired:(MAOfflineItem *)item
 {
 
 XMLOG(@"过期的情况处理。。。");
 }
 
 
 //!< 没有离线地图的情况
 - (void)setInfoWhenNone:(MAOfflineItem *)item
 {
 _downLoadBtn.hidden = NO;//!< 没有检测出离线地图，显示下载按钮
 _progressLabel.hidden = YES;
 _progress.hidden = YES;
 
 }
 
 
 //!< 安装完成的情况
 - (void)setInfoWhenInstalled:(MAOfflineItem *)item
 {
 //    //!< 设置辅助显示内容为已完成
 //    _progressLabel.text = @"已完成";
 //    _progressLabel.hidden = NO;
 //    _progressLabel.textColor = XMGrayColor;
 //    _downLoadBtn.hidden = YES;//!< 隐藏进度条和按钮
 //    _progress.hidden = YES;
 //
 //!< 控制控件的显示
 [self setAccessoryStatuslabel:NO progress:YES btn:YES];
 
 }
 
 */

@end
