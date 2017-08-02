//
//  OpenCVWrapper.m
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <stdio.h>
#import <stdlib.h>
#import <ctime>

#import "OpenCVWrapper.h"
#import "CardListWrapper.h"

using namespace cv;
using namespace std;

@implementation OpenCVWrapper

+ (CGRect) CvRectToCgRect : (cv::Rect) rect {
    CGFloat originX(rect.x);
    CGFloat originY(rect.y);
    CGPoint origin;
    origin.x = originX;
    origin.y = originY;
    
    CGFloat sizeWidth(rect.width);
    CGFloat sizeHeight(rect.height);
    CGSize size;
    size.width = sizeWidth;
    size.height = sizeHeight;
    
    CGRect cgRect;
    cgRect.origin = origin;
    cgRect.size = size;
    return cgRect;
}

+ (UIImage *) cannify :(UIImage *) image {
    cv::Mat src;
    cv::Mat gray;
    cv::Mat canny;
    
    UIImageToMat(image, src);
    
    cv::cvtColor(src, gray, CV_BGR2GRAY);
    cv::Canny(gray, canny, 80, 240, 3);
    return MatToUIImage(canny);
}

+ (cv::Mat) deskew :(cv::Mat) img angle:(double) angle {
    cv::bitwise_not(img, img);
    
    std::vector<cv::Point> points;
    cv::Mat_<uchar>::iterator it = img.begin<uchar>();
    cv::Mat_<uchar>::iterator end = img.end<uchar>();
    for (; it != end; ++it)
        if (*it)
            points.push_back(it.pos());
    
    cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));
    
    cv::Mat rot_mat = cv::getRotationMatrix2D(box.center, angle, 1);
    
    cv::Mat rotated;
    cv::warpAffine(img, rotated, rot_mat, img.size(), cv::INTER_CUBIC);
    
//    cv::Size box_size = box.size;
//    if (box.angle < -45.)
//        std::swap(box_size.width, box_size.height);
//    cv::Mat cropped;
//    cv::getRectSubPix(rotated, box_size, box.center, cropped);
    cv::bitwise_not(rotated, rotated);
    return rotated;
}

+ (cv::Mat) rotate :(cv::Mat) image :(double) rotation {
//    cv::Mat thresholdedImage;
//    cv::adaptiveThreshold(image, thresholdedImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 11, 2);
    
    cv::Mat rotated;
    rotated = [[self class] deskew:image angle:rotation];
    
//    cv::Rect cropBound;
//    cropBound.x = 3;
//    cropBound.y = 0;
//    cropBound.width = rotated.size().width - 3;
//    cropBound.height = rotated.size().height - 3;
//    
//    cv::Mat crop(rotated, cropBound);
//    cv::Mat cropped;
//    crop.copyTo(cropped);
    return rotated;
}

+ (std::vector<std::vector<cv::Point>>) findHexagons :(cv::Mat) src {
    cv::Mat gray;
    cv::Mat canny;
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Point> approx;
    std::vector<std::vector<cv::Point>> hexagons;
    cv::Rect bound;

    cv::cvtColor(src, gray, CV_BGR2GRAY);
    cv::Canny(gray, canny, 80, 240, 3);
    
    cv::findContours(canny, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 400 || !cv::isContourConvex(approx))
            continue;
        
        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            hexagons.push_back(contours[i]);
        }
    }
    return hexagons;
}


+ (void) process :(UIImage *) image :(CardListWrapper *) cardListWrapper {
    std::vector<std::vector<cv::Point>> hexagons;
    std::vector<std::vector<cv::Point>> innerHexagons;
    std::vector<std::vector<cv::Point>> rotatedHexagons;
    std::vector<int> rotations;
    
    cv::Mat analyzed;
//    cv::Mat unsized;
    cv::Mat src;
    UIImageToMat(image, src);
//    cv::resize(unsized, src, cv::Size(), 0.5, 0.5);
    //    src.copyTo(analyzed);

    hexagons = [[self class] findHexagons:src];
    
    printf("Hexagons: %lu found\n ", hexagons.size());

    for (int i = 0; i < hexagons.size(); ++i) {
        cv::Rect bound = boundingRect(hexagons[i]);
        
        cv::Mat hex(src, bound);

        cv::Rect validInnerHex;
        innerHexagons = [[self class] findHexagons:hex];
        
        for (int j=0; j<innerHexagons.size(); ++j) {
            cv::Rect innerBound = cv::boundingRect(innerHexagons[j]);
            
            if (innerBound.width != bound.width && innerBound.height != bound.height) {
                validInnerHex = innerBound;
                break;
            }
        }
        
        if (validInnerHex.width == 0) {
            continue;
        }
        
        CGRect innerHexRect = [[self class] CvRectToCgRect:validInnerHex];
        CGRect hexRect = [[self class] CvRectToCgRect:bound];
        
//        cv::Point p1(9999, -1);
//        cv::Point p2(-1, -1);
//        for (int c = 0; c<hexagons[i].size(); ++c) {
//            if (hexagons[i][c].x < p1.x) {
//                p1 = hexagons[i][c];
//            }
//            if (hexagons[i][c].x > p2.x) {
//                p2 = hexagons[i][c];
//            }
//        }
//
//        float distance = (float)(p2.x - p1.x);
//        
//        float slope = ((float)(p2.y - p1.y)/distance);
//        double rotation = (atan(slope) * 180 / CV_PI);
//
//        cv::Rect fullCardBound;
//        fullCardBound.x = bound.x - (bound.width * 2.75);
//        fullCardBound.y = bound.y - (bound.height * 5.5);
//        fullCardBound.width = bound.width * 6.5;
//        fullCardBound.height = bound.height * 8;
        cv::Rect fullCardBound;
        fullCardBound.x = bound.x - (bound.width * 1.5);
        fullCardBound.y = bound.y - (bound.height * 4.6);
        fullCardBound.width = bound.width * 4.2;
        fullCardBound.height = bound.height * 6.1;
        
        if (fullCardBound.x < 0) fullCardBound.x = 0;
        if (fullCardBound.y < 0) fullCardBound.y = 0;
        if (fullCardBound.x + fullCardBound.width > src.size().width) {
            fullCardBound.width = src.size().width - fullCardBound.x;
        }
        if (fullCardBound.y + fullCardBound.height > src.size().height) {
            fullCardBound.height = src.size().height - fullCardBound.y;
        }
        
        cv::Mat full(src, fullCardBound);
        cv::Mat cardFull;
        full.copyTo(cardFull);
        
//        clock_t start;
//        double diff;
//        start = clock();

//        cv::Mat rotated = [[self class] rotate :cardFull :rotation];

//        diff = ( std::clock() - start ) / (double)CLOCKS_PER_SEC;
//        printf("CLOCK: %d: %f seconds\n ", i, diff);
        
//        rotatedHexagons = [[self class] findHexagons:rotated];
//
//        int largestIndex = -1;
//        double largestArea = -1;
//        for (int r=0; r<rotatedHexagons.size(); ++r) {
//            double area = cv::boundingRect(rotatedHexagons[r]).area();
//            if (largestArea < area) {
//                largestArea = area;
//                largestIndex = r;
//            }
//        }
//        
//        cv::Rect hexBound = cv::boundingRect(rotatedHexagons[largestIndex]);
//
//        cv::Mat rotatedHex(rotated, hex);
//        cv::Mat cardHex;
//        rotatedHex.copyTo(cardHex);
//        
//        cv::Rect rotatedFullCardBound;
//        rotatedFullCardBound.x = hex.x - (hex.width * 1.1);
//        rotatedFullCardBound.y = hex.y - (hex.height * 4.5);
//        rotatedFullCardBound.width = hex.width * 3.2;
//        rotatedFullCardBound.height = hex.height * 5.75;
//        
//        if (rotatedFullCardBound.x < 0) rotatedFullCardBound.x = 0;
//        if (rotatedFullCardBound.y < 0) rotatedFullCardBound.y = 0;
//        if (rotatedFullCardBound.x + rotatedFullCardBound.width > rotated.size().width) {
//            rotatedFullCardBound.width = rotated.size().width - rotatedFullCardBound.x;
//        }
//        if (rotatedFullCardBound.y + rotatedFullCardBound.height > rotated.size().height) {
//            rotatedFullCardBound.height = rotated.size().height - rotatedFullCardBound.y;
//        }
//        
//        cv::Mat rotatedFull(rotated, rotatedFullCardBound);
//        cv::Mat rotatedCardFull;
//        rotatedFull.copyTo(rotatedCardFull);
//        rotatedCardFull.copyTo(analyzed);
        
        cv::Rect functionBound;
        functionBound.x = bound.x + (bound.width * 0.2);
        functionBound.y = bound.y + (bound.height * 0.2);
        functionBound.width = bound.width - (bound.width * 0.4);
        functionBound.height = bound.height - (bound.height * 0.4);

        cv::Mat function(src, functionBound);
//        cv::Mat unsizedCardFunction;
        cv::Mat cardFunction;
        function.copyTo(cardFunction);
//        cv::resize(unsizedCardFunction, cardFunction, cv::Size(200, (200 * (functionBound.height / functionBound.width))));

        cv::Rect paramBound;
        paramBound.x = bound.x - bound.width * 0.4;
        paramBound.y = bound.y - bound.height * 3;
        paramBound.width = bound.width * 1.75;
        paramBound.height = bound.height * 1.6;

//        printf("5 (%d, %d) %d x %d - %d x %d\n", paramBound.x, paramBound.y, paramBound.width, paramBound.height, rotated.size().width, rotated.size().height);
        cv::Mat param(src, paramBound);
        cv::Mat cardParam;
        param.copyTo(cardParam);

        int rotation = 0;
        CGRect fullRect = [[self class] CvRectToCgRect:fullCardBound];
        
        [cardListWrapper add :rotation :fullRect :hexRect :innerHexRect :MatToUIImage(hex) :MatToUIImage(cardFull) :MatToUIImage(cardFunction) :MatToUIImage(cardParam)];
    }
    
    cardListWrapper.analyzedImage = MatToUIImage(analyzed);

    printf("CARDS: %d\n", cardListWrapper.count);
    
//    for (int i=0; i<cardListWrapper.count; ++i) {
//        double rotation = [cardListWrapper getRotation:i];
//        
//        UIImage* function = [cardListWrapper getFunctionImage:i];
//        [cardListWrapper setFunctionImage :i :[[self class] rotate:function :rotation]];
//
////        UIImage* full = [cardListWrapper getFullImage:i];
////        [cardListWrapper setFullImage :i :[[self class] rotate:full :rotation]];
//    }
    
//    printf("Hexagons Found %d \n", acceptableCount);
    
    // Crop the full image to that image contained by the rectangle myROI
    // Note that this doesn't copy the data
//    cv::Mat croppedRef(drawing, bound);
    
//    cv::Mat cropped;
    // Copy the data into new matrix
//    croppedRef.copyTo(cropped);
    
    /// Draw contours
//    for( int i = 0; i < contours.size(); ++i ) {
//        cv::Scalar color = cv::Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        cv::drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
//    }
    
//    return MatToUIImage(returnImage);
}


@end
