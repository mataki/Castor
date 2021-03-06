//
//  ImageView.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/05/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"

@interface ImageView (Private)
- (void)_startIndicator:(id)sender;
- (void)_loadAttachmentImageInBackground:(id)arg;
@end

@implementation ImageView

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize indicator = _indicator;
@synthesize factory = _factory;
@synthesize entry = _entry;

static const float MAX_SCALE = 5.0;
static const float MIN_SCALE = 1.0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
                entry:(EntryData *)entry 
              factory:(DataFactory *)factory
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.entry = entry;
        self.factory = factory;
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:self.indicator];
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.scrollView = nil;
    self.indicator = nil;
    self.factory = nil;
    self.entry = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.factory == nil) {
        NSLog(@"DataFactory disappeared");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Homeへ移動します" 
                                                            message:@"メモリ不足のためキャッシュが破棄されました"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        [alertView release];
        HomeView *homeView = [[[HomeView alloc] initWithNibName:@"HomeView" bundle:nil
                                                        factory:[[DataFactory alloc] init]] autorelease];
        [self.navigationController pushViewController:homeView animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ImageView loaded");
    self.title = @"Image";
    self.scrollView.maximumZoomScale = MAX_SCALE;
    self.scrollView.minimumZoomScale = MIN_SCALE;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(_startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(_loadAttachmentImageInBackground:) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.scrollView = nil;
    self.indicator = nil;
    self.factory = nil;
    self.entry = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        _portrate = NO;
    }
    else if (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown || interfaceOrientation == UIDeviceOrientationPortrait) {
        _portrate = YES;
    }
    return YES;
}

//// UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {  
    return self.imageView;  
} 

//// Alertable
- (void)alertException:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setMessage:message];
    [alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

//// Private
- (void)_startIndicator:(id)sender
{
    CGRect viewSize = self.view.bounds;
    [self.indicator setFrame:CGRectMake(viewSize.size.width/2-25, viewSize.size.height/2-25, 50, 50)];
    [self.indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)_loadAttachmentImageInBackground:(id)arg
{
    NSLog(@"load Attachment Image In Background");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [self.factory getAttachmentImageByEntryData:self.entry sender:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.indicator stopAnimating];
    [pool release];
}

@end
