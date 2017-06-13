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

using namespace cv;
using namespace std;

@implementation OpenCVWrapper

+ (UIImage *) canny: (UIImage *) image {
    cv::Mat src;
    cv::Mat gray;
    cv::Mat blur;
    cv::Mat canny;
    cv::Mat kernel;
    cv::Mat closed;
    cv::RNG rng(12345);
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Point> approx;
    cv::Rect bound;
    
    UIImageToMat(image, src);
    
    cv::cvtColor(src, gray, CV_BGR2GRAY);
//    cv::blur(gray, blur, cv::Size(3, 3));
    cv::Canny(gray, canny, 150, 240, 3);

//    kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(10, 10));
//    cv::morphologyEx(canny, closed, cv::MORPH_CLOSE, kernel);
    
    cv::findContours(canny, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );

    cv::Mat drawing = cv::Mat::zeros( src.size(), CV_8UC3 );

    int acceptableCount = 0;
    
    cv::Mat allAcceptable;

    int maxHeight = 0;
    
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 500 || !cv::isContourConvex(approx))
            continue;
        
        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            if (bound.height > maxHeight) {
                maxHeight = bound.height;
            }
        }
    }
    
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 500 || !cv::isContourConvex(approx))
            continue;

        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;

        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            ++acceptableCount;
            printf("Hexagon Found %lu %f \n", approx.size(), cv::contourArea(contours[i]));
            printf("ASPECT RATIO: %f \n\n", aspectRatio);

            bound.height = maxHeight;
            cv::Mat cropped(src, bound);

            cv::Size allSize = allAcceptable.size();
            
            if (allSize.width == 0) {
                cropped.copyTo(allAcceptable);
            } else {
                cv::Mat all;
                cv::hconcat(allAcceptable, cropped, all);
                allAcceptable = all;
            }
            
//            cv::Scalar color = cv::Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//            cv::drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        }
    }
    
    printf("Hexagons Found %d \n", acceptableCount);
    
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
    
    return MatToUIImage(allAcceptable);
}



@end
