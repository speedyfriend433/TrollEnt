//
//  ViewController.h
//  TrollEntM
//
//  Created by speedy on 2/26/25.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) UIPickerView *appPickerView;
@property (nonatomic, strong) UIButton *presetButton;
@property (nonatomic, strong) UITextView *entitlementsTextView;
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSArray *installedApps;
@property (nonatomic, strong) NSArray *presetEntitlements;

@end
