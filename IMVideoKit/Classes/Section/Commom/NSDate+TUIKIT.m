//
//  NSDate+TUIKIT.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "NSDate+TUIKIT.h"

@implementation NSDate (TUIKIT)

- (NSString *)tk_messageString
{

    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:self];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    dateFmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_SI"];
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:self];

    NSString *result;
    
    if (nowCmps.day==myCmps.day) {
        dateFmt.dateFormat = @"hh:mm aa";
        result = [dateFmt stringFromDate:self];
    } else if((nowCmps.day-myCmps.day)==1) {
        dateFmt.dateFormat = @"hh:mm aa";
        result = [@"Yesterday " stringByAppendingString:[dateFmt stringFromDate:self]];
        
    } else {
        if ((nowCmps.day-myCmps.day) <=7) {
            dateFmt.dateFormat = @"EEEE hh:mm aa";
            result = [dateFmt stringFromDate:self];
        }else {
            dateFmt.dateFormat = @"dd MMM yyyy hh:mm aa";
            result = [dateFmt stringFromDate:self];
        }
    }
    result = [[result substringToIndex:result.length-2] stringByAppendingString:[[result substringFromIndex:result.length-2]lowercaseString]];
    return result;
}
@end
