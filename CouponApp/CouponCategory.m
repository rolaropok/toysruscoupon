//
//  CouponCategory.m
//  ToysRUsIL
//
//  Created by Fredrick Jansen on 15/02/15.
//  Copyright (c) 2015 Fredrick Jansen. All rights reserved.
//

#import "CouponCategory.h"

@implementation CouponCategory

-(instancetype) initWithCategory:(int) category {
    
    if (self = [super init]) {
        _category = category;
        _coupons = [[NSMutableArray alloc] init];
    }
    return  self;
}

-(void) addcouponThumb:(CouponThumbInfo *) thumb
{
    [self.coupons addObject:thumb];
    
}
@end
