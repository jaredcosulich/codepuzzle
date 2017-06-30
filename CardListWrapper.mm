//
//  CardListWrapper.m
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import "CardListWrapper.h"
#import "CardList.h"

@interface CardListWrapper()
@property CardList *cardList;
@end

@implementation CardListWrapper

- (instancetype) init {
    if (self = [super init]) {
        self.cardList = new CardList();
    }
    return self;
}

- (void) clear {
    self.cardList->clear();
}

- (void) printHex :(int) index {
    return self.cardList->printHex(index);
}

- (UIImage *) getHexImage :(int) index {
    return self.cardList->getHexImage(index);
}

- (UIImage *) getFullImage :(int) index {
    return self.cardList->getFullImage(index);
}

- (UIImage *) getFunctionImage :(int) index {
    return self.cardList->getFunctionImage(index);
}

- (void) setFunctionImage :(int) index :(UIImage *) functionImage {
    self.cardList->setFunctionImage(index, functionImage);
}

- (UIImage *) getParamImage :(int) index {
    return self.cardList->getParamImage(index);
}

- (void) add :(CGRect) hex :(CGRect) innerHex :(UIImage*) hexImage :(UIImage*) fullImage :(UIImage*) functionImage :(UIImage*) paramImage {
    self.cardList->add(hex, innerHex, hexImage, fullImage, functionImage, paramImage);
}

- (int) count {
    return self.cardList->count();
}

@end
