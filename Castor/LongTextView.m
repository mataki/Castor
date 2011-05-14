//
//  LongTextView.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/05/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LongTextView.h"


@implementation LongTextView

@synthesize textView = _textView;
@synthesize entry = _entry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Nothing to do
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.entry = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"LongTextView loaded");
    self.title = @"Long Text";
    self.textView.text = self.entry.attachmentText;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textView = nil;
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

@end
