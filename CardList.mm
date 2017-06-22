//
//  CardList.cpp
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#include "CardList.h"

struct Card {
    UIImage* full;
    UIImage* function;
    UIImage* param;
};

CardList::CardList() {
    length = 0;
};

UIImage* CardList::getFull(int index) {
    return cards[index].full;
}

UIImage* CardList::getFunction(int index) {
    return cards[index].function;
}

UIImage* CardList::getParam(int index) {
    return cards[index].param;
}


void CardList::add(UIImage* full, UIImage* function, UIImage* param) {
    Card c;
    c.full = full;
    c.function = function;
    c.param = param;
    cards.push_back(c);
    ++length;
}

