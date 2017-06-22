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

- (UIImage *) getFull :(int) index {
    return self.cardList->getFull(index);
}

- (UIImage *) getFunction :(int) index {
    return self.cardList->getFunction(index);
}

- (UIImage *) getParam :(int) index {
    return self.cardList->getParam(index);
}

- (void) add :(int) x :(int) y :(UIImage*) full :(UIImage*) function :(UIImage*) param {
    self.cardList->add(x, y, full, function, param);
}

- (int *) count {
    return self.cardList->count();
}

@end
