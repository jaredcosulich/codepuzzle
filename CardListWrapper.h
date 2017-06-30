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
- (UIImage *) getParamImage :(int) index;
- (void) add :(CGRect) hex :(CGRect) innerHex :(UIImage*) hexImage :(UIImage*) fullImage :(UIImage*) functionImage :(UIImage*) paramImage;
- (int) count;

@end

