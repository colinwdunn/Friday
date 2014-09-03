//
//  AddPeopleViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "AddPeopleViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "User.h"
#import "Roll.h"
#import "UserRoll.h"
#import "PeopleViewController.h"
#import "CameraViewController.h"
#import "ContactCell.h"

@interface AddPeopleViewController ()

@property (nonatomic) NSMutableArray *myContacts;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic) NSMutableArray *filteredSearchResults;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *shareMyCameraButton;
@property (nonatomic) NSMutableArray *selectedContactRows;
@property (weak, nonatomic) IBOutlet UITextField *inviteToTextfield;

- (IBAction)cancelButtonDidPress:(id)sender;

@end

@implementation AddPeopleViewController

- (id)initWithImage:(UIImage *)image processedImage:(UIImage *)processedImage {
    self = [super init];
    if (self) {
        self.image = image;
        self.processedImage = processedImage;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getContactsList];
    [self styleTextfieldText];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    self.searchTableView.hidden = true;
    self.selectedContacts = [NSMutableArray array];
    self.myContacts = [NSMutableArray array];
    self.selectedContactRows = [NSMutableArray array];
    self.imageView.image = self.processedImage;
    
    self.shareMyCameraButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.shareMyCameraButton.layer.borderWidth = 3;
    self.shareMyCameraButton.layer.cornerRadius = 20;
    
    self.inviteToTextfield.delegate = self;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.filteredSearchResults = [NSMutableArray array];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = false;
    [self.view addGestureRecognizer:tap];
}

- (void)getContactsList {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    __block BOOL userDidGrantAddressBookAccess;
    CFErrorRef addressBookError = NULL;
    
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, &addressBookError);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
            userDidGrantAddressBookAccess = granted;
            dispatch_semaphore_signal(sema);
                if (addressBook !=nil) {
                    NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
                    NSUInteger i = 0;
                        for (i = 0; i<[allContacts count]; i++) {
                            User *person = [[User alloc] init];
                            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                            
                            ABMultiValueRef phoneNumberValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                            CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(phoneNumberValueRef, 0);
                            NSString *phoneNumber = (__bridge NSString *) phoneRef;
                            
                            if (phoneNumber != nil ){
                                person.phoneNumber = phoneNumber;
                                person.firstName = firstName;
                                [self.myContacts addObject:person];
                            }

                        }
                    
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.contactTableView reloadData];
                        });
                }
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted ){
                NSLog(@"Some Error Occurd While Getting Contact List.");
            }
    }
}

- (void)styleTextfieldText {
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[UIFont systemFontSize]];
    [self.inviteToTextfield setFont:boldFont];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchTableView){
        return self.filteredSearchResults.count;
    } else {
        return self.myContacts.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"ContactCell"];
    NSString *entry;
    if (tableView == self.searchTableView) {
        entry = [self.filteredSearchResults[indexPath.row] firstName];
    } else {
        entry = [self.myContacts[indexPath.row] firstName];
    }
    [self configureCell:cell forEntry:entry];
    return cell;
}

- (void)configureCell:(ContactCell *)cell forEntry:(NSString *)entry {
    cell.contactTitleLabel.text = entry;
    cell.contactSelectedBackground.layer.borderWidth = 1;
    cell.contactSelectedBackground.layer.cornerRadius = 17;
    cell.contactSelectedBackground.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)configureHighlightedCell:(ContactCell *)cell highlighted:(BOOL)selected {
    if (selected) {
        cell.contactCheckmark.hidden = false;
        cell.contactSelectedBackground.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
    } else {
        cell.contactCheckmark.hidden = true;
        cell.contactSelectedBackground.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = (ContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    User *person = nil;
    if (tableView == self.searchTableView){
        //TODO: Find where the selected user is in myContacts and add that index to the selectedContactRows
        person = self.filteredSearchResults[indexPath.row];
        //hide
    } else {
        [self.selectedContactRows addObject:indexPath];
        [self configureHighlightedCell:cell highlighted:true];
        person = self.myContacts[indexPath.row];
    }
    [self.selectedContacts addObject:person];
    [self addContactNames:self.selectedContacts toTextfield:self.inviteToTextfield];
    
    if (tableView == self.searchTableView) {
        [self.inviteToTextfield becomeFirstResponder];
        self.searchTableView.hidden = true;
        [self.filteredSearchResults removeAllObjects];
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = (ContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.selectedContactRows removeObject:indexPath];
    [self configureHighlightedCell:cell highlighted:false];
    User *person = self.myContacts[indexPath.row];
    if ([self.selectedContacts containsObject:person]) {
        [self.selectedContacts removeObject:person];
    }
    [self addContactNames:self.selectedContacts toTextfield:self.inviteToTextfield];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ContactCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL highlighted;
    if ([self.selectedContactRows containsObject:indexPath]) {
        highlighted = true;
    } else {
        highlighted = false;
    }
    [self configureHighlightedCell:cell highlighted:highlighted];
}

- (void)addContactNames:(NSArray *)contacts toTextfield:(UITextField *)inviteTextfield {
    NSString *allNames;
    for (User *contact in contacts) {
        NSString *contactName = contact.firstName;
        //If first we dont want a comma
        if (allNames == nil) {
            allNames = [NSString stringWithFormat:@"%@, ", contactName];
        } else {
            allNames = [NSString stringWithFormat:@"%@%@, ", allNames, contactName];
        }
    }
    inviteTextfield.text = allNames;
}

- (IBAction)onAddSelectedContactsButton:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
      if([MFMessageComposeViewController canSendText])
      {
          NSMutableArray *inviteNumbers = [NSMutableArray array];
          for (User *person in self.selectedContacts) {
              [inviteNumbers addObject:person.phoneNumber];
          }
          
          controller.body = @"Go to your Friday app! It is Friday!";
          controller.recipients = inviteNumbers;
          controller.messageComposeDelegate = self;
          [self presentViewController:controller animated:YES completion:nil];
      }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Canceled the message: %d", result);
        [self didInviteUsers];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (result == MessageComposeResultSent) {
        NSLog(@"Message was sent");
        
    }
    if (result == MessageComposeResultFailed) {
        NSLog(@"Message failed");
    }
}

- (void)didInviteUsers {
    for (User *user in self.selectedContacts) {
        UserRoll *invited = [UserRoll object];
        invited.phoneNumber = user.phoneNumber;
        invited.invitedUserName = user.firstName;
        invited.roll = [Roll currentRoll];
        invited.user = [User currentUser];
        invited.status = @"invited";
        [invited saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Shell user created");
            CameraViewController *cameraViewController = [[CameraViewController alloc] init];
            [self presentViewController:cameraViewController animated:YES completion:nil];
        }];
    }
}

- (IBAction)cancelButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:true];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"About to edit the text field");
    self.searchTableView.hidden = false;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //We can set and reload the search table view here
    self.searchTableView.hidden = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    //TODO: Build search text regex that ignores the already added people
    NSString *searchText = self.inviteToTextfield.text;
    [self.filteredSearchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstName contains[c] %@", searchText];
    self.filteredSearchResults = [NSMutableArray arrayWithArray:[self.myContacts filteredArrayUsingPredicate:predicate]];
    [self.searchTableView reloadData];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Stopped editing the text field");
    
}

@end


//For Laters:
//                    ABMultiValueRef email = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
//                    CFStringRef emailRef = ABMultiValueCopyValueAtIndex(email, 0);
//                    NSString *emailFromMulti = (__bridge NSString *) emailRef;
//



//person.firstName = firstName;
//person.emailBaby = emailFromMulti;
//person.phoneNumber = phoneFromMulti;

// Check if person has phone number, if they do add them.
// TODO: Fix for case when just have email




//For dunno when:
//      [[User currentUser] getInvitedUser:self.selectedContacts withSuccess:^(User *invitedUser) {
//          NSLog(@"%@", invitedUser);
//          PFObject *userRollWithInvitedUser = [PFObject objectWithClassName:@"UserRolls"];
//          userRollWithInvitedUser[@"roll"] = self.theRoll;
//          userRollWithInvitedUser[@"user"] = invitedUser;
//          userRollWithInvitedUser[@"status"] = @"invited";
//
//
//          //adding invited user to the UserRolls Tabel
//          [userRollWithInvitedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//              MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//              if([MFMessageComposeViewController canSendText])
//              {
//                  controller.body = @"Go to your Friday app! It is Friday!";
//                  controller.recipients = [NSArray arrayWithObjects:[self.selectedContacts[0] phoneNumber], nil];
//                  controller.messageComposeDelegate = self;
//                  [self presentViewController:controller animated:YES completion:nil];
//              }
//
//          }];
//      } andFailure:^(NSError *error) {
//
//      }];
