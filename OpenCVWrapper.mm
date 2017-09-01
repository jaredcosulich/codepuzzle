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

+ (cv::Mat) threshold :(cv::Mat) src {
    cv::Mat result;
    cv::threshold(src, result, 200, 255, 0);
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


+ (UIImage *) debug :(UIImage *) image {
    cv::Mat src;
    cv::Mat gray;
    cv::Mat canny;
    cv::Mat threshold;
    cv::Mat dilated;
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Point> approx;
    std::vector<std::vector<cv::Point>> hexagons;
    std::vector<std::vector<cv::Point>> innerHexagons;
    cv::Rect bound;
    
    UIImageToMat(image, src);
    
    gray = [[self class] color:src];
//    threshold = [[self class] threshold:gray];
    canny = [[self class] canny:gray];
    dilated = [[self class] dilate:canny];
    
    cv::findContours(dilated, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 400 || !cv::isContourConvex(approx))
            continue;
        
        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            hexagons.push_back(contours[i]);
            
            cv::Rect bound = boundingRect(contours[i]);
            
            cv::Mat hex(src, bound);
            
            cv::Rect validInnerHex;
            innerHexagons = [[self class] findHexagons:hex];
            
            double rotation = 0;
            double angle = 0;
            
            for (int j=0; j<innerHexagons.size(); ++j) {
                cv::Rect innerBound = cv::boundingRect(innerHexagons[j]);
                
                if (std::abs(innerBound.width - bound.width) > 3 && std::abs(innerBound.height - bound.height)) {
                    validInnerHex = innerBound;
                    
                    cv::Point p1(-1, 9999);
                    cv::Point p2(-1, 9999);
                    for (int c = 0; c<innerHexagons[j].size(); ++c) {
                        cv::Point corner = cvPoint(bound.x + innerHexagons[j][c].x, bound.y + innerHexagons[j][c].y);
                        
                        if (corner.y < p1.y || corner.y < p2.y) {
                            if (p2.y < p1.y) {
                                p1 = p2;
                            }
                            p2 = corner;
                        }
                        
                    }
                    if (p2.x < p1.x) {
                        cv::Point p3 = p1;
                        p1 = p2;
                        p2 = p3;
                    }

                    float distance = (float)(p2.x - p1.x);
                    float slope = ((float)(p2.y - p1.y)/distance);
                    angle = atan(slope);
                    rotation = (angle * 180 / CV_PI);
                    
//                    printf("DRAWING ROTATION: %lu\n", innerHexagons[j].size());
                    for (int c = 0; c<innerHexagons[j].size(); ++c) {
                        cv::Point corner = cvPoint(bound.x + innerHexagons[j][c].x, bound.y + innerHexagons[j][c].y);
                        cv::Scalar color = cv::Scalar(0,0,0);
                        cv::circle(dilated, corner, 1, color, 6, 8, 0);

                        int xOrigin = bound.x + (bound.size().width / 2);
                        int yOrigin = bound.y + (bound.size().height / 2);

                        int x = corner.x;
                        int y = corner.y;
                        
                        float s1 = sin(angle * -1);
                        float c1 = cos(angle * -1);
                        
                        // translate point back to origin:
                        x -= xOrigin;
                        y -= yOrigin;
                        
                        // rotate point
                        float xnew = x * c1 - y * s1;
                        float ynew = x * s1 + y * c1;
                        
                        // translate point back:
                        float xRotated = xnew + xOrigin;
                        float yRotated = ynew + yOrigin;
                        
//                        int xRotated = ((x - xOrigin) * cos(rotation)) - ((yOrigin - y) * sin(rotation)) + xOrigin;
//                        int yRotated = ((yOrigin - y) * cos(rotation)) - ((x - xOrigin) * sin(rotation)) + yOrigin;
//                        printf("rotation: %f, %d -> %f\n", rotation, corner.y, yRotated);
                        corner.x = xRotated;
                        corner.y = yRotated;
                        cv::Scalar color2 = cv::Scalar(200,0,200);
                        cv::circle(dilated, corner, 1, color2, 6, 8, 0);
                    }


//                    cv::Scalar color = cv::Scalar(200,200,0);
//                    cv::circle(dilated, p1, 1, color, 6, 8, 0);
//                    cv::circle(dilated, p2, 1, color, 6, 8, 0);
                    break;
                }
            }
        }
    }
    
    return MatToUIImage(dilated);
}

+ (std::vector<std::vector<cv::Point>>) findHexagons :(cv::Mat) src {
    cv::Mat gray;
    cv::Mat threshold;
    cv::Mat canny;
    cv::Mat dilated;
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<cv::Point> approx;
    std::vector<std::vector<cv::Point>> hexagons;
    cv::Rect bound;

    
    gray = [[self class] color:src];
    //    threshold = [[self class] threshold:gray];
    canny = [[self class] canny:gray];
    dilated = [[self class] dilate:canny];
    
    cv::findContours(dilated, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    for (int i = 0; i < contours.size(); i++) {
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 400 || !cv::isContourConvex(approx))
            continue;
        
        bound = cv::boundingRect(contours[i]);
        float aspectRatio = float(bound.width)/bound.height;
        
        if (approx.size() == 6 && aspectRatio > 0.8 && aspectRatio < 1.2) {
            hexagons.push_back(approx);
        }
    }
    return hexagons;
}


+ (void) process :(UIImage *) image :(CardListWrapper *) cardListWrapper {
    std::vector<std::vector<cv::Point>> hexagons;
    std::vector<std::vector<cv::Point>> innerHexagons;
    double angle = 0;
    double rotation = 0;
    
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

        cv::Rect rotatedBound;
        cv::Rect validInnerHex;
        innerHexagons = [[self class] findHexagons:hex];

        for (int j=0; j<innerHexagons.size(); ++j) {
            cv::Rect innerBound = cv::boundingRect(innerHexagons[j]);
            
            if (std::abs(innerBound.width - bound.width) > 3 && std::abs(innerBound.height - bound.height)) {
                validInnerHex = innerBound;

                cv::Point p1(-1, 9999);
                cv::Point p2(-1, 9999);
                for (int c = 0; c<innerHexagons[j].size(); ++c) {
                    cv::Point corner = cvPoint(bound.x + innerHexagons[j][c].x, bound.y + innerHexagons[j][c].y);

                    if (corner.y < p1.y || corner.y < p2.y) {
                        if (p2.y < p1.y) {
                            p1 = p2;
                        }
                        p2 = corner;
                    }
                }
                if (p2.x < p1.x) {
                    cv::Point p3 = p1;
                    p1 = p2;
                    p2 = p3;
                }
                
                float distance = (float)(p2.x - p1.x);
                
                float slope = ((float)(p2.y - p1.y)/distance);
                angle = atan(slope);
                rotation = (angle * 180 / CV_PI);
//                printf("Rotation: %f, Bound: %dx%d \n ", rotation, bound.width, bound.height);

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
                    
//                    printf("Point: %d, %d -> %f, %f\n", x, y, xRotated, yRotated);
                }
                
                rotatedBound = boundingRect(innerHexagons[j]);
//                printf("Rotation: %f, Bound: %dx%d \n\n", angle, rotatedBound.width, rotatedBound.height);

                break;
            }
        }
        
        if (validInnerHex.width == 0) {
            continue;
        }
        
        
//        cv::Rect fullCardBound;
//        fullCardBound.x = bound.x - (bound.width * 2.75);
//        fullCardBound.y = bound.y - (bound.height * 5.5);
//        fullCardBound.width = bound.width * 6.5;
//        fullCardBound.height = bound.height * 8;
        cv::Rect fullCardBound;
        fullCardBound.x = rotatedBound.x - (rotatedBound.width * 1.25);
        fullCardBound.y = rotatedBound.y - (rotatedBound.height * 5);
        fullCardBound.width = rotatedBound.width * 3.6;
        fullCardBound.height = rotatedBound.height * 6.5;
        
        if (fullCardBound.x < 0) fullCardBound.x = 0;
        if (fullCardBound.y < 0) fullCardBound.y = 0;
        if (fullCardBound.x + fullCardBound.width > src.size().width) {
            fullCardBound.width = src.size().width - fullCardBound.x;
        }
        if (fullCardBound.y + fullCardBound.height > src.size().height) {
            fullCardBound.height = src.size().height - fullCardBound.y;
        }
        
//        cv::Mat full(src, fullCardBound);
//        cv::Mat cardFull;
//        full.copyTo(cardFull);
        
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
        functionBound.x = rotatedBound.x + (rotatedBound.width * 0.26);
        functionBound.y = rotatedBound.y + (rotatedBound.height * 0.28);
        functionBound.width = rotatedBound.width - (rotatedBound.width * 0.5);
        functionBound.height = rotatedBound.height - (rotatedBound.height * 0.6);
//        functionBound.x = rotatedBound.x + (rotatedBound.width * 0.2);
//        functionBound.y = rotatedBound.y + (rotatedBound.height * 0.2);
//        functionBound.width = rotatedBound.width - (rotatedBound.width * 0.4);
//        functionBound.height = rotatedBound.height - (rotatedBound.height * 0.4);

//        cv::Mat function(src, functionBound);
//        cv::Mat unsizedCardFunction;
//        cv::Mat cardFunction;
//        function.copyTo(cardFunction);
//        cv::resize(unsizedCardFunction, cardFunction, cv::Size(200, (200 * (functionBound.height / functionBound.width))));

        cv::Rect paramBound;
        paramBound.x = rotatedBound.x - rotatedBound.width * 0.55;
        paramBound.y = rotatedBound.y - rotatedBound.height * 3.4;
        paramBound.width = rotatedBound.width * 2.2;
        paramBound.height = rotatedBound.height * 1.8;

//        printf("5 (%d, %d) %d x %d - %d x %d\n", paramBound.x, paramBound.y, paramBound.width, paramBound.height, rotated.size().width, rotated.size().height);
//        cv::Mat param(src, paramBound);
//        cv::Mat cardParam;
//        param.copyTo(cardParam);

        CGRect fullRect = [[self class] CvRectToCgRect:fullCardBound];
        CGRect hexRect = [[self class] CvRectToCgRect:rotatedBound];
        CGRect innerHexRect = [[self class] CvRectToCgRect:validInnerHex];
        CGRect functionRect = [[self class] CvRectToCgRect:functionBound];
        CGRect paramRect = [[self class] CvRectToCgRect:paramBound];
        
        [cardListWrapper add :rotation :fullRect :hexRect :innerHexRect :functionRect :paramRect];
    }
    
//    cardListWrapper.analyzedImage = MatToUIImage(analyzed);

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

+ (UIImage *) floodFill :(UIImage *) image :(int) x :(int) y :(int) red :(int) green :(int) blue {
    cv::Mat mat4Image;
    cv::Mat matImage;
    UIImageToMat(image, mat4Image);
    
    cv::cvtColor(mat4Image, matImage, CV_BGRA2RGB);
    
    cv::floodFill(matImage, cv::Point(x, y), CV_RGB(255,0,0));
    
    return MatToUIImage(matImage);
}



@end
