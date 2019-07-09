#import "RNOpenCvLibrary.h"
#import <React/RCTLog.h>

#import "DlibWrapper.h"

@interface RNOpenCvLibrary ()

// non-pointer attribute with synthesize
@property (assign) BOOL prepared;

@end

@implementation RNOpenCvLibrary {
  cv::CascadeClassifier faceCascade;
  DlibWrapper* dlibWrapper;
}


- (instancetype)init {
  self = [super init];
  if (self) {
    [self prepare];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup{
  return NO;
}

- (void)prepare {
  
  if (self.prepared) {
    return;
  }
  
  NSString *faceCascadeName = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
  
  if(faceCascade.load(std::string([faceCascadeName UTF8String]))){
    self.prepared = YES;
    
    NSString *resnetModelFileName = [[NSBundle mainBundle] pathForResource:@"dlib_face_recognition_resnet_model_v1" ofType:@"dat"];
    
    // create instance then setup
    dlibWrapper = [[DlibWrapper alloc] initWithModel: resnetModelFileName];
  }

}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

RCT_EXPORT_METHOD(detect:(NSString *)imageURL resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];  
  cv::Mat matImage = [self convertUIImageToCVMat:image];
  
  
  if(!self.prepared){
      return reject(@"novalex.vn", @"--(!)Error loading\n", nil);
  }
  
  std::vector<cv::Rect> faces;
  faceCascade.detectMultiScale(matImage, faces);
  NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity: faces.size()];
  
  for( size_t i = 0; i < faces.size(); i++ )
  {
    
    
    auto faceMat = matImage(faces[i]);
    cv::cvtColor(faceMat, faceMat, cv::COLOR_BGR2GRAY);
    
    if (faceMat.rows != 150 || faceMat.cols != 150) {
      cv::resize(faceMat, faceMat, cv::Size(150, 150));
    }
    
    auto faceChip = [dlibWrapper imageFromMat:faceMat];
    auto descriptor = [dlibWrapper getFaceDescriptor: faceChip];
    
    
    NSDictionary *item = @{ @"x" : [NSNumber numberWithInt:faces[i].x],
                            @"y" : [NSNumber numberWithInt:faces[i].y],
                            @"width": [NSNumber numberWithInt:faces[i].width],
                            @"height": [NSNumber numberWithInt:faces[i].height],
                            @"descriptor": descriptor
                            };
    
    [dataArray addObject:item];
  }
  
  resolve(dataArray);
}


- (cv::Mat)convertUIImageToCVMat:(UIImage *)image {
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
  CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
  
  // check whether the UIImage is greyscale already
  if (numberOfComponents == 1){
    cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
  }
  
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,             // Pointer to backing data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  bitmapInfo);              // Bitmap info flags
  
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  
  return cvMat;
}

@end
