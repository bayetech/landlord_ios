//
//  NSString+MHCommon.m
//  PerfectProject
//
//  Created by Meng huan on 14/11/19.
//  Copyright (c) 2014年 M.H Co.,Ltd. All rights reserved.
//

#import "NSString+Extension.h"
// MD5加密
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)

/**
 *  判断字符串是否为空
 */
 BOOL stringEmpty(id _Nonnull aString) {
     if (!aString) return YES;
     if ([aString isKindOfClass:[NSNull class]]) return YES;
     if (aString == [NSNull null]) return YES;
     if (![aString isKindOfClass:[NSString class]]) return YES;
     if ([aString isEqualToString:@""]) return YES;
     if ([aString length] == 0) return YES;
    return NO;
}

/**
 汉字转拼音
 */
+ (NSString *)chineseTransformLetter:(NSString *)chinese {
    
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *letter = [pinyin uppercaseString];
    
    return letter;
}

/// 汉字转拼音 返回首字母

+ (NSString *)transformFirstLetter:(NSString *)chinese
{
    NSString *letter                = [self chineseTransformLetter:chinese];
    if (letter.length < 1) {
        return @"#";
    }
    NSString *firstLetter           = [letter substringToIndex:1];
    NSString *regex = @"^[A-Z]+$";
    NSPredicate *letterPredicate    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL flag = [letterPredicate evaluateWithObject:firstLetter];
    if (!flag) {
        return @"#";
    } else {
        return firstLetter;
    }

}

#pragma mark - MD5加密
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[32];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    // 先转MD5，再转大写
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
//#pragma mark - URL编码
//- (NSString *)urlCodingToUTF8
//{
//    NSString *escapedPath = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    return escapedPath;
//}
//#pragma mark - URL解码
//- (NSString *)urlDecodingToUrlString
//{
//    return [self stringByRemovingPercentEncoding];
//}

-(CGSize)getTextSizeWithFont:(CGFloat)fontSize restrictWidth:(float)width
{
    //动态计算文字大小
    NSDictionary *oldDict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize oldPriceSize = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:oldDict context:nil].size;
    return oldPriceSize;
}

-(CGSize)getAttributedTextSizeWithRestrictWidth:(float)width  withString:(NSAttributedString*)string
{
    CGFloat titleHeight = 0.0f;
    CGFloat titleWidth  = 0.0f;
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:options
                                       context:nil];
    titleHeight = ceilf(rect.size.height);
    titleWidth  = ceilf(rect.size.width);
    CGSize size = {titleWidth,titleHeight};
    return size;  // 加两个像素,防止emoji被切掉.
    
}

- (BOOL)stingIsBoolValue {
    
    if ([self isEqualToString:@"true"]) {
        return YES;
    }else {
        return NO;
    }
    
}

/**
 *  判断银行卡号
 */
+ (BOOL) isValidCreditNumber:(NSString*)cardNo {
    
    int oddsum       = 0;//奇数求和
    int evensum      = 0;//偶数求和
    int allsum       = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum      = [[cardNo substringFromIndex:cardNoLength-1] intValue];

    cardNo = [cardNo substringToIndex:cardNoLength - 1];  
    for (int i = cardNoLength -1 ; i>=1;i--) {  
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];  
        int tmpVal = [tmpString intValue];  
        if (cardNoLength % 2 ==1 ) {  
            if((i % 2) == 0){  
                tmpVal *= 2;  
                if(tmpVal>=10)  
                    tmpVal -= 9;  
                evensum += tmpVal;  
            }else{  
                oddsum += tmpVal;  
            }  
        }else{  
            if((i % 2) == 1){  
                tmpVal *= 2;  
                if(tmpVal>=10)  
                    tmpVal -= 9;  
                evensum += tmpVal;  
            }else{  
                oddsum += tmpVal;  
            }  
        }  
    }  
    
    allsum = oddsum + evensum;  
    allsum += lastNum;  
    if((allsum % 10) == 0)  {
        
        return YES;  
    } else {
        return NO;  

    }

    
}
//
//
//+(BOOL)checkIdentityCardNo:(NSString*)identityCard {
//    
//    BOOL flag;
//    if (identityCard.length <= 0)
//    {
//        flag = NO;
//        return flag;
//    }
//    
//    NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
//    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
//    flag = [identityCardPredicate evaluateWithObject:identityCard];
//    
//    
//    //如果通过该验证，说明身份证格式正确，但准确性还需计算
//    if(flag)
//    {
//        if(identityCard.length ==18)
//        {
//            //将前17位加权因子保存在数组里
//            NSArray * idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
//            
//            //这是除以11后，可能产生的11位余数、验证码，也保存成数组
//            NSArray * idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
//            
//            //用来保存前17位各自乖以加权因子后的总和
//            
//            NSInteger idCardWiSum = 0;
//            for(int i = 0;i < 17;i++)
//            {
//                NSInteger subStrIndex   = [[identityCard substringWithRange:NSMakeRange(i, 1)] integerValue];
//                NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
//                
//                idCardWiSum             += subStrIndex * idCardWiIndex;
//                
//            }
//            
//            //计算出校验码所在数组的位置
//            NSInteger idCardMod = idCardWiSum%11;
//            
//            //得到最后一位身份证号码
//            NSString * idCardLast= [identityCard substringWithRange:NSMakeRange(17, 1)];
//            
//            //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
//            if(idCardMod==2)
//            {
//                if([idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"])
//                {
//                    return flag;
//                }else
//                {
//                    flag =  NO;
//                    return flag;
//                }
//            }else
//            {
//                //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
//                if([idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]])
//                {
//                    return flag;
//                }
//                else
//                {
//                    flag =  NO;
//                    return flag;
//                }
//            }
//        }
//        else
//        {
//            flag =  NO;
//            return flag;
//        }
//    }
//    else
//    {
//        return flag;
//    }
//    
//    
//}
//
/**
 把 jsonString 转换成字符串
 */
- (id)jsonStringToData {
    
    NSData *data    = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error = nil;
    id result       = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        result = @{};
    }
    
    return result;
}

/**
 是否为纯数字 0-9 不包含 字母 符号
 */
- (BOOL)isNumberValue {
    
    NSString *number                    = @"^[0-9]*$";
    NSPredicate *regextestmobile        = [NSPredicate predicateWithFormat:@"SELF MATCHES  %@",number];
    
    BOOL isNumber                       = [regextestmobile evaluateWithObject:self];

    return isNumber;
}


@end
