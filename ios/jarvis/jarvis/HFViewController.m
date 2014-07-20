//
//  FDViewController.m
//  FaceDetection
//
//  Created by Nikhil Srinivasan on 7/20/14.
//  Copyright (c) 2014 greylock hackfest. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#import "HFViewController.h"

@interface HFViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
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
        [output setSampleBufferDelegate:self queue:bufferQueue];
        if ([self.session canAddOutput:output])
            [self.session addOutput:output];
        
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy: CIDetectorAccuracyLow }];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.view.layer addSublayer:previewLayer];
    self.previewLayer = previewLayer;
    
    UIView *faceView = [[UIView alloc] init];
    faceView.backgroundColor = [UIColor redColor];
    [self.view addSubview:faceView];
    self.faceView = faceView;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawFeatures:features aperature:aperature];
    });
}

- (void)drawFeatures:(NSArray *)features aperature:(CGRect)aperature {
    for (CIFaceFeature *feature in features) {
        CGRect featureBounds = feature.bounds;
        featureBounds = CGRectMake(featureBounds.origin.y, featureBounds.origin.x, featureBounds.size.height, featureBounds.size.width);
        aperature = CGRectMake(aperature.origin.y, aperature.origin.x, aperature.size.height, aperature.size.width);
        
        CGRect relative = CGRectMake(featureBounds.origin.x / aperature.size.width, featureBounds.origin.y / aperature.size.height, featureBounds.size.width / aperature.size.width, featureBounds.size.height / aperature.size.height);
        
        CGRect previewBounds = self.previewLayer.bounds;
        CGFloat scale = (previewBounds.size.height / aperature.size.height);
        previewBounds = CGRectMake(aperature.origin.x * scale, aperature.origin.y * scale, aperature.size.width * scale, aperature.size.height * scale);
        
        CGRect face = CGRectMake(relative.origin.x * previewBounds.size.width, relative.origin.y * previewBounds.size.height, relative.size.width * previewBounds.size.width, relative.size.height * previewBounds.size.height);
        self.faceView.frame = face;
        
        NSLog(@"FEATURE %@", NSStringFromCGRect(feature.bounds));
    }
}

@end
