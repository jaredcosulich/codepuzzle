//
//  OpenCVWrapper.h
//  Grey
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *) canny: (UIImage *) image;

@end
