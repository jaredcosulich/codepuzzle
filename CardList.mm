//
//  CardList.cpp
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#include "CardList.h"

struct Hex {
    int x;
    int y;
    int width;
    int height;
    int innerX;
    int innerY;
    int innerWidth;
    int innerHeight;
    double rotation;
    UIImage* image;
};

struct Card {
    Hex hex;
    UIImage* full;
    UIImage* function;
    UIImage* param;
};

bool roughlySame (int a, int b) {
    if (abs(a-b) < 3) return true;
    return false;
}

bool sameCard (Card a, Card b) {
    if (roughlySame(a.hex.x, b.hex.x) && roughlySame(a.hex.y, b.hex.y)) return true;
    if (a.hex.x < b.hex.innerX && a.hex.x + a.hex.width > b.hex.innerX + b.hex.innerWidth) {
        if (a.hex.y < b.hex.innerY && a.hex.y + a.hex.height > b.hex.innerY + b.hex.innerHeight) {
            return true;
        }
    }
    return false;
}

bool sortFunction (Card a, Card b) {
    int aX = 0;
    if (a.hex.x + (a.hex.width * 2) < b.hex.x) aX = 1;
    if (a.hex.x > b.hex.x + (b.hex.width * 2)) aX = -1;

    int aY = 0;
    if (a.hex.y + (a.hex.height * 4) < b.hex.y) aY = 1;
    if (a.hex.y > b.hex.y + (b.hex.height * 4)) aY = -1;
    
    if (aY > 0) return true;
    if (aY == 0 && aX > 0) return true;
    return false;
}

CardList::CardList() {};

void CardList::clear() {
    cards.clear();
}

void CardList::printHex(int index) {
    Hex hex = cards[index].hex;
    printf("HEX: X: %d Y: %d WIDTH: %d HEIGHT: %d\n\n", hex.x, hex.y, hex.width, hex.height);
    printf("INR: X: %d Y: %d WIDTH: %d HEIGHT: %d\n\n", hex.innerX, hex.innerY, hex.innerWidth, hex.innerHeight);
}

UIImage* CardList::getHexImage(int index) {
    return cards[index].hex.image;
}

UIImage* CardList::getFullImage(int index) {
    Hex h = cards[index].hex;
//    printf("x: %u, y: %u, width: %u, height: %u\n", h.x, h.y, h.width, h.height);
    return cards[index].full;
}

UIImage* CardList::getFunctionImage(int index) {
    return cards[index].function;
}

void CardList::setFunctionImage(int index, UIImage* functionImage) {
    Card card = cards[index];
    card.function = functionImage;
    cards[index] = card;
}

void CardList::setFullImage(int index, UIImage* fullImage) {
    Card card = cards[index];
    card.full = fullImage;
    cards[index] = card;
}

UIImage* CardList::getParamImage(int index) {
    return cards[index].param;
}

double CardList::getRotation(int index) {
    return cards[index].hex.rotation;
}

void CardList::add(double rotation, CGRect hex, CGRect innerHex, UIImage* hexImage, UIImage* fullImage, UIImage* functionImage, UIImage* paramImage) {
    Hex h;
    h.x = hex.origin.x;
    h.y = hex.origin.y;
    h.width = hex.size.width;
    h.height = hex.size.height;
    
    h.innerX = hex.origin.x + innerHex.origin.x;
    h.innerY = hex.origin.y + innerHex.origin.y;
    h.innerWidth = innerHex.size.width;
    h.innerHeight = innerHex.size.height;
    
    h.rotation = rotation;
    
    h.image = hexImage;
    
    Card c;
    c.hex = h;
    c.full = fullImage;
    c.function = functionImage;
    c.param = paramImage;
    
    cards.push_back(c);
    std::sort( cards.begin(), cards.end(), sortFunction );
    cards.erase( unique( cards.begin(), cards.end(), sameCard ), cards.end() );
}

int CardList::count() {
    int i = *new int((int) cards.size());
    return i;
}

