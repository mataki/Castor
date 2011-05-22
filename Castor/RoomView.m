//
//  RoomView.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/04/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomView.h"

@interface RoomView (Private)
- (void)_startIndicator:(id)sender;
- (void)_reloadEntryListInBackground:(id)arg;
- (void)_nextPage:(id)sender;
- (void)_moveToCommentViewWithOriginEntry:(EntryData *)originEntry;
- (void)_updateEntryWithOriginEntry:(EntryData *)originEntry;
- (void)_deleteEntryWithOriginEntry:(EntryData *)originEntry;
- (void)_viewAttachmentWithOriginEntry:(EntryData *)originEntry;
- (void)_cancelWithOriginEntry:(EntryData *)originEntry;
@end

@implementation RoomView

@synthesize entryTable = _entryTable;
@synthesize entryList = _entryList;
@synthesize factory = _factory;
@synthesize room = _room;
@synthesize target = _target;
@synthesize willDelete = _willDelete;
@synthesize selectors = _selectors;
@synthesize indicator = _indicator;
@synthesize cellBuilder = _cellBuilder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
                 room:(RoomData *)room 
              factory:(DataFactory *)factory
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _page = 1;
        self.room = room;
        self.factory = factory;
        self.entryList = [self.factory getRoomEntryListFromCache:self.room.roomId];
        [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // <<load next page>>用
        [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // 最後の空白行用
        self.selectors = [[NSMutableArray alloc] init];
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:self.indicator];
        self.cellBuilder = [[CellBuilder alloc] initWithDataFactory:self.factory];
    }
    return self;
}

- (void)dealloc
{
    self.entryList = nil;
    self.entryTable = nil;
    self.factory = nil;
    self.room = nil;
    self.target = nil;
    self.willDelete = nil;
    self.selectors = nil;
    self.indicator = nil;
    self.cellBuilder = nil;
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
    NSLog(@"RoomView Will appear");
    [self.entryTable deselectRowAtIndexPath:[self.entryTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"roomView[%@] loaded", self.room.roomId);
    self.title = @"Room";
    [self performSelector:@selector(_startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(_reloadEntryListInBackground:) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.entryList = nil;
    self.entryTable = nil;
    self.factory = nil;
    self.room = nil;
    self.target = nil;
    self.willDelete = nil;
    self.selectors = nil;
    self.indicator = nil;
    self.cellBuilder = nil;
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

//// UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.cellBuilder getRoomHeaderView:self.room
                                        target:nil 
                                        action:nil
                                       section:section
                                      portrate:_portrate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entryList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.entryList count] - 2 ) {
        return [self.cellBuilder getEntryCellHeight:[self.entryList objectAtIndex:indexPath.row] portrate:_portrate];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    if ([self.entryList count] <= indexPath.row) return cell;
    
    if (indexPath.row < [self.entryList count] - 2) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [cell.contentView addSubview:[self.cellBuilder getEntryCellView:[self.entryList objectAtIndex:indexPath.row] portrate:_portrate]];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        [pool release];
    }
    else if (indexPath.row == [self.entryList count] - 2) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [cell.contentView addSubview:[self.cellBuilder getNextPageCellView:_portrate]];
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
        
        // View Commentsボタンは必ず表示
        [menu addButtonWithTitle:@"View Comments"];
        [self.selectors addObject:@"_moveToCommentViewWithOriginEntry:"];
        
        // Updateボタンの表示判定
        if (self.room.admin || [self.room.myId intValue] == [self.target.participationId intValue]) {
            [menu addButtonWithTitle:@"Update"];
            [self.selectors addObject:@"_updateEntryWithOriginEntry:"];
        }
        
        // Deleteボタンの表示判定(RoomViewのエントリは全てrootエントリ)
        if (self.room.admin || [self.room.myId intValue] == [self.target.participationId intValue]) {
            [menu addButtonWithTitle:@"Delete"];
            [self.selectors addObject:@"_deleteEntryWithOriginEntry:"];
        }
        
        // View Attachmentボタンの表示判定
        if ([@"Text" isEqualToString:self.target.attachmentType] || [@"Image" isEqualToString:self.target.attachmentType] || [@"Link" isEqualToString:self.target.attachmentType]) {
            [menu addButtonWithTitle:@"View Attachment"];
            [self.selectors addObject:@"_viewAttachmentWithOriginEntry:"];
        }
        
        // Cancelボタンは必ず表示
        [menu addButtonWithTitle:@"Cancel"];
        [self.selectors addObject:@"_cancelWithOriginEntry:"];
        
        
        [menu showInView:self.view];
        [menu release];
    }
    else if (indexPath.row == [self.entryList count] - 2) {
        [self _nextPage:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory button clicked[%d]", indexPath.row);
    [self performSelector:@selector(_moveToCommentViewWithOriginEntry:) withObject:[self.entryList objectAtIndex:indexPath.row]];
}

//// UIAlertView Callback
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            NSLog(@"delete entry [%@]", self.willDelete.entryId);
            [self.factory deleteEntryByEntryId:self.willDelete.entryId roomId:self.room.roomId sender:self];
            [self performSelector:@selector(_startIndicator:) withObject:self];
            [self performSelectorInBackground:@selector(_reloadEntryListInBackground:) withObject:nil];
            break;
    }
}

//// UIActionSheet Callback
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet button clicked[%d]", buttonIndex);
    [self performSelector:NSSelectorFromString([self.selectors objectAtIndex:buttonIndex]) withObject:self.target];
    self.target = nil;
    [self.selectors removeAllObjects];
}

//// Reloadable
- (IBAction)reload:(id)sender
{
    NSLog(@"reloadRoom[%@]", self.room.roomId);
    _page = 1;
    [self performSelector:@selector(_startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(_reloadEntryListInBackground:) withObject:nil];
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
- (IBAction)callSetting:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"move to SettingView");
    SettingView *settingView = [[[SettingView alloc] initWithNibName:@"SettingView" bundle:nil 
                                                             factory:self.factory] autorelease];
    [self.navigationController pushViewController:settingView animated:YES];
    [pool release];
}

- (IBAction)addEntry:(id)sender
{
    NSLog(@"editEntry");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"move to EditView");
    EditView *editView = [[[EditView alloc] initWithNibName:@"EditView" bundle:nil 
                                                     roomId:self.room.roomId 
                                                   parentId:nil 
                                                targetEntry:nil 
                                               previousView:self
                                                    factory:self.factory] autorelease];
    [self.navigationController pushViewController:editView animated:YES];
    [pool release];
}

//// Private
- (void)_startIndicator:(id)sender
{
    CGRect viewSize = self.view.bounds;
    [self.indicator setFrame:CGRectMake(viewSize.size.width/2-25, viewSize.size.height/2-25, 50, 50)];
    [self.indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)_reloadEntryListInBackground:(id)arg
{
    NSLog(@"reload entryList[%@] In Background", self.room.roomId);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *timeline = [self.factory getRoomEntryListByRoomId:self.room.roomId page:_page sender:self];
    if (timeline != nil && [timeline count] != 0) {
        self.entryList = timeline;
        [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // <<load next page>>用
        [self.entryList addObject:[[[EntryData alloc] init] autorelease]]; // 最後の空白行用
        [self.entryTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.indicator stopAnimating];
    [pool release];
}

- (void)_nextPage:(id)sender
{
    _page++;
    NSLog(@"nextPage [%d]", _page);
    [self performSelector:@selector(_startIndicator:) withObject:self];
    [self performSelectorInBackground:@selector(_reloadEntryListInBackground:) withObject:nil];
}

- (void)_moveToCommentViewWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"move to CommentView");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CommentView *commentView = [[[CommentView alloc] initWithNibName:@"CommentView" 
                                                              bundle:nil 
                                                                room:self.room 
                                                         originEntry:originEntry 
                                                        previousView:self 
                                                             factory:self.factory] autorelease];
    [self.navigationController pushViewController:commentView animated:YES];
    [pool release];
}

- (void)_updateEntryWithOriginEntry:(EntryData *)originEntry
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"更新できません"];
    [alert setMessage:@"更新APIがまだ提供されていません"];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
    
//    NSLog(@"update entry [%@]", originEntry.entryId);
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSLog(@"move to EditView");
//    EditView *editView = [[[EditView alloc] initWithNibName:@"EditView" bundle:nil 
//                                                     roomId:self.room.roomId 
//                                                   parentId:nil 
//                                                targetEntry:originEntry 
//                                               previousView:self 
//                                                    factory:self.factory] autorelease];
//    [self.navigationController pushViewController:editView animated:YES];
//    [pool release];
}

- (void)_deleteEntryWithOriginEntry:(EntryData *)originEntry
{
    self.willDelete = originEntry;
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"確認";
    alert.message = @"削除してもよろしいですか？";
    [alert addButtonWithTitle:@"いいえ"];
    [alert addButtonWithTitle:@"はい"];
    [alert show];
}

- (void)_viewAttachmentWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"View Attachment [%@]", originEntry.entryId);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([@"Text" isEqualToString:originEntry.attachmentType]) {
        NSLog(@"move to LongTextView");
        LongTextView *longTextView = [[[LongTextView alloc] initWithNibName:@"LongTextView" bundle:nil 
                                                                      entry:originEntry
                                                                    factory:self.factory] autorelease];
        [self.navigationController pushViewController:longTextView animated:YES];
    }
    else if ([@"Image" isEqualToString:originEntry.attachmentType]) {
        NSLog(@"move to ImageView");
        ImageView *imageView = [[[ImageView alloc] initWithNibName:@"ImageView" bundle:nil 
                                                             entry:originEntry 
                                                           factory:self.factory] autorelease];
        [self.navigationController pushViewController:imageView animated:YES];
    }
    else if ([@"Link" isEqualToString:self.target.attachmentType]) {
        NSLog(@"open safari with url[%@]", originEntry.attachmentURL);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.target.attachmentURL]];
    }
    [pool release];
}

- (void)_cancelWithOriginEntry:(EntryData *)originEntry
{
    NSLog(@"cancel entry [%@]", originEntry.entryId);
    [self.entryTable deselectRowAtIndexPath:[self.entryTable indexPathForSelectedRow] animated:YES];
}

@end
