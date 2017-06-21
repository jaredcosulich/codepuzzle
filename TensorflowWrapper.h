//
//  TensorflowWrapper.h
//  codepuzzle
//
//  Created by Jared Cosulich on 6/19/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <tensorflow/core/lib/core/status.h>

@interface TensorflowWrapper : NSObject

+ (tensorflow::Status) LoadModel: (NSString*)file_name;// :(NSString*)file_type :(std::unique_ptr<tensorflow::Session>*)session;



@end
