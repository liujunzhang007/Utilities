//
//  NSBundle+Language.h
//  IM for iOS-WebSoket
//
//  Created by 刘俊彰 on 2020/5/29.
//  Copyright © 2020 shishizu. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

#define GCLocalizedString(KEY) [[NSBundle mainBundle] localizedStringForKey:KEY value:nil table:@"Localizable"]

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Language)

+ (void)setLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
