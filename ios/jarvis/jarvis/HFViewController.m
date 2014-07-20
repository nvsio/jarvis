//
//  FDViewController.m
//  FaceDetection
//
//  Created by Nikhil Srinivasan on 7/20/14.
//  Copyright (c) 2014 greylock hackfest. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreImage/CoreImage.h>
#import "ReKognitionSDK.h"
#import "HFViewController.h"

@interface HFViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, weak) UIView *faceView;
@property (nonatomic, strong) CIDetector *faceDetector;

@end

static dispatch_queue_t bufferQueue = nil;

@implementation HFViewController

+ (void)load {
    bufferQueue = dispatch_queue_create("buffer.video.face.detection", DISPATCH_QUEUE_SERIAL);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.session = [[AVCaptureSession alloc] init];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if ([self.session canAddInput:input])
            [self.session addInput:input];
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        output.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA) };
        [output setSampleBufferDelegate:self queue:bufferQueue];
        if ([self.session canAddOutput:output])
            [self.session addOutput:output];
        
        self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([self.session canAddOutput:self.imageOutput] )
            [self.session addOutput:self.imageOutput];
        
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy: CIDetectorAccuracyLow }];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetDetecting) userInfo:nil repeats:YES];
    
    isDetecting = false;
    
    NSArray *animationArray=[NSArray arrayWithObjects:
                    [UIImage imageNamed:@"blur1.png"],
                    [UIImage imageNamed:@"blur2.png"],
                    [UIImage imageNamed:@"blur3.png"],
                    [UIImage imageNamed:@"blur4.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    [UIImage imageNamed:@"blur5.png"],
                    [UIImage imageNamed:@"blur6.png"],
                    [UIImage imageNamed:@"blur7.png"],
                    [UIImage imageNamed:@"blur8.png"],
                    nil];
    UIImageView *animationView=[[UIImageView alloc]initWithFrame:CGRectMake(-120, -140,320, 320)];
    animationView.backgroundColor=[UIColor clearColor];
    animationView.animationImages = animationArray;
    animationView.animationDuration=2.5;
    animationView.animationRepeatCount=0;
    [animationView startAnimating];
    
    
    name = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 320)];
    name.numberOfLines = 1;
    name.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    name.adjustsFontSizeToFitWidth = YES;
    name.minimumScaleFactor = 10.0f/12.0f;
    name.clipsToBounds = YES;
    name.backgroundColor = [UIColor clearColor];
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentLeft;
    
    bio = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 320, 320)];
    bio.numberOfLines = 1;
    bio.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    bio.adjustsFontSizeToFitWidth = YES;
    bio.minimumScaleFactor = 10.0f/12.0f;
    bio.clipsToBounds = YES;
    bio.backgroundColor = [UIColor clearColor];
    bio.textColor = [UIColor whiteColor];
    bio.textAlignment = NSTextAlignmentLeft;

    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.view.layer addSublayer:previewLayer];
    self.previewLayer = previewLayer;
    
    UIView *faceView = [[UIView alloc] init];
    [faceView addSubview:animationView];
    [faceView addSubview:name];
    [faceView addSubview:bio];
    [self.view addSubview:faceView];
    self.faceView = faceView;
}

- (void)resetDetecting {
    isDetecting = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

- (void)viewDidLayoutSubviews {
    self.previewLayer.frame = self.view.layer.bounds;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge_transfer id)attachments];
    
	NSDictionary *options = @{ CIDetectorImageOrientation: @6 };
	NSArray *features = [self.faceDetector featuresInImage:image options:options];
    
    CMFormatDescriptionRef descriptor = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect aperature = CMVideoFormatDescriptionGetCleanAperture(descriptor, false);
    
//    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
//    vImage_Buffer src;
//    src.height = CVPixelBufferGetHeight(pixelBuffer);
//    src.width = CVPixelBufferGetWidth(pixelBuffer);
//    src.rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer);
//    src.data = CVPixelBufferGetBaseAddress(pixelBuffer);
//
//    NSMutableData *imageData = [NSMutableData dataWithLength:CVPixelBufferGetDataSize(pixelBuffer)];
//    vImage_Buffer dest;
//    dest.height = src.height;
//    dest.width = src.width;
//    dest.rowBytes = src.rowBytes;
//    dest.data = imageData.mutableBytes;
//
//    const uint8_t map[4] = { 3, 2, 1, 0 };
//    vImagePermuteChannels_ARGB8888(&src, &dest, map, kvImageNoFlags);
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
//    CGImageRef imageRef = CGImageCreate(dest.width, dest.height, 8, 32, dest.rowBytes, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, false, kCGRenderingIntentDefault);
//    [self detectFacesWithImage:[UIImage imageWithCGImage:imageRef]];
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(dataProvider);
//    CGColorSpaceRelease(colorSpace);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawFeatures:features aperature:aperature];
    });
}

- (void)drawFeatures:(NSArray *)features aperature:(CGRect)aperature {
    CIFaceFeature *feature = features.firstObject;

    if (!feature) {
        self.faceView.hidden = YES;
        return;
    }
    
    if (!isDetecting) {
        isDetecting = true;
        [self detectFaces];
    }

    CGRect featureBounds = feature.bounds;
    featureBounds = CGRectMake(featureBounds.origin.y, featureBounds.origin.x, featureBounds.size.height, featureBounds.size.width);
    aperature = CGRectMake(aperature.origin.y, aperature.origin.x, aperature.size.height, aperature.size.width);
    
    CGRect relative = CGRectMake(featureBounds.origin.x / aperature.size.width, featureBounds.origin.y / aperature.size.height, featureBounds.size.width / aperature.size.width, featureBounds.size.height / aperature.size.height);
    
    CGRect previewBounds = self.previewLayer.bounds;
    CGFloat scale = (previewBounds.size.height / aperature.size.height);
    previewBounds = CGRectMake(aperature.origin.x * scale, aperature.origin.y * scale, aperature.size.width * scale, aperature.size.height * scale);
    
    CGRect face = CGRectMake(relative.origin.x * previewBounds.size.width, relative.origin.y * previewBounds.size.height, relative.size.width * previewBounds.size.width, relative.size.height * previewBounds.size.height);

    self.faceView.frame = face;
    self.faceView.hidden = NO;
}

-(void)changeName: (NSString*) new_name{
    name.text = new_name;
    
}

- (void)detectFaces {
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:[self.imageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *result = [ReKognitionSDK RKFaceRecognize:image scale:1.0f nameSpace:@"default" userID:@"default"];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *detection = [dictionary[@"face_detection"] firstObject];
            NSArray *matches = [detection objectForKey:@"matches"];
            NSDictionary *match = matches.firstObject;
            
            NSString *name2 = match[@"tag"];
            NSString *cofindenceString = match[@"score"];
            NSLog(cofindenceString);
            float confidence = [cofindenceString floatValue];
            
            
            NSString *message = [NSString stringWithFormat:@"%@", name2];
            
            if (confidence > 0.55) {
             
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self changeName:message];
                    if ([[name text] isEqualToString:@"Greg_James"]) {
                        bio.text = @"Nextdoor, Engineering Manager";
                    }
                    else if ([[name text] isEqualToString:@"James_Tamplin"]) {
                        bio.text = @"Firebase, CEO";
                    }
                    else if ([[name text] isEqualToString:@"Raphael_Lee"]) {
                        bio.text = @"Airbnb, Engineering Manager";
                    }
                    else if ([[name text] isEqualToString:@"Ganesh_Ramanarayanan"]) {
                        bio.text = @"Pure Storage, Software Engineer";
                    }
                    else if ([[name text] isEqualToString:@"Evan_Tana"]) {
                        bio.text = @"Sparks, CEO";
                    }
                    else if ([[name text] isEqualToString:@"Dan_Pupius"]) {
                        bio.text = @"Medium, Director of Engineering";
                    }
                    else if ([[name text] isEqualToString:@"Alex_DeNeui"]) {
                        bio.text = @"Stealth Startup, Founder";
                    }
                    else if ([[name text] isEqualToString:@"Chunyan_Song"]) {
                        bio.text = @"Gemshare, CTO";
                    }
                    else if ([[name text] isEqualToString:@"Lawrence_Bruhmuller"]) {
                        bio.text = @"ClearSlide, VPE";
                    }
                    else if ([[name text] isEqualToString:@"Eric_Bieschke"]) {
                        bio.text = @"Pandora, Chief Scientist & VP of Playlists";
                    }
                    else if ([[name text] isEqualToString:@"Megha_Bangalore"]) {
                        bio.text = @"Sumo Logic, Sr Software Engineer";
                    }
                    else if ([[name text] isEqualToString:@"Matt_Trotter"]) {
                        bio.text = @"SVB, Managing Director";
                    }
                    else if ([[name text] isEqualToString:@"David_Mandelin"]) {
                        bio.text = @"Edmodo, Director of Engineering";
                    }
                    else if ([[name text] isEqualToString:@"Prachi_Gupta"]) {
                        bio.text = @"LinkedIn, Sr Engineering Manager";
                    }
                    else if ([[name text] isEqualToString:@"Joaquin_Candela"]) {
                        bio.text = @"Facebook, Director of Engineering";
                    }
                    else if ([[name text] isEqualToString:@"Jean-Denis_Greze"]) {
                        bio.text = @"Dropbox, Engineering Manager";
                    }
                    else if ([[name text] isEqualToString:@"Chintan_Parikh"]) {
                        bio.text = @"Student, Georgia Tech";
                    }
                    else if ([[name text] isEqualToString:@"Jay_Deuskar"]) {
                        bio.text = @"Student, Georgia Tech";
                    }
                    else if ([[name text] isEqualToString:@"Nikhil_Srinivasan"]) {
                        bio.text = @"Student, RPI";
                    }
                    else
                        bio.text = @"N/A";
                    
                    name.text = [[name text] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    

                });
            }
            
            });
        }];
                       
}

@end
