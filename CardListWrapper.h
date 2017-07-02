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
- (void) clear;
- (void) printHex :(int) index;
- (UIImage *) getHexImage :(int) index;
- (UIImage *) getFullImage :(int) index;
- (UIImage *) getFunctionImage :(int) index;
- (void) setFunctionImage :(int) index :(UIImage *) functionImage;
- (void) setFullImage :(int) index :(UIImage *) fullImage;
- (UIImage *) getParamImage :(int) index;
- (double) getRotation :(int) index;
- (void) add :(double) rotation :(CGRect) hex :(CGRect) innerHex :(UIImage*) hexImage :(UIImage*) fullImage :(UIImage*) functionImage :(UIImage*) paramImage;
- (int) count;

@end

