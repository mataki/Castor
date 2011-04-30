//
//  GroupView2.m
//  Castor
//
//  Created by Nobuyuki Matsui on 11/04/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupView.h"


@implementation GroupView

@synthesize factory;

@synthesize groupTable;
@synthesize groupList;

- (UILabel *)makeLabel:(CGRect)rect text:(NSString *)text font:(UIFont *)font
{
    UILabel *label = [[[UILabel alloc] init] autorelease];
    [label setFrame:rect];
    [label setText:text];
    [label setFont:font];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentLeft];
    [label setNumberOfLines:0];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    return label;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.factory = nil;
    
    self.groupList = nil;
    self.groupTable = nil;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupData *group = [groupList objectAtIndex:indexPath.row];
    float w = (portrate)?
    self.view.window.screen.bounds.size.width - 70:
    self.view.window.screen.bounds.size.height - 70;
    CGSize size = [group.roomName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(w, 1024) lineBreakMode:UILineBreakModeCharacterWrap];
    float height = 30 + size.height + 10;
    return (height<60)?60:height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([groupList count] <= indexPath.row) return cell;
    GroupData *group = [groupList objectAtIndex:indexPath.row];
    float w = (portrate)?
    self.view.window.screen.bounds.size.width - 70:
    self.view.window.screen.bounds.size.height - 70;
    CGSize size = [group.roomName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(w, 1024) lineBreakMode:UILineBreakModeCharacterWrap];
    UILabel *nameLabel = [self makeLabel:CGRectMake(60, 30, w, size.height) text:group.roomName font:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:nameLabel];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d clicked",indexPath.row);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"move to RoomView");
    RoomView *roomView = [[[RoomView alloc] initWithNibName:@"RoomView" bundle:nil] autorelease];
    roomView.factory = self.factory;
    roomView.roomId = [NSNumber numberWithInteger:indexPath.row];
    [self.navigationController pushViewController:roomView animated:YES];
    [pool release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"GroupView Loaded");
    self.title = @"Group";
    [self.navigationItem.backBarButtonItem setEnabled:NO];
    self.navigationItem.hidesBackButton = YES;
    if (self.factory == nil) {
        self.factory = [[DataFactory alloc] init];
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.groupList = [factory getGroupList];
    [pool release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.factory = nil;
    
    self.groupList = nil;
    self.groupTable = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        portrate = NO;
        [groupTable reloadData];
    }
    else if (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown || interfaceOrientation == UIDeviceOrientationPortrait) {
        portrate = YES;
        [groupTable reloadData];
    }
    return YES;
}

@end
