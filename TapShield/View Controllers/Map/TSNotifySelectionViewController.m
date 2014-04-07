//
//  TSNotifySelectionViewController.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNotifySelectionViewController.h"

@interface TSNotifySelectionViewController ()

@end

@implementation TSNotifySelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.translucentBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.y += self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbar.frame = frame;
    
    [self addDescriptionToNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self showContainerView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self hideContainerView];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [self transitionNavigationBarAnimatedRight];
        [self whiteNavigationBar];
    }
}

- (void)addDescriptionToNavBar {
    
    _addressLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _routeInfoView.frame.size.width, 21.0f)];
    _addressLabel.text = _addressString;
    _addressLabel.textColor = [TSColorPalette whiteColor];
    _addressLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:13.0f];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    
    _etaLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, _routeInfoView.frame.size.width, 16.0f)];
    _etaLabel.textColor = [TSColorPalette whiteColor];
    _etaLabel.text = _etaString;
    _etaLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:12.0f];
    _etaLabel.textAlignment = NSTextAlignmentCenter;
    [_etaLabel setAdjustsFontSizeToFitWidth:YES];
    
    
    _containerView = [[UIView alloc] initWithFrame:_routeInfoView.frame];
    [_containerView addSubview:_addressLabel];
    [_containerView addSubview:_etaLabel];
    [self.navigationController.navigationBar addSubview:_containerView];
    
    _containerView.alpha = 0.0f;
}

- (void)showContainerView {
    
    [UIView animateWithDuration:0.3f animations:^{
        _containerView.alpha = 1.0f;
    }];
}

- (void)hideContainerView {
    
    [UIView animateWithDuration:0.3f animations:^{
        _containerView.alpha = 0.0f;
    }];
}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


#pragma mark - Collection View Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
     NSString *cellIdentifier = @"ContactCell";
    if (indexPath.item == 0) {
         cellIdentifier = @"AddCell";
    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_homeViewController.entourageManager.contactRecipients.count < 3) {
        return 3;
    }
    
    return _homeViewController.entourageManager.contactRecipients.count + 1;
}

@end
