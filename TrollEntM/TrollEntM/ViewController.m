//
//  ViewController.m
//  TrollEntM
//
//  Created by speedy on 2/26/25.
//

#import "ViewController.h"
#import "LSApplicationProxy.h"
#import <Security/Security.h>
#import <dlfcn.h>

typedef struct CF_BRIDGED_TYPE(id) __SecCode *SecCodeRef;
typedef int32_t OSStatus;
extern OSStatus SecCodeCopySelf(SecCodeRef *self);

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appPickerView = [[UIPickerView alloc] init];
    self.appPickerView.delegate = self;
    self.appPickerView.dataSource = self;
    
    self.presetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.presetButton setTitle:@"Select Preset" forState:UIControlStateNormal];
    [self.presetButton addTarget:self action:@selector(showPresetMenu) forControlEvents:UIControlEventTouchUpInside];
    
    self.entitlementsTextView = [[UITextView alloc] init];
    self.entitlementsTextView.font = [UIFont systemFontOfSize:14];
    self.entitlementsTextView.layer.borderWidth = 1;
    self.entitlementsTextView.layer.borderColor = [UIColor.systemGrayColor CGColor];
    self.entitlementsTextView.layer.cornerRadius = 8;
    
    self.applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.applyButton setTitle:@"Apply Entitlements" forState:UIControlStateNormal];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    
    [self.view addSubview:self.appPickerView];
    [self.view addSubview:self.presetButton];
    [self.view addSubview:self.entitlementsTextView];
    [self.view addSubview:self.applyButton];
    [self.view addSubview:self.statusLabel];
    
    // Configure auto layout
    self.appPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.presetButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.entitlementsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.applyButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.appPickerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.appPickerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.appPickerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.appPickerView.heightAnchor constraintEqualToConstant:200],
        
        [self.presetButton.topAnchor constraintEqualToAnchor:self.appPickerView.bottomAnchor constant:20],
        [self.presetButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        [self.entitlementsTextView.topAnchor constraintEqualToAnchor:self.presetButton.bottomAnchor constant:20],
        [self.entitlementsTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.entitlementsTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.entitlementsTextView.heightAnchor constraintEqualToConstant:200],
        
        [self.applyButton.topAnchor constraintEqualToAnchor:self.entitlementsTextView.bottomAnchor constant:20],
        [self.applyButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.applyButton.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    self.installedApps = [LSApplicationProxy installedApplications];
    self.presetEntitlements = @[
        @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>platform-application</key>\n\t<true/>\n</dict>\n</plist>",
        
        @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>platform-application</key>\n\t<true/>\n\t<key>com.apple.private.security.container-required</key>\n\t<false/>\n\t<key>com.apple.private.security.no-container</key>\n\t<true/>\n</dict>\n</plist>",
        
        @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>platform-application</key>\n\t<true/>\n\t<key>com.apple.private.security.container-required</key>\n\t<false/>\n\t<key>com.apple.private.security.no-container</key>\n\t<true/>\n\t<key>get-task-allow</key>\n\t<true/>\n\t<key>task_for_pid-allow</key>\n\t<true/>\n</dict>\n</plist>"
    ];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

#pragma mark - UIPickerView Delegate & DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.installedApps.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    LSApplicationProxy *app = self.installedApps[row];
    return [NSString stringWithFormat:@"%@ (%@)", app.localizedName, app.bundleIdentifier];
}

#pragma mark - Preset Menu

- (void)showPresetMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Preset"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Basic Platform App"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        self.entitlementsTextView.text = self.presetEntitlements[0];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"File System Access"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        self.entitlementsTextView.text = self.presetEntitlements[1];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Debug Privileges"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        self.entitlementsTextView.text = self.presetEntitlements[2];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
