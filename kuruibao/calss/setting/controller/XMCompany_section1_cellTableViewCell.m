//
//  XMCompany_section1_cellTableViewCell.m
//  kuruibao
//
//  Created by x on 17/5/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCompany_section1_cellTableViewCell.h"

@interface XMCompany_section1_cellTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *allNameLabel;


@end

@implementation XMCompany_section1_cellTableViewCell

+ (instancetype)dequeueWithTableView:(UITableView *)tableView
{

    static NSString *identifier = @"XMCompany_section1_cellTableViewCell";
    
    XMCompany_section1_cellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMCompany_section1_cellTableViewCell" owner:nil options:nil].firstObject;
        
         cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05];
    }

    
    return cell;


}


- (void)setCarModel:(XMCar *)carModel
{

    _carModel = carModel;
    
    NSLog(@"Joyce______%@",carModel.class);
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",carModel.brandid]];;
    
         
    
    
    
    self.carImageView.image = image ? image : [UIImage imageNamed:@"companyList_placeholderImahe"];
    
    self.carNumberLabel.text = carModel.chepaino;
    
    
    UIColor *color;
    
    switch (carModel.currentstatus)
    {
        case 0:

            self.statusLabel.text = @"停驶中";
            
            color = XMRedColor;
            
            break;
            
        case 1:
            
            self.statusLabel.text = @"行驶中";
            
            color = XMGreenColor;
            
            break;
            
        case 2:
            
            self.statusLabel.text = @"失联";
            
            color = XMGrayColor;
            
            break;
            
        default:
            break;
    }
    
    self.statusLabel.textColor = color;
    
    NSString *name = [carModel.seriesname stringByAppendingFormat:@"%@",carModel.stylename];

    self.allNameLabel.text = name.length > 2 ? name : @"暂无数据";

}

@end
