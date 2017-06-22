//
//  CardListWrapper.h
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CardListWrapper : NSObject

- (instancetype) init;
- (UIImage *) getFull :(int) index;
- (UIImage *) getFunction :(int) index;
- (UIImage *) getParam :(int) index;
- (void) add :(UIImage*) full :(UIImage*) function :(UIImage*) param;
- (int) length;

@end

