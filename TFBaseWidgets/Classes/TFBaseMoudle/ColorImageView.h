//
//  ColorImageView.h
//
//  Created by iMac on 16/12/12.
//  Copyright © 2016年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorImageView : UIImageView
//@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color);
@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color,CGPoint pt);
@property (assign,nonatomic) CGPoint pickerPt;
@end
