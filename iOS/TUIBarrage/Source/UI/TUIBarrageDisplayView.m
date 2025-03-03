//
//  TUIBarrageDisplayView.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import "TUIBarrageDisplayView.h"
#import "TUIBarrageCell.h"
#import "Masonry.h"
#import "UIView+TUILayout.h"

@interface TUIBarrageDisplayView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) TUIBarrageStyle style;
@property (nonatomic, strong) NSMutableArray <TUIBarrageModel *> *dataArray;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) CGFloat maxHeight;
@end

@implementation TUIBarrageDisplayView

- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame maxHeight:maxHeight groupId:groupId]) {
        self.style = TUIBarrageStyleVertical;
        self.originFrame = frame;
        self.maxHeight = maxHeight;
        [self setupUI];
        [self bindInteraction];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI {
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)bindInteraction {
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeOrientation:) name:
     UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didChangeOrientation:(NSNotification*)notification {
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        CGFloat maxHeight = self.superview.mm_h - self.mm_y;
        CGFloat height = self.tableView.contentSize.height > maxHeight ? maxHeight : self.tableView.contentSize.height;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(self.mm_x);
            make.top.equalTo(self).offset(self.originFrame.origin.y);
            make.width.mas_equalTo(self.mm_w);
            make.height.mas_equalTo(height);
        }];
    } else {
        CGFloat maxHeight = [UIScreen mainScreen].bounds.size.width - self.mm_y;
        CGFloat height = self.tableView.contentSize.height > maxHeight ? maxHeight : self.tableView.contentSize.height;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(self.mm_x);
            make.top.equalTo(self).offset(80);
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
            make.height.mas_equalTo(height);
        }];
    }
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tableView);
    }];
}

#pragma mark - tableview delegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIBarrageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TUIBarrageCell.class) forIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {
        [cell setBarrage:self.dataArray[indexPath.row] index:indexPath.row];
    }
    self.cellHeight = [cell getCellHeight];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

#pragma mark - set/get
-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:TUIBarrageCell.class forCellReuseIdentifier:NSStringFromClass(TUIBarrageCell.class)];
    }
    return _tableView;
}

///展示弹幕消息
- (void)receiveBarrage:(TUIBarrageModel *)barrage {
    [self.dataArray addObject:barrage];
    [self.tableView reloadData];
    __weak typeof(self) wealSelf = self;
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        CGFloat maxHeight = self.superview.mm_h - self.originFrame.origin.y;
        if (self.maxHeight > 0) {
            maxHeight = self.maxHeight;
        }
        CGFloat height = self.tableView.contentSize.height > maxHeight ? maxHeight : self.tableView.contentSize.height;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.superview).offset(self.mm_x);
            make.top.equalTo(self.superview).offset(self.originFrame.origin.y);
            make.width.mas_equalTo(self.mm_w);
            make.height.mas_equalTo(height);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.tableView);
        }];
    } else {
        CGFloat maxHeight = self.superview.mm_h - self.mm_y;
        CGFloat height = self.tableView.contentSize.height > maxHeight ? maxHeight : self.tableView.contentSize.height;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.superview).offset(self.mm_x);
            make.top.equalTo(self.superview).offset(80);
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
            make.height.mas_equalTo(height);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.tableView);
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wealSelf) strongSelf = wealSelf;
        if (strongSelf) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count -1 inSection:0]
             atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

@end
