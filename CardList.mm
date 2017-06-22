//
//  CardList.cpp
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#include "CardList.h"

struct Card {
    int x;
    int y;
    UIImage* full;
    UIImage* function;
    UIImage* param;
};

bool sameCard (Card a, Card b) { return (a.x == b.x && a.y == b.y); }

CardList::CardList() {};

UIImage* CardList::getFull(int index) {
    return cards[index].full;
}

UIImage* CardList::getFunction(int index) {
    return cards[index].function;
}

UIImage* CardList::getParam(int index) {
    return cards[index].param;
}

void CardList::add(int x, int y, UIImage* full, UIImage* function, UIImage* param) {
    Card c;
    c.x = x;
    c.y = y;
    c.full = full;
    c.function = function;
    c.param = param;
    cards.push_back(c);
    cards.erase( unique( cards.begin(), cards.end(), sameCard ), cards.end() );
}

int* CardList::count() {
    int* i = new int((int) cards.size());
    return i;
}

