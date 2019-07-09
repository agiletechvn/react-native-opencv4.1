//
//  DlibWrapper.m
//  reactNativeOpencvTutorial
//
//  Created by Thanh Tu on 7/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>

@implementation DlibWrapper {  
  anet_type net;
}

- (instancetype)initWithModel: (NSString *)resnetModelFileName {
  self = [super init];
  if (self) {
    std::string resnetModelFileNameCString = [resnetModelFileName UTF8String];
    dlib::deserialize(resnetModelFileNameCString) >> net;
  }
  return self;
}


- (dlib::matrix<dlib::rgb_pixel>)imageFromMat:(cv::Mat)matImage  {
  
  dlib::matrix<dlib::rgb_pixel> img;
  dlib::assign_image(img, dlib::cv_image<unsigned char>(matImage));
  
  return img;
  
}

- (NSArray *)getFaceDescriptor:(dlib::matrix<dlib::rgb_pixel> &)img {
    
  auto descriptor = net(img);
  
  NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity: descriptor.size()];
  
  for (unsigned int r = 0; r < descriptor.nr(); r += 1) {
    // loop over all the columns
    for (unsigned int c = 0; c < descriptor.nc(); c += 1) {
      // do something here
      [dataArray addObject:[NSNumber numberWithFloat: descriptor(r,c)]];
    }
  }
  
  return dataArray;
  
}


@end
