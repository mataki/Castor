//
//  GroupView2.h
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
#import "RoomView.h"
#import "SettingView.h"
#import "CellBuilder.h"


@interface GroupView : UIViewController <UITableViewDataSource, UITableViewDelegate, Reloadable, Alertable> {
    UITableView *_roomTable;
    NSMutableArray *_roomList;    
    DataFactory *_factory;
    UIActivityIndicatorView *_indicator;
    CellBuilder *_cellBuilder;
    BOOL _portrate;
}

@property(nonatomic, retain) IBOutlet UITableView *roomTable;
@property(nonatomic, retain) IBOutlet NSMutableArray *roomList;
@property(nonatomic, retain) DataFactory *factory;
@property(nonatomic, retain) UIActivityIndicatorView *indicator;
@property(nonatomic, retain) CellBuilder *cellBuilder;

- (IBAction)callSetting:(id)sender;
- (IBAction)moveToHome:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
              factory:(DataFactory *)factory;

@end
