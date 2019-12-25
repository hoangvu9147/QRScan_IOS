//
//  UtilityZebar.m
//  Monistor
//
//  Created by lhvu on 2018/12/28.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

#import "UtilityZebar.h"

@implementation UtilityZebar

+ (NSString *)formatAddressBLE:(NSString *)addres
{
    NSString *_bt_address = @"";
    if (6*2 == [addres length])
        {
        for (int i = 0; i < 6; i++)
            {
            _bt_address = [_bt_address stringByAppendingString:[NSString stringWithString:[addres substringWithRange:NSMakeRange(i*2, 2)]]];
            if (i < 5)
                {
                _bt_address = [_bt_address stringByAppendingString:@":"];
                }
            }
        }
    return _bt_address;
}
@end
