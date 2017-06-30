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

+ (double) calculateSkew :(cv::Mat) src {
    cv::Mat img;
    src.copyTo(img);
    cv::Size size = img.size();
    cv::bitwise_not(img, img);
    std::vector<cv::Vec4i> lines;
    printf("Size: %d\n", size.width);
    cv::HoughLinesP(img, lines, 1, CV_PI/180, 10, size.width / 2.f, 10);
    cv::Mat disp_lines(size, CV_8UC1, cv::Scalar(0, 0, 0));
    double angle = 0.;
    unsigned long nb_lines = lines.size();
    for (unsigned long i = 0; i < nb_lines; ++i)
    {
        cv::line(disp_lines, cv::Point(lines[i][0], lines[i][1]),
                 cv::Point(lines[i][2], lines[i][3]), cv::Scalar(255, 0 ,0));
        angle += atan2((double)lines[i][3] - lines[i][1],
                       (double)lines[i][2] - lines[i][0]);
    }
    angle /= nb_lines; // mean angle, in radians.
    
    return angle * 180 / CV_PI;
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


+ (void) process :(UIImage *) image :(CardListWrapper *) cardListWrapper {
    cv::Mat src;
    cv::Mat gray;
    cv::Mat blur;
    cv::Mat thresholded;
    cv::Mat canny;
    cv::Mat kernel;
    cv::Mat erosion;
    cv::Mat closed;
    cv::Mat returnImage;
    cv::RNG rng(12345);
    
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Point> approx;
    
    std::vector<std::vector<cv::Point> > inner;
    std::vector<cv::Vec4i> innerHierarchy;
    std::vector<cv::Point> innerApprox;
    cv::Rect bound;
    
    UIImageToMat(image, src);
    
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
            
            cv::Mat hex(canny, bound);
            cv::Mat cardHex;
            hex.copyTo(cardHex);

            cv::Rect validInnerHex;
            
            cv::findContours(cardHex, inner, innerHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );

            for (int j = 0; j < inner.size(); j++) {
                cv::approxPolyDP(cv::Mat(inner[j]), innerApprox, cv::arcLength(cv::Mat(inner[j]), true)*0.02, true);
                
                // Skip small or non-convex objects
                if (std::fabs(cv::contourArea(inner[j])) < 200 || !cv::isContourConvex(innerApprox))
                    continue;
                
                cv::Rect innerHex = cv::boundingRect(inner[j]);
                
                float innerAspectRatio = float(innerHex.width)/innerHex.height;
                
                if (innerApprox.size() == 6 && innerAspectRatio > 0.8 && innerAspectRatio < 1.2) {
                    if (innerHex.width != bound.width && innerHex.height != bound.height) {
//                        printf("VALID HEX ASPECT: %f SIZE: %f\n\n", aspectRatio, cv::contourArea(contours[i]));
                        validInnerHex = innerHex;
                        break;
                    }
                }
            }
            
            if (validInnerHex.width == 0) {
                continue;
            }
            
            cv::Rect fullCardBound;
            fullCardBound.x = bound.x - bound.width * 1.25;
            fullCardBound.y = bound.y - bound.height * 4.75;
            fullCardBound.width = bound.width * 3.5;
            fullCardBound.height = bound.height * 6.25;
            
            cv::Mat full(src, fullCardBound);
            cv::Mat cardFull;
            full.copyTo(cardFull);

            cv::Rect functionBound;
            functionBound.x = bound.x + (bound.width * 0.26);
            functionBound.y = bound.y + (bound.height * 0.33);
            functionBound.width = bound.width - (bound.width * 0.54);
            functionBound.height = bound.height - (bound.height * 0.61);

            cv::Mat function(gray, functionBound);

            cv::Mat blurredFuction;
            cv::medianBlur(function, blurredFuction, 3);

            cv::Mat thresholdedFunction;
            cv::adaptiveThreshold(blurredFuction, thresholdedFunction, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 11, 2);
            
            cv::Mat rotated;
            double skew = [[self class] calculateSkew:thresholdedFunction];
            rotated = [[self class] deskew:thresholdedFunction angle:skew];

//            std::vector<std::vector<cv::Point> > functionContours;
//            std::vector<cv::Vec4i> functionHierarchy;
//
//            int maxX = 0, maxY = 0, minX = 0, minY = 0;
//
//            cv::Mat erodedFunction;
//            cv::Mat element = cv::getStructuringElement(MORPH_RECT, cv::Size(3, 3), cv::Point(1,1));
//            cv::erode(thresholdedFunction, erodedFunction, element);
//
//            cv::Mat cannyFunction;
//            cv::Canny(erodedFunction, cannyFunction, 80, 240, 3);
//
//            cv::findContours(erodedFunction, functionContours, functionHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
//            
//            printf("FUNCTION CONTOURS: %lu\n", functionContours.size());
//
//            /// Draw contours
//            Mat drawing = Mat::zeros( cannyFunction.size(), CV_8UC3 );
//            cv::drawContours(drawing, functionContours, -1, cv::Scalar(255,255,255), 2, 8, functionHierarchy, 0, cv::Point());
//            
//            for (int j = 0; j < functionContours.size(); j++) {
//                if (std::fabs(cv::contourArea(functionContours[j])) < 100) continue;
//                
//                printf("FUNCTION CONTOUR FOUND: %f\n", cv::contourArea(functionContours[j]));
//                
//                for (int k = 0; k < functionContours[j].size(); k++) {
//                    cv::Point p = functionContours[j][k];
//                    if (minX > p.x) minX = p.x;
//                    if (minY > p.y) minY = p.y;
//                    if (maxX < p.x) maxX = p.x;
//                    if (maxY < p.y) maxY = p.y;
//                }
//            }
//            printf("FUNCTION BOUNDS: %d, %d, %d, %d\n\n", minX, minY, maxX, maxY);
//
//            cv::Rect croppedFunctionBound;
//            croppedFunctionBound.x = minX + 5;
//            croppedFunctionBound.y = minY + 5;
//            croppedFunctionBound.width = maxX - minX - 5;
//            croppedFunctionBound.height = maxY - minY - 5;
//            
//            cv::Mat croppedFunction(thresholdedFunction, croppedFunctionBound);

            cv::Mat cardFunction;
            rotated.copyTo(cardFunction);
            
            
            
            cv::Rect paramBound;
            paramBound.x = bound.x - bound.width * 0.3;
            paramBound.y = bound.y - bound.height * 3;
            paramBound.width = bound.width * 1.5;
            paramBound.height = bound.height * 1.6;
            
            cv::Mat param(gray, paramBound);
            cv::Mat cardParam;
            param.copyTo(cardParam);

            CGRect innerHexRect = [[self class] CvRectToCgRect:validInnerHex];
            CGRect hexRect = [[self class] CvRectToCgRect:bound];
            
            [cardListWrapper add :hexRect :innerHexRect :MatToUIImage(cardHex) :MatToUIImage(cardFull) :MatToUIImage(cardFunction) :MatToUIImage(cardParam)];
          
            
//            cv::Mat thresholded;
//            cv::threshold(allAcceptable, thresholded, 100, 255, 0);
            
//            cv::Size allSize = allAcceptable.size();
            
//            if (allSize.width == 0) {
//                cropped.copyTo(allAcceptable);
//            } else {
//                cv::Mat all;
//                cv::hconcat(allAcceptable, cropped, all);
//                allAcceptable = all;
//            }
            
//            cv::Scalar color = cv::Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//            cv::drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        }
    }
    
    printf("CARDS: %d\n", cardListWrapper.count);
    
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
