//
//  CardList.mm
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#ifndef CardList_mm
#define CardList_mm

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <stdio.h>
#include <vector>

struct Card;

class CardList
{
public:
    CardList();
    void clear();
    void printHex(int);
    double getRotation(int);
    CGRect getFullRect(int);
    CGRect getHexRect(int);
    CGRect getInnerHexRect(int);
    CGRect getFunctionRect(int);
    CGRect getParamRect(int);
    
    void remove(int);

    void add(double, CGRect, CGRect, CGRect, CGRect, CGRect);
    int count();
    
private:
    std::vector<Card> cards;
};

#endif /* CardList_mm */
