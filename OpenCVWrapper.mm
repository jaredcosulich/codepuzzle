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

+ (UIImage *) individualProcess :(UIImage *) image :(int) process {
    cv::Mat src;
    cv::Mat result;
    UIImageToMat(image, src);
    
    switch (process) {
        case 0:
            result = [[self class] color:src];
            break;

        case 1:
            result = [[self class] canny:src];
            break;

        case 2:
            result = [[self class] dilate:src];
            break;
            
        case 3:
            result = [[self class] threshold:src];
            break;

        case 4:
            result = [[self class] sharpen:src];
            break;
            
        default:
            result = src;
            break;
    }
    
    return MatToUIImage(result);
}


+ (cv::Mat) canny :(cv::Mat) src {
    cv::Mat result;
    cv::Canny(src, result, 80, 240, 3);
    return result;
}

+ (cv::Mat) color :(cv::Mat) src {
    cv::Mat result;
    cv::cvtColor(src, result, CV_BGR2GRAY);
    return result;
}

+ (cv::Mat) blur :(cv::Mat) src {
    cv::Mat result;
    cv::blur(src, result, cv::Size(3,3));
    return result;
}

+ (cv::Mat) threshold :(cv::Mat) src {
    cv::Mat result;
//    cv::threshold(src, result, 200, 255, 0);
    cv::threshold(src, result, 50, 255, 0);
    return result;
}

+ (cv::Mat) dilate :(cv::Mat) src {
    cv::Mat result;
    
    Mat element = getStructuringElement( cv::MORPH_RECT,
                                        //cv::Size(5, 5),
                                        cv::Size(2, 2),
                                        cv::Point(0,0) );

    cv::dilate(src, result, element);
    return result;
}

+ (cv::Mat) sharpen :(cv::Mat) src {
    cv::Mat result;
    
    cv::GaussianBlur(src, result, cv::Size(5, 5), 3);
    cv::addWeighted(src, 1.5, result, -0.5, 0, result);
    return result;
}

+ (float) calculateYRotation :(cv::Point) p1 :(cv::Point) p2 {
    float distance = (float)(p2.x - p1.x);
    float slope = ((float)(p2.y - p1.y)/distance);
    float angle = atan(slope);
    return (angle * 180 / CV_PI);
}

+ (float) calculateXRotation :(cv::Point) p1 :(cv::Point) p2 {
    float distance = (float)(p2.y - p1.y);
    float slope = ((float)(p2.x - p1.x)/distance);
    float angle = atan(slope);
    return (angle * -180 / CV_PI);
}

+ (UIImage *) debug :(UIImage *) image :(int) stage  :(double) scale {
    cv::Mat src;
    cv::Mat gray;
    cv::Mat blur;
    cv::Mat canny;
    cv::Mat threshold;
    cv::Mat dilated;
    cv::Mat sharpened;
    cv::Mat processed;
    cv::Mat debug;
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Vec4i> debugHierarchy;
    std::vector<cv::Point> approx;
    std::vector<std::vector<cv::Point>> hexagons;
    std::vector<std::vector<cv::Point>> innerHexagons;
    cv::Rect bound;
    
    cv::Mat unsized;
    UIImageToMat(image, unsized);
    
    cv::resize(unsized, src, cv::Size(), scale, scale);

    cv::cvtColor(src, debug, CV_BGRA2BGR);

    gray = [[self class] color:src];
    blur = [[self class] blur:gray];
    canny = [[self class] canny:blur];
    
    processed = canny;
    cv::findContours(processed, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    int drawn = 0;
    
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 400 || !cv::isContourConvex(approx))
            continue;

        if (stage == 0) {
            cv::Scalar color = cv::Scalar(0,255,0);
            cv::drawContours(debug, contours, i, color, 2, 8, debugHierarchy, 0, cv::Point());
        }

        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            hexagons.push_back(contours[i]);

            if (stage == 1) {
                cv::Scalar color = cv::Scalar(255,0,0);
                cv::drawContours(debug, contours, i, color, 2, 8, debugHierarchy, 0, cv::Point());
            }

            cv::Rect bound = boundingRect(contours[i]);
            
            cv::Mat hex(src, bound);
            
            cv::Rect validInnerHex;
            innerHexagons = [[self class] findHexagons:hex :debug :(stage == 2)];
            
            double rotation = 0;
            double angle = 0;
            
            for (int j=0; j<innerHexagons.size(); ++j) {
                cv::Rect innerBound = cv::boundingRect(innerHexagons[j]);
                
                std::vector<float> rotations;
                if (std::abs(innerBound.width - bound.width) > (bound.width / 15.0) && std::abs(innerBound.height - bound.height)) {
                    validInnerHex = innerBound;

                    int left = -1;
                    int right = -1;
                    cv::Point leftPoint(9999, 0);
                    cv::Point rightPoint(-1, 0);
                    for (int c = 0; c<innerHexagons[j].size(); ++c) {
                        cv::Point corner = cvPoint(bound.x + innerHexagons[j][c].x, bound.y + innerHexagons[j][c].y);
                        
                        cv::Scalar color = cv::Scalar(255,255,255);
                        cv::circle(processed, corner, 1, color, 6, 8, 0);
                        
                        if (corner.x < leftPoint.x) {
                            leftPoint = corner;
                            left = c;
                        }
                        
                        if (corner.x > rightPoint.x) {
                            rightPoint = corner;
                            right = c;
                        }
                    }
                    
                    std::vector<cv::Point> ordered;
                    for (int c = 0; c<innerHexagons[j].size(); ++c) {
                        int index = c + left;
                        if (index >= innerHexagons[j].size()) {
                            index = index - int(innerHexagons[j].size());
                        }
                        ordered.push_back(innerHexagons[j][index]);
                    }
                    
                    drawn += 1;
                    
                    rotations.push_back([[self class] calculateYRotation :ordered[0] :ordered[3]]);
                    rotations.push_back([[self class] calculateYRotation :ordered[1] :ordered[2]]);
                    rotations.push_back([[self class] calculateYRotation :ordered[5] :ordered[4]]);
                    rotations.push_back([[self class] calculateXRotation :ordered[5] :ordered[1]]);
                    rotations.push_back([[self class] calculateXRotation :ordered[4] :ordered[2]]);
                
                    std::sort (rotations.begin(), rotations.end());
                    rotation = (rotations[1] + rotations[2] + rotations[3]) / 3;
                    angle = (rotation * CV_PI) / 180;
                }
            }
        }
    }
    
    if (stage == -1) {
        return MatToUIImage(processed);
    } else {
        return MatToUIImage(debug);
    }
}

+ (std::vector<std::vector<cv::Point>>) findHexagons :(cv::Mat) src {
    cv::Mat debug;
    return [[self class] findHexagons:src :debug :false];
}

+ (std::vector<std::vector<cv::Point>>) findHexagons :(cv::Mat) src :(cv::Mat) debug :(BOOL) doDebug {
    cv::Mat gray;
    cv::Mat blur;
    cv::Mat threshold;
    cv::Mat canny;
    cv::Mat dilated;
    cv::Mat sharpened;
    cv::Mat processed;
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Vec4i> debugHierarchy;
    std::vector<cv::Point> approx;
    std::vector<std::vector<cv::Point>> hexagons;
    cv::Rect bound;

    gray = [[self class] color:src];
    blur = [[self class] blur:gray];
    canny = [[self class] canny:blur];

    processed = canny;
    
    cv::findContours(processed, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 400 || !cv::isContourConvex(approx))
            continue;
        
        if (doDebug) {
            cv::Scalar color = cv::Scalar(0,0,255);
            cv::drawContours(debug, contours, i, color, 2, 8, debugHierarchy, 0, cv::Point());
        }
        
        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            hexagons.push_back(approx);
        }
    }
    return hexagons;
}


+ (void) process :(UIImage *) image :(CardListWrapper *) cardListWrapper :(double) scale {
    std::vector<std::vector<cv::Point>> hexagons;
    std::vector<std::vector<cv::Point>> innerHexagons;
    double angle = 0;
    double rotation = 0;
    
    cv::Mat src;
    if (scale < 1.0) {
        cv::Mat unsized;
        UIImageToMat(image, unsized);
        cv::resize(unsized, src, cv::Size(), scale, scale);
    } else {
        UIImageToMat(image, src);
    }

    hexagons = [[self class] findHexagons:src];
    
    for (int i = 0; i < hexagons.size(); ++i) {
        cv::Rect bound = boundingRect(hexagons[i]);
        
        cv::Mat hex(src, bound);

        cv::Rect rotatedBound;
        cv::Rect validInnerHex;
        innerHexagons = [[self class] findHexagons:hex];

        for (int j=0; j<innerHexagons.size(); ++j) {
            std::vector<float> rotations;

            cv::Rect innerBound = cv::boundingRect(innerHexagons[j]);
            
            if (std::abs(innerBound.width - bound.width) > (bound.width / 15.0) && std::abs(innerBound.height - bound.height)) {
                validInnerHex = innerBound;

                int left = -1;
                int right = -1;
                cv::Point leftPoint(9999, 0);
                cv::Point rightPoint(-1, 0);
                for (int c = 0; c<innerHexagons[j].size(); ++c) {
                    cv::Point corner = cvPoint(bound.x + innerHexagons[j][c].x, bound.y + innerHexagons[j][c].y);

                    if (corner.x < leftPoint.x) {
                        leftPoint = corner;
                        left = c;
                    }
                    
                    if (corner.x > rightPoint.x) {
                        rightPoint = corner;
                        right = c;
                    }
                }
                
                std::vector<cv::Point> ordered;
                for (int c = 0; c<innerHexagons[j].size(); ++c) {
                    int index = c + left;
                    if (index >= innerHexagons[j].size()) {
                        index = index - int(innerHexagons[j].size());
                    }
                    ordered.push_back(innerHexagons[j][index]);
                }
                
                rotations.push_back([[self class] calculateYRotation :ordered[0] :ordered[3]]);
                rotations.push_back([[self class] calculateYRotation :ordered[1] :ordered[2]]);
                rotations.push_back([[self class] calculateYRotation :ordered[5] :ordered[4]]);
                rotations.push_back([[self class] calculateXRotation :ordered[5] :ordered[1]]);
                rotations.push_back([[self class] calculateXRotation :ordered[4] :ordered[2]]);
                
                auto func=[](float a, float b) { return abs(a) < abs(b); };
                std::sort(rotations.begin(), rotations.end(), func);

                rotation = (rotations[0] + rotations[1] + rotations[2]) / 3;
                angle = (rotation * CV_PI) / 180;

                int xOrigin = bound.x + (bound.size().width / 2);
                int yOrigin = bound.y + (bound.size().height / 2);
                for (int c = 0; c<innerHexagons[j].size(); ++c) {
                    int x = bound.x + innerHexagons[j][c].x;
                    int y = bound.y + innerHexagons[j][c].y;
                    
                    float s1 = sin(angle * -1);
                    float c1 = cos(angle * -1);
                    
                    x -= xOrigin;
                    y -= yOrigin;
                    
                    float xnew = x * c1 - y * s1;
                    float ynew = x * s1 + y * c1;
                    
                    float xRotated = xnew + xOrigin;
                    float yRotated = ynew + yOrigin;
                    
                    innerHexagons[j][c].x = xRotated;
                    innerHexagons[j][c].y = yRotated;
                }
                
                rotatedBound = boundingRect(innerHexagons[j]);

                break;
            }
        }
        
        if (validInnerHex.width == 0) {
            continue;
        }
        
        if (scale < 1) {
            rotatedBound.x = rotatedBound.x / scale;
            rotatedBound.y = rotatedBound.y / scale;
            rotatedBound.width = rotatedBound.width / scale;
            rotatedBound.height = rotatedBound.height / scale;
        }
                
        double hexCenterX = (rotatedBound.x + (rotatedBound.width / 2));
        double hexCenterY = (rotatedBound.y + (rotatedBound.height / 2));
        [cardListWrapper add :hexCenterX :hexCenterY :rotatedBound.width :rotatedBound.height :rotation];
    }
    
    printf("CARDS: %d\n", cardListWrapper.count);
}

+ (UIImage *) floodFill :(UIImage *) image :(int) x :(int) y :(int) red :(int) green :(int) blue {
    cv::Mat mat4Image;
    cv::Mat matImage;
    UIImageToMat(image, mat4Image);
    
    cv::cvtColor(mat4Image, matImage, CV_BGRA2RGB);
    
    cv::floodFill(matImage, cv::Point(x, y), CV_RGB(255,0,0));
    
    return MatToUIImage(matImage);
}



@end
