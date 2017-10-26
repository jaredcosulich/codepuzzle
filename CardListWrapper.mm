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

//- (void) setAnalyzedImage :(UIImage*) image {
//    self.analyzedImage = image;
//}
//
//- (UIImage *) getAnalyzedImage {
//    return self.analyzedImage;
//}

- (void) printHex :(int) index {
    return self.cardList->printHex(index);
}

- (double) getRotation :(int) index {
    return self.cardList->getRotation(index);
}


- (CGRect) getFullRect :(int) index {
    return self.cardList->getFullRect(index);
}

- (CGRect) getHexRect :(int) index {
    return self.cardList->getHexRect(index);
}

- (CGRect) getInnerHexRect :(int) index {
    return self.cardList->getInnerHexRect(index);
}

- (CGRect) getFunctionRect :(int) index {
    return self.cardList->getFunctionRect(index);
}

- (CGRect) getParamRect :(int) index {
    return self.cardList->getParamRect(index);
}

- (void) remove :(int) index {
    self.cardList->remove(index);
}

- (void) add :(double) hexCenterX :(double) hexCenterY :(double) hexWidth :(double) hexHeight :(double) rotation  {
    self.cardList->add(hexCenterX, hexCenterY, hexWidth, hexHeight, rotation);
}

- (int) count {
    return self.cardList->count();
}

@end
