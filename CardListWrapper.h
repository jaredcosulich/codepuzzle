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

@property UIImage * analyzedImage;

- (instancetype) init;
- (void) clear;
- (void) printHex :(int) index;
- (double) getRotation :(int) index;
- (CGRect) getFullRect :(int) index;
- (CGRect) getHexRect :(int) index;
- (CGRect) getInnerHexRect :(int) index;
- (CGRect) getFunctionRect :(int) index;
- (CGRect) getParamRect :(int) index;
- (void) remove :(int) index;
- (void) add :(double) hexCenterX :(double) hexCenterY :(double) hexWidth :(double) hexHeight :(double) rotation;
- (int) count;

@end

