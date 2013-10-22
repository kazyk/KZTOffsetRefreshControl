#import "KZTOffsetRefreshControl.h"

static BOOL isiOS7OrLater() {
    static BOOL flag = NO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        flag = ([ver floatValue] >= 7.0);
    });
    return flag;
}


@interface KZTOffsetRefreshControl ()
@property (nonatomic) CGFloat topContentInset;
@property (nonatomic) BOOL topContentInsetSaved;
@end


@implementation KZTOffsetRefreshControl

- (void)layoutSubviews
{
    [super layoutSubviews];

    //RefreshControlの表示位置を変更するhack.
    //ref. http://stackoverflow.com/questions/12913208/uitableview-with-uirefreshcontrol-under-a-semi-transparent-status-bar

    UIScrollView *scrollView = (UIScrollView *)self.superview;
    NSAssert([scrollView isKindOfClass:[UIScrollView class]], @"");

    if (!self.topContentInsetSaved) {
        self.topContentInset = scrollView.contentInset.top;
        self.topContentInsetSaved = YES;
        return; //初回はここでreturnしておかないと起動直後に少しはみでて見えてしまう
    }

    //iOS6: 最初はnavigation barなどに隠れていて引っ張ると一緒に下に移動して出てくる。完全に見えるようになったらそれ以上下に移動しない。
    //iOS7: はじめから位置が動かない。

    CGRect f = self.frame;

    if (!isiOS7OrLater() && scrollView.contentOffset.y + self.topContentInset > -f.size.height) {
        f.origin.y = self.offsetY + -f.size.height;
    } else {
        f.origin.y = self.offsetY + scrollView.contentOffset.y + self.topContentInset;
    }

    self.frame = f;
}

@end