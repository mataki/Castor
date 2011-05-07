//
//  RoomView.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/04/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomView.h"


@implementation RoomView

@synthesize factory = _factory;
@synthesize room = _room;

@synthesize entryTable = _entryTable;
@synthesize entryList = _entryList;

@synthesize target = _target;
@synthesize selectors = _selectors;

@synthesize indicator = _indicator;

- (void)alertException:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setMessage:message];
    [alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (void)moveToCommentViewWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"move to CommentView");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CommentView *commentView = [[[CommentView alloc] initWithNibName:@"CommentView" bundle:nil] autorelease];
    commentView.factory = self.factory;
    commentView.originEntry = originEntry;
    [self.navigationController pushViewController:commentView animated:YES];
    [pool release];
}

- (void)viewAttachmentWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"View Attachment [%@]", originEntry.entryId);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([@"Text" isEqualToString:originEntry.attachmentType]) {
        NSLog(@"move to LongTextView");
        LongTextView *longTextView = [[[LongTextView alloc] initWithNibName:@"LongTextView" bundle:nil] autorelease];
        longTextView.entry = originEntry;
        [self.navigationController pushViewController:longTextView animated:YES];
    }
    else if ([@"Image" isEqualToString:originEntry.attachmentType]) {
        NSLog(@"move to ImageView");
        ImageView *imageView = [[[ImageView alloc] initWithNibName:@"ImageView" bundle:nil] autorelease];
        imageView.factory = self.factory;
        imageView.entry = originEntry;
        [self.navigationController pushViewController:imageView animated:YES];
    }
    else if ([@"Link" isEqualToString:self.target.attachmentType]) {
        NSLog(@"open safari with url[%@]", originEntry.attachmentURL);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.target.attachmentURL]];
    }
    [pool release];
}

- (void)updateEntryWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"update entry [%@]", originEntry.entryId);
}

- (void)deleteEntryWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"delete entry [%@]", originEntry.entryId);
}

- (void)cancelWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"cancel entry [%@]", originEntry.entryId);
}

- (void)startIndicator:(id)sender
{
    CGRect viewSize = self.view.bounds;
    [self.indicator setFrame:CGRectMake(viewSize.size.width/2-25, viewSize.size.height/2-25, 50, 50)];
    [self.indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)reloadEntryListInBackground:(id)arg
{
    NSLog(@"reload entryList[%@] In Background", self.room.roomId);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.entryList = [self.factory getRoomEntryListByRoomId:self.room.roomId page:_page sender:self];
    [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // <<load next page>>用
    [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // 最後の空白行用
    [self.entryTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.indicator stopAnimating];
    [pool release];
}

- (IBAction)callSetting:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"move to SettingView");
    SettingView *settingView = [[[SettingView alloc] initWithNibName:@"SettingView" bundle:nil] autorelease];
    settingView.factory = self.factory;
    [self.navigationController pushViewController:settingView animated:YES];
    [pool release];
}

- (IBAction)editEntry:(id)sender
{
    NSLog(@"editEntry");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"move to EditView");
    EditView *editView = [[[EditView alloc] initWithNibName:@"EditView" bundle:nil] autorelease];
    editView.factory = self.factory;
    editView.roomId = self.room.roomId;
    editView.originEntry = nil;
    editView.previousView = self;
    [self.navigationController pushViewController:editView animated:YES];
    [pool release];
}

- (IBAction)reload:(id)sender
{
    NSLog(@"reloadRoom[%@]", self.room.roomId);
    [self performSelector:@selector(startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(reloadEntryListInBackground:) withObject:nil];
}

- (void)nextPage:(id)sender
{
    _page++;
    NSLog(@"nextPage [%d]", _page);
    [self performSelector:@selector(startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(reloadEntryListInBackground:) withObject:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _page = 1;
        self.selectors = [[NSMutableArray alloc] init];
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:self.indicator];
    }
    return self;
}

- (void)dealloc
{
    self.factory = nil;
    self.room = nil;
    
    self.entryList = nil;
    self.entryTable = nil;
    
    self.target = nil;
    self.selectors = nil;
    self.indicator = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section) {
        case 0: return self.room.roomName;
        default: return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entryList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.entryList count] - 2 ) {
        return [ViewUtil getEntryCellHeight:self.view.window.screen.bounds.size entry:[self.entryList objectAtIndex:indexPath.row] portrate:_portrate];
    }
    else {
        return 40;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([self.entryList count] <= indexPath.row) return cell;
    
    if (indexPath.row < [self.entryList count] - 2) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [cell.contentView addSubview:[ViewUtil getEntryCellView:self.view.window.screen.bounds.size entry:[self.entryList objectAtIndex:indexPath.row] portrate:_portrate]];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        [pool release];
    }
    else if (indexPath.row == [self.entryList count] - 2) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [cell.contentView addSubview:[ViewUtil getNextPageCellView:self.view.window.screen.bounds.size portrate:_portrate]];
        [pool release];
    }

    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"RoomView %d row clicked",indexPath.row);
    if (indexPath.row < [self.entryList count] - 2) {
        [self.selectors removeAllObjects];
        if (self.target != nil) self.target = nil;
        self.target = [self.entryList objectAtIndex:indexPath.row];
        UIActionSheet *menu = [[UIActionSheet alloc] init];
        [menu setDelegate:self];
        [menu addButtonWithTitle:@"View Comments"];
        [self.selectors addObject:@"moveToCommentViewWithOriginEntry:"];
        [menu addButtonWithTitle:@"Update"];
        [self.selectors addObject:@"updateEntryWithOriginEntry:"];
        [menu addButtonWithTitle:@"Delete"];
        [self.selectors addObject:@"deleteEntryWithOriginEntry:"];
        if ([@"Text" isEqualToString:self.target.attachmentType] || [@"Image" isEqualToString:self.target.attachmentType] || [@"Link" isEqualToString:self.target.attachmentType]) {
            [menu addButtonWithTitle:@"View Attachment"];
            [self.selectors addObject:@"viewAttachmentWithOriginEntry:"];
        }
        [menu addButtonWithTitle:@"Cancel"];
        [self.selectors addObject:@"cancelWithOriginEntry:"];
        [menu showInView:self.view];
        [menu release];
    }
    else if (indexPath.row == [self.entryList count] - 2) {
        [self nextPage:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory button clicked[%d]", indexPath.row);
    [self performSelector:@selector(moveToCommentViewWithOriginEntry:) withObject:[self.entryList objectAtIndex:indexPath.row]];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet button clicked[%d]", buttonIndex);
    [self performSelector:NSSelectorFromString([self.selectors objectAtIndex:buttonIndex]) withObject:self.target];
    self.target = nil;
    [self.selectors removeAllObjects];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"roomView[%@] loaded", self.room.roomId);
    self.title = @"Room";
    if (self.factory == nil) {
        self.factory = [[DataFactory alloc] init];
    }
    [self performSelector:@selector(startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(reloadEntryListInBackground:) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.factory = nil;
    self.room = nil;
    
    self.entryList = nil;
    self.entryTable = nil;
    
    self.target = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        _portrate = NO;
        [self.entryTable reloadData];
    }
    else if (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown || interfaceOrientation == UIDeviceOrientationPortrait) {
        _portrate = YES;
        [self.entryTable reloadData];
    }
    return YES;
}

@end
