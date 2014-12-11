//
//  NewPostViewController.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "NewPostViewController.h"
#import "UPlaceDataStoreManager.h"
#import "HGPhotoWall.h"
#import "TQTextView.h"
#import "FeedViewController.h"
#import "RESideMenu.h"
#import "SVProgressHUD.h"

#define _tintColor          [UIColor colorWithRed:255/255.0 green:184/255.0 blue:41/255.0 alpha:1.0]

@interface NewPostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, HGPhotoWallDelegate>

@property (weak, nonatomic) IBOutlet UIView *photoWallView;
@property (weak, nonatomic) IBOutlet TQTextView *messageTextView;

@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UILabel *postLocationPlaceNameLabel;

@property (nonatomic, strong) CLLocation *postLocation;
@property (nonatomic, strong) NSString *postLocationPlaceName;
@property (nonatomic, strong) NSString *postLocationAddress;

@end

@implementation NewPostViewController

// Designated initializer
- (id)initWithPostLocation:(CLLocation *)location placeName:(NSString *)name address:(NSString *)address
{
    self = [super initWithNibName:@"NewPostViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _postLocation = location;
        _postLocationAddress = address;
        _postLocationPlaceName = name;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initWithPostLocation:" userInfo:nil];
    return nil;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TextView placeholder etc.
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:18];
    self.messageTextView.maxTextLength = 180;
    self.messageTextView.textColor = [UIColor darkGrayColor];
    self.messageTextView.placeholder = @"What's happening?";
    self.messageTextView.placeholderColor = [UIColor grayColor];
    self.messageTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // PhotoWall configuration
    self.imageArray = [NSMutableArray array];
    HGPhotoWall *photoWall = [[HGPhotoWall alloc] initWithFrame:CGRectZero];
    [photoWall setPhotos:[NSArray arrayWithObjects:nil]];
    photoWall.delegate = self;
    [photoWall setEditModel:YES];
    [self.photoWallView addSubview:photoWall];
    
    _postLocationPlaceNameLabel.text = _postLocationPlaceName;
    [self.messageTextView becomeFirstResponder];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Don't want to delay view to appear so init image picker here
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.messageTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delegate implementions

#pragma mark - TextViewDelegate

// Conforms TextViewDelegate protocol to dismiss keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 180;
    return YES;
}

#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // If we have an image picked
    if(image != nil) {
        [self addCompressedImage:image];
        [self addThumbnailImage:image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PhotoWallDelegate

- (void)photoWallPhotoTaped:(NSUInteger)index
{
    UIActionSheet *actionSheetTemp = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete"
                                                        otherButtonTitles:@"Edit", nil];
    actionSheetTemp.tag = index;
    
    //[actionSheetTemp showInView:[UIApplication sharedApplication].keyWindow];
    
    [actionSheetTemp showInView:self.view];
    
}

- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
    NSData *tmpData = [self.imageArray objectAtIndex:index];
    [self.imageArray removeObjectAtIndex:index];
    [self.imageArray insertObject:tmpData atIndex:newIndex];
}

- (void)photoWallAddAction
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}

- (void)photoWallAddFinish
{
    return;
}

- (void)photoWallDeleteFinishAtIndex:(NSInteger)index
{
    [self.imageArray removeObjectAtIndex:index];
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.photoWallView.subviews[0] deletePhotoByIndex:actionSheet.tag];
    } else if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark - Make compressed imgae

- (void)addThumbnailImage:(UIImage *)image
{
    CGSize origImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, 65, 65);
    float ratio = MAX(newRect.size.width/origImageSize.width, newRect.size.height/origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:3.0];
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width)/2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height)/2.0;
    
    [image drawInRect:projectRect];
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [self.photoWallView.subviews[0] addPhoto:UIImageJPEGRepresentation(thumbnailImage, 1.0)];
    
    UIGraphicsEndImageContext();
}

- (void)addCompressedImage: (UIImage *)image
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    // Make sure image file size is under 250KB
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    [self.imageArray addObject:imageData];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Actions
- (IBAction)cancelPost:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmPost:(id)sender {
    if (self.messageTextView.text.length == 0) {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Don't you want to say something?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self.messageTextView resignFirstResponder];
    NSLog(@"We have %lu images!", (unsigned long)[self.imageArray count]);
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.980f green:0.980f blue:0.980f alpha:1.00f]];
    [SVProgressHUD setForegroundColor:_tintColor];
    [SVProgressHUD showWithStatus:@"Uploading Post"];
    UPlacePost *post = [[UPlaceDataStoreManager sharedDataStoreManager] creatPostWithMessage:self.messageTextView.text
                                                         Images:self.imageArray
                                                       Location:self.postLocation
                                                        Address:self.postLocationAddress
                                                      PlaceName:self.postLocationPlaceName];
    
    if (post) {
        [SVProgressHUD showSuccessWithStatus:@"Post Uploaded"];
        // Reload data after creating a new Post
        UINavigationController *nvc = (UINavigationController *)[(RESideMenu *)self.presentingViewController contentViewController];
        FeedViewController *fvc = nvc.viewControllers[0];
        [fvc addPostToArray:post];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Error Occurred"];
    }
}

@end
