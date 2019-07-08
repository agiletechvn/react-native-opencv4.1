#import "RNOpenCvLibrary.h"
#import <React/RCTLog.h>

@implementation RNOpenCvLibrary

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

cv::CascadeClassifier faceCascade;
bool cascadeLoaded = false;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

RCT_EXPORT_METHOD(detect:(NSString *)imageURL resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];  
  cv::Mat matImage = [self convertUIImageToCVMat:image];
  
  ///2. detection
  NSString *faceCascadeName = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
  if(!cascadeLoaded){
    std::cout<<"loading ..";
    if( !faceCascade.load(std::string([faceCascadeName UTF8String]))){
      return reject(@"novalex.vn", @"--(!)Error loading\n", nil);
    }
    cascadeLoaded = true;
  }
  
  std::vector<cv::Rect> faces;
  faceCascade.detectMultiScale(matImage, faces);
  NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity: faces.size()];
  
  for( size_t i = 0; i < faces.size(); i++ )
  {
    NSDictionary *item = @{ @"x" : [NSNumber numberWithInt:faces[i].x],
                            @"y" : [NSNumber numberWithInt:faces[i].y],
                            @"width": [NSNumber numberWithInt:faces[i].width],
                            @"height": [NSNumber numberWithInt:faces[i].height] };
    
    [dataArray addObject:item];
  }
  
  resolve(dataArray);
}


- (cv::Mat)convertUIImageToCVMat:(UIImage *)image {
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  kCGImageAlphaNoneSkipLast |
                                                  kCGBitmapByteOrderDefault); // Bitmap info flags
  
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  
  return cvMat;
}

@end
