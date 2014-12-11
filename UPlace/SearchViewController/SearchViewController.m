//
//  SearchViewController.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "SearchViewController.h"
#import "UPlaceLocationManager.h"

#import "RESideMenu.h"
#import "FeedViewController.h"
// Google plcaes result items
#import "GOPlace.h"
#import "FTGooglePlacesAPISearchResultItem.h"
#import "FTGooglePlacesAPIDetailResponse.h"


@interface SearchViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UPlaceLocationManagerDelegate>

// Array to store search results
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *resultTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Configure UITableView to display search results
    _resultTable.dataSource = self;
    _resultTable.delegate = self;
    
    // Configure UISearchBar
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Where to discover?";
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Location Manager Configuration
    [[UPlaceLocationManager sharedLocationManager] setDelegate:self];
    [[UPlaceLocationManager sharedLocationManager] setDelegateNotSafe:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions

- (IBAction)cancelSearch:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UPlaceLocationManager Delegate

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindPlacesFromSearch:(NSArray *)locations
{
    _searchResults = locations;
    [_resultTable reloadData];
}

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindDetailsFromLocation:(FTGooglePlacesAPIDetailResponse *)detailedLocation
{
    CLLocation *location = detailedLocation.location;
    // Reload data after user selecting a location
    UINavigationController *nvc = (UINavigationController *)[(RESideMenu *)self.presentingViewController contentViewController];
    FeedViewController *fvc = nvc.viewControllers[0];
    // Update feed view controllor's post location and location place name
    fvc.postLocation = location;
    fvc.postLocationPlaceName = detailedLocation.name;
    fvc.postLocationAddress = detailedLocation.addressString;
    [fvc unselectSegmentedControl];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    // Refresh feed table view
    [fvc reloadTableViewDataWithLocatin:location];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        _searchResults = nil;
        [_resultTable reloadData];
        return;
    }
    [[UPlaceLocationManager sharedLocationManager] searchForPlacesFromKeyword:searchText];
}

#pragma mark - Search results table view delegate and data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultTableViewCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultTableViewCell"];
    }
    GOPlace *location = [_searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = location.name;
    [cell.textLabel setFont:[UIFont systemFontOfSize:13.0]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResults.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    GOPlace *selectedLocation = [self.searchResults objectAtIndex:indexPath.row];
    [[UPlaceLocationManager sharedLocationManager] getDetailsFromLocation:selectedLocation.reference];

}


@end
