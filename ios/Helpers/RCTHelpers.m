//
//  RCTHelpers.m
//  ReactNativeControllers
//
//  Created by Artal Druk on 25/05/2016.
//  Copyright © 2016 artal. All rights reserved.
//

#import "RCTHelpers.h"
#import <React/RCTView.h>
#import <React/RCTScrollView.h>
#import <React/RCTFont.h>

@implementation RCTHelpers

+(NSArray*)getAllSubviewsForView:(UIView*)view
{
    NSMutableArray *allSubviews = [NSMutableArray new];
    for (UIView *subview in view.subviews)
    {
        [allSubviews addObject:subview];
        [allSubviews addObjectsFromArray:[self getAllSubviewsForView:subview]];
    }
    return allSubviews;
}

/*
 The YellowBox is added to each RCTRootView. Regardless if there are warnings or not, if there's a warning anywhere in the app - it is added
 Since it is always appears on the top, it blocks interactions with other components.
 It is most noticeable in RCCLightBox and RCCNotification where button (for example) are not clickable if placed at the bottom part of the view
 */

+(BOOL)removeYellowBox:(RCTRootView*)reactRootView
{
#ifndef DEBUG
    return YES;
#endif
    
    BOOL removed = NO;
    
    NSArray* subviews = [self getAllSubviewsForView:reactRootView];
    for (UIView *view in subviews)
    {
        if ([view isKindOfClass:[RCTView class]])
        {
            CGFloat r, g, b, a;
            [view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
            
            //identify the yellow view by its hard-coded color and height
            if((lrint(r * 255) == 250) && (lrint(g * 255) == 186) && (lrint(b * 255) == 48) && (lrint(a * 100) == 95) && (view.frame.size.height == 46))
            {
                UIView *yelloboxParentView = view;
                while (view.superview != nil)
                {
                    yelloboxParentView = yelloboxParentView.superview;
                    if ([yelloboxParentView isKindOfClass:[RCTScrollView class]])
                    {
                        yelloboxParentView = yelloboxParentView.superview;
                        break;
                    }
                }
                
                [yelloboxParentView removeFromSuperview];
                removed = YES;
                break;
            }
        }
        
        if (removed)
        {
            break;
        }
    }
    
    return removed;
}

+ (NSMutableDictionary *)textAttributesFromDictionary:(NSDictionary *)dictionary withPrefix:(NSString *)prefix baseFont:(UIFont *)baseFont
{
    NSMutableDictionary *textAttributes = [NSMutableDictionary new];
    
    NSString *colorKey = @"color";
    NSString *familyKey = @"fontFamily";
    NSString *weightKey = @"fontWeight";
    NSString *sizeKey = @"fontSize";
    NSString *styleKey = @"fontStyle";
    NSString *shadowColourKey = @"shadowColor";
    NSString *shadowOffsetKey = @"shadowOffset";
    NSString *shadowBlurRadiusKey = @"shadowBlurRadius";
    NSString *showShadowKey = @"showShadow";
    
    if (prefix) {
        
        colorKey = [colorKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[colorKey substringToIndex:1].capitalizedString];
        colorKey = [NSString stringWithFormat:@"%@%@", prefix, colorKey];
        
        familyKey = [familyKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[familyKey substringToIndex:1].capitalizedString];
        familyKey = [NSString stringWithFormat:@"%@%@", prefix, familyKey];
        
        weightKey = [weightKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[weightKey substringToIndex:1].capitalizedString];
        weightKey = [NSString stringWithFormat:@"%@%@", prefix, weightKey];
        
        sizeKey = [sizeKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[sizeKey substringToIndex:1].capitalizedString];
        sizeKey = [NSString stringWithFormat:@"%@%@", prefix, sizeKey];
        
        styleKey = [styleKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[styleKey substringToIndex:1].capitalizedString];
        styleKey = [NSString stringWithFormat:@"%@%@", prefix, styleKey];
        
        shadowColourKey = [shadowColourKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[shadowColourKey substringToIndex:1].capitalizedString];
        shadowColourKey = [NSString stringWithFormat:@"%@%@", prefix, shadowColourKey];
        
        shadowOffsetKey = [shadowOffsetKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[shadowOffsetKey substringToIndex:1].capitalizedString];
        shadowOffsetKey = [NSString stringWithFormat:@"%@%@", prefix, shadowOffsetKey];
        
        shadowBlurRadiusKey = [shadowBlurRadiusKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[shadowBlurRadiusKey substringToIndex:1].capitalizedString];
        shadowBlurRadiusKey = [NSString stringWithFormat:@"%@%@", prefix, shadowBlurRadiusKey];
        
        showShadowKey = [showShadowKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[showShadowKey substringToIndex:1].capitalizedString];
        showShadowKey = [NSString stringWithFormat:@"%@%@", prefix, showShadowKey];
    }
    
    NSShadow *shadow;
    
    NSNumber *shadowColor = dictionary[shadowColourKey];
    if (shadowColor && [shadowColor isKindOfClass:[NSNumber class]]) {
        if (!shadow) {
            shadow = [NSShadow new];
        }
        shadow.shadowColor = [RCTConvert UIColor:shadowColor];
    }
    
    NSDictionary *shadowOffsetDict = dictionary[shadowOffsetKey];
    if (shadowOffsetDict && [shadowOffsetDict isKindOfClass:[NSDictionary class]]) {
        CGSize shadowOffset = [RCTConvert CGSize:shadowOffsetDict];
        if (!shadow) {
            shadow = [NSShadow new];
        }
        shadow.shadowOffset = shadowOffset;
    }
    
    NSNumber *shadowRadius = dictionary[shadowBlurRadiusKey];
    if (shadowRadius) {
        CGFloat radius = [RCTConvert CGFloat:shadowRadius];
        if (!shadow) {
            shadow = [NSShadow new];
        }
        shadow.shadowBlurRadius = radius;
    }
    
    NSNumber *showShadow = dictionary[showShadowKey];
    if (showShadow) {
        BOOL show = [RCTConvert BOOL:showShadow];
        if (!show) {
            shadow = nil;
        }
    }
    
    if (shadow) {
        [textAttributes setObject:shadow forKey:NSShadowAttributeName];
    }
    
    NSNumber *textColor = dictionary[colorKey];
    if (textColor && [textColor isKindOfClass:[NSNumber class]])
    {
        UIColor *color = [RCTConvert UIColor:textColor];
        [textAttributes setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    NSString *fontFamily = dictionary[familyKey];
    if (![fontFamily isKindOfClass:[NSString class]]) {
        fontFamily = nil;
    }
    
    NSString *fontWeight = dictionary[weightKey];
    if (![fontWeight isKindOfClass:[NSString class]]) {
        fontWeight = nil;
    }
    
    NSNumber *fontSize = dictionary[sizeKey];
    if (![fontSize isKindOfClass:[NSNumber class]]) {
        fontSize = nil;
    }
    
    NSNumber *fontStyle = dictionary[styleKey];
    if (![fontStyle isKindOfClass:[NSString class]]) {
        fontStyle = nil;
    }
    
    UIFont *font = [RCTFont updateFont:baseFont withFamily:fontFamily size:fontSize weight:fontWeight style:fontStyle variant:nil scaleMultiplier:1];
    
    if (font && (fontStyle || fontWeight || fontSize || fontFamily)) {
        [textAttributes setObject:font forKey:NSFontAttributeName];
    }
    
    return textAttributes;
}

+ (NSMutableDictionary *)textAttributesFromDictionary:(NSDictionary *)dictionary withPrefix:(NSString *)prefix
{
    return [self textAttributesFromDictionary:dictionary withPrefix:prefix baseFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
}

+ (NSString *)getTimestampString {
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    return [NSString stringWithFormat:@"%lld", milliseconds];
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+ (UIColor *)colorFromHexString:(NSString *)hexColor {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexColor];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)generateFilePath:(NSString *)glyph withFontName:(NSString *)fontName
                  withFontSize:(CGFloat)fontSize
                     withColor:(NSString *)hexColor
           withExtraIdentifier:(NSString *)identifier
{
    CGFloat screenScale = RCTScreenScale();
    NSString *fileName = [NSString stringWithFormat:@"tmp/RNVectorIcons_%@_%@_%hu_%.f%@@%.fx.png",
                          identifier, fontName,
                          [glyph characterAtIndex:0],
                          fontSize, hexColor, screenScale];
    
    return [NSHomeDirectory() stringByAppendingPathComponent:fileName];
}

+ (UIImage *)createAndSaveGlyphImage:(NSString *)glyph withFont:(UIFont *)font
                   withFilePath:(NSString *)filePath
                      withColor:(UIColor *)color
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:glyph attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
    
    CGSize iconSize = [attributedString size];
    UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
    [attributedString drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(iconImage);
    [imageData writeToFile:filePath atomically:YES];
    return iconImage;
}

+ (UIImage *) getImageForFont:(NSString*)fontName withGlyph:(NSString*)glyph withFontSize:(CGFloat)fontSize withColor:(NSString *)hexColor {
    
    NSString *filePath = [self generateFilePath:glyph withFontName:fontName withFontSize:fontSize withColor:hexColor withExtraIdentifier:@""];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // No cached icon exists, we need to create it and persist to disk
        UIColor *color = [RCTHelpers colorFromHexString:hexColor];
        UIFont *font = [UIFont fontWithName:fontName size:fontSize];
        return [self createAndSaveGlyphImage:glyph withFont:font withFilePath:filePath withColor:color];
    }
    return [UIImage imageWithContentsOfFile:filePath];
}

+ (UIImage *) getImageForFont:(NSString*)fontFamily withGlyph:(NSString*)glyph withFontSize:(CGFloat)fontSize withFontStyle:(NSInteger)style withColor:(NSString *)hexColor {
    
    NSNumber *fontWeight = [NSNumber numberWithDouble:UIFontWeightRegular];
    if (style == 1)
        fontWeight = [NSNumber numberWithDouble:UIFontWeightUltraLight];
    else if (style == 2)
        fontWeight = [NSNumber numberWithDouble:UIFontWeightBold];
    
    NSString *identifier = [NSString stringWithFormat:@"FA5.%ld", (long)style];
    
    NSString *filePath = [self generateFilePath:glyph withFontName:fontFamily withFontSize:fontSize withColor:hexColor withExtraIdentifier:identifier];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // No cached icon exists, we need to create it and persist to disk
        UIColor *color = [RCTHelpers colorFromHexString:hexColor];
        UIFont *font = [UIFont fontWithName:fontFamily size:fontSize];
        for (NSString *fontString in [UIFont fontNamesForFamilyName:fontFamily]) {
            UIFont *testFont = [UIFont fontWithName:fontString size:fontSize];
            NSDictionary *traits = [testFont.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
            NSNumber *testFontWeight = traits[UIFontWeightTrait];
            
            if (testFontWeight.doubleValue == fontWeight.doubleValue) {
                font = testFont;
                break;
            }
        }
        return [self createAndSaveGlyphImage:glyph withFont:font withFilePath:filePath withColor:color];
    }
    return [UIImage imageWithContentsOfFile:filePath];
}

+ (UIImage *)UIImage:(id)json
{
    // suport convert with font and uri
    if (json[@"fontName"]){
        CGFloat fontSize = [RCTConvert CGFloat:json[@"fontSize"]];
        // if we use fontFamily Font Awesome 5 Free
//        if([json[@"fontName"] isEqualToString: @"Font Awesome 5 Free"]){
        if(json[@"fontStyle"]){
            NSString* fontStyle = json[@"fontStyle"];
            NSInteger style = 0;
            if([fontStyle isEqualToString:@"light"])
                style = 1;
            else if ([fontStyle isEqualToString:@"solid"])
                style = 2;
            // hacky way to support font awesome 5 as alternative
            return [RCTHelpers getImageForFont: @"Font Awesome 5 Free" withGlyph:json[@"glyph"] withFontSize:fontSize withFontStyle: style withColor:json[@"color"]];
        }
        return [RCTHelpers getImageForFont: json[@"fontName"] withGlyph:json[@"glyph"] withFontSize:fontSize  withColor:json[@"color"]];
    }
    
    // fallback
    return [RCTConvert UIImage:json];
}

@end
