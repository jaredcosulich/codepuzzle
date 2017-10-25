//
//  CardList.cpp
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#include "CardList.h"

struct Card {
    int rotation;
    CGRect fullRect;
    CGRect hexRect;
    CGRect innerHexRect;
    CGRect functionRect;
    CGRect paramRect;
};

bool roughlySame (int a, int b) {
    if (abs(a-b) < 10) return true;
    return false;
}

bool sameCard (Card cardA, Card cardB) {
    CGRect a = cardA.hexRect;
    CGRect b = cardB.hexRect;
    
    if (roughlySame(a.origin.x, b.origin.x) && roughlySame(a.origin.y, b.origin.y)) return true;

    if (a.origin.x < b.origin.x && a.origin.x + a.size.width > b.origin.x + b.size.width) {
        if (a.origin.y < b.origin.y && a.origin.y + a.size.height > b.origin.y + b.size.height) {
            return true;
        }
    }

    if (b.origin.x < a.origin.x && b.origin.x + b.size.width > a.origin.x + a.size.width) {
        if (b.origin.y < a.origin.y && b.origin.y + b.size.height > a.origin.y + a.size.height) {
            return true;
        }
    }

    return false;
}

bool sortFunction (Card cardA, Card cardB) {
    CGRect a = cardA.hexRect;
    CGRect b = cardB.hexRect;

    int aX = 0;
    if (a.origin.x + (a.size.width * 2) < b.origin.x) aX = 1;
    if (a.origin.x > b.origin.x + (b.size.width * 2)) aX = -1;

    int aY = 0;
    if (a.origin.y + (a.size.height * 4) < b.origin.y) aY = 1;
    if (a.origin.y > b.origin.y + (b.size.height * 4)) aY = -1;
    
    if (aY > 0) return true;
    if (aY == 0 && aX > 0) return true;
    return false;
}

CardList::CardList() {};

void CardList::clear() {
    cards.clear();
}

void CardList::printHex(int index) {
    CGRect hex = cards[index].hexRect;
    printf("HEX: X: %f Y: %f WIDTH: %f HEIGHT: %f\n\n", hex.origin.x, hex.origin.y, hex.size.width, hex.size.height);
//    printf("INR: X: %d Y: %d WIDTH: %d HEIGHT: %d\n\n", hex.innerX, hex.innerY, hex.innerWidth, hex.innerHeight);
}


double CardList::getRotation(int index) {
    return cards[index].rotation;
}

CGRect CardList::getFullRect(int index) {
    return cards[index].fullRect;
}

CGRect CardList::getHexRect(int index) {
    return cards[index].hexRect;
}

CGRect CardList::getInnerHexRect(int index) {
    return cards[index].innerHexRect;
}

CGRect CardList::getFunctionRect(int index) {
    return cards[index].functionRect;
}

CGRect CardList::getParamRect(int index) {
    return cards[index].paramRect;
}

void CardList::remove(int index) {
    cards.erase(cards.begin() + index);
}

void CardList::add(double rotation, CGRect fullRect, CGRect hexRect, CGRect innerHexRect, CGRect functionRect, CGRect paramRect) {
    Card c;
    c.rotation = rotation;
    c.fullRect = fullRect;
    c.hexRect = hexRect;
    c.innerHexRect = innerHexRect;
    c.functionRect = functionRect;
    c.paramRect = paramRect;
    
    cards.push_back(c);
    std::sort( cards.begin(), cards.end(), sortFunction );
    cards.erase( unique( cards.begin(), cards.end(), sameCard ), cards.end() );
}

int CardList::count() {
    int i = *new int((int) cards.size());
    return i;
}

