//
//  CommentView.h
//  Castor
//
//  Created by Nobuyuki Matsui on 11/04/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reloadable.h"
#import "Alertable.h"
#import "DataFactory.h"
#import "HomeView.h"
#import "EditView.h"
#import "SettingView.h"
#import "CellBuilder.h"

@interface CommentView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, Reloadable, Alertable> {
    UITableView *_entryTable;
    NSMutableArray *_entryList;
    DataFactory *_factory;
    RoomData *_room;
    EntryData *_originEntry;
    EntryData *_target;
    EntryData *_willDelete;
    NSMutableArray *_selectors;
    UIViewController <Reloadable> *_previousView;
    UIActivityIndicatorView *_indicator;
    CellBuilder *_cellBuilder;
    BOOL _portrate;
}

@property(nonatomic, retain) IBOutlet UITableView *entryTable;
@property(nonatomic, retain) IBOutlet NSMutableArray *entryList;
@property(nonatomic, retain) DataFactory *factory;
@property(nonatomic, retain) RoomData *room;
@property(nonatomic, retain) EntryData *originEntry;
@property(nonatomic, retain) EntryData *target;
@property(nonatomic, retain) EntryData *willDelete;
@property(nonatomic, retain) NSMutableArray *selectors;
@property(nonatomic, retain) UIViewController <Reloadable> *previousView;
@property(nonatomic, retain) UIActivityIndicatorView *indicator;
@property(nonatomic, retain) CellBuilder *cellBuilder;

- (IBAction)callSetting:(id)sender;
- (IBAction)addEntry:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
                 room:(RoomData *)room 
          originEntry:(EntryData *)originEntry 
         previousView:(UIViewController <Reloadable> *)previousView 
              factory:(DataFactory *)factory;

@end
