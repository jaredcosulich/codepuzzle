//
//  TensorflowWrapper.m
//  codepuzzle
//
//  Created by Jared Cosulich on 6/19/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tensorflow_utils.h"

#import "TensorflowWrapper.h"

@implementation TensorflowWrapper

+ (tensorflow::Status) LoadModel: NSString* file_name, NSString* file_type, std::unique_ptr<tensorflow::Session>* session) {
    return tensorflow_utils::LoadModel(file_name, file_type, session);
}

@end
