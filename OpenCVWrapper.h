//
//  OpenCVWrapper.h
//  Grey
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CardListWrapper.h"

@interface OpenCVWrapper : NSObject

+ (UIImage *) individualProcess :(UIImage *) image :(int) process;

+ (UIImage *) debug :(UIImage *) image;

+ (void) process :(UIImage *) image :(CardListWrapper *) cards;

+ (UIImage *) floodFill :(UIImage *) image :(int) x :(int) y :(int) red :(int) green :(int) blue;

@end
