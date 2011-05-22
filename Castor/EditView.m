//
//  EditView.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/05/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditView.h"


@implementation EditView

@synthesize textView = _textView;
@synthesize letterCount = _letterCount;
@synthesize factory = _factory;
@synthesize roomId = _roomId;
@synthesize parentId = _parentId;
@synthesize targetEntry = _targetEntry;
@synthesize previousView = _previousView;

static const int MAX_LETTER = 140;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
               roomId:(NSNumber *)roomId 
             parentId:(NSNumber *)parentId 
          targetEntry:(EntryData *)targetEntry 
         previousView:(UIViewController <Reloadable> *)previousView 
              factory:(DataFactory *)factory
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.roomId = roomId;
        self.parentId = parentId;
        self.targetEntry = targetEntry;
        self.previousView = previousView;
        self.factory = factory;
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.letterCount = nil;
    self.factory = nil;
    self.roomId = nil;
    self.parentId = nil;
    self.targetEntry = nil;
    self.previousView = nil;
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
    NSLog(@"EditView loaded");
    if (self.targetEntry == nil) {
        self.title = @"Add Entry";
        self.letterCount.text = [NSString stringWithFormat:@"%d", MAX_LETTER];
    }
    else {
        self.title = @"Update Entry";
        self.textView.text = self.targetEntry.content;
        self.letterCount.text = [NSString stringWithFormat:@"%d", MAX_LETTER - [self.targetEntry.content length]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textView = nil;
    self.letterCount = nil;
    self.factory = nil;
    self.roomId = nil;
    self.parentId = nil;
    self.targetEntry = nil;
    self.previousView = nil;
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

//// UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int textcount = MAX_LETTER - ([textView.text length] + [text length] - range.length);
    if (textcount < 0) {
        self.letterCount.textColor=[UIColor redColor];
    }else{
        self.letterCount.textColor=[UIColor blackColor];
    }
    self.letterCount.text = [NSString stringWithFormat:@"%d", textcount];
    return YES;
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

//// IBAction
- (IBAction)postEntry:(id)sender
{
    if ([self.textView.text length] > MAX_LETTER) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setDelegate:self];
        [alert setMessage:@"140文字を越えています"];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        [alert release];
        return;
    }
    if (self.targetEntry == nil) {
        NSLog(@"add entry (parentId[%@])", self.parentId);
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self.factory addEntryText:self.textView.text roomId:self.roomId parentId:self.parentId sender:self];
        [self.previousView reload:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [pool release];
    }
    else {
        NSLog(@"edit entry (entryId[%@])", self.targetEntry.entryId);
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self.factory updateEntryText:self.textView.text roomId:self.roomId entryId:self.targetEntry.entryId sender:self];
        [self.previousView reload:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [pool release];
    }
}

- (IBAction)doneEntryEdit:(id)sender
{
    NSLog(@"done Entry editing");
    [self.textView resignFirstResponder];
}

@end
