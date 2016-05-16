//
//  SGNavigationBarNotificationView.h
//  EkuKangDA
//
//  Created by ysghome on 5/12/16.
//  Copyright © 2016 eku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGNavigationBarNotificationView : UIView

/**
 *  图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
/**
 *  标题
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/**
 *  内容
 */
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
