//
//  UILabel+Extension.h
//  IM for iOS-WebSoket
//
//  Created by 刘俊彰 on 2020/5/21.
//  Copyright © 2020 shishizu. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Extension)
/**
 *  改变行间距
 */
+ (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变字间距
 */
+ (void)changeWordSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
+ (void)changeSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

//转换时间戳
+ (NSString *)transformToDateStrWithTimeIntrval:(NSTimeInterval)interval;
@end

NS_ASSUME_NONNULL_END
