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
    UIImage* getHexImage(int);
    UIImage* getFullImage(int);
    UIImage* getFunctionImage(int);
    UIImage* getParamImage(int);
    void add(CGRect, CGRect, UIImage*, UIImage*, UIImage*, UIImage*);
    int count();
    
private:
    std::vector<Card> cards;
};

#endif /* CardList_mm */
