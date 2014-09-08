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
#import <Realm/Realm.h>
#import "CachedBlurredImage.h"

@interface AddPeopleViewController ()

@property (nonatomic) NSMutableArray *myContacts;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic) NSMutableArray *filteredSearchResults;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *shareMyCameraButton;
@property (nonatomic) NSMutableArray *selectedContactRows;
@property (weak, nonatomic) IBOutlet UITextView *inviteToTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTableViewHeightConstraint;
- (IBAction)cancelButtonDidPress:(id)sender;

@end

@implementation AddPeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getContactsList];
    [self styleTextViewText];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    [self.searchTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    self.searchTableView.hidden = true;
    self.selectedContacts = [NSMutableArray array];
    self.myContacts = [NSMutableArray array];
    self.selectedContactRows = [NSMutableArray array];
    
    self.imageView.image = [CachedBlurredImage getBlurredImage];
    
    self.shareMyCameraButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.shareMyCameraButton.layer.borderWidth = 3;
    self.shareMyCameraButton.layer.cornerRadius = 20;
    
    self.inviteToTextView.delegate = self;
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

- (void)styleTextViewText {
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[UIFont systemFontSize]];
    [self.inviteToTextView setFont:boldFont];
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
        person = self.filteredSearchResults[indexPath.row];
        NSUInteger indexOfPerson = [self.myContacts indexOfObject:person];
        NSIndexPath *selectedPersonIndexPath = [NSIndexPath indexPathForRow:indexOfPerson inSection:0];
        [self.selectedContactRows addObject:selectedPersonIndexPath];
        [self.contactTableView reloadData];
    } else {
        [self.selectedContactRows addObject:indexPath];
        [self configureHighlightedCell:cell highlighted:true];
        person = self.myContacts[indexPath.row];
    }
    
    [self.selectedContacts addObject:person];
    [self addContactNames:self.selectedContacts toTextView:self.inviteToTextView];
    
    if (tableView == self.searchTableView) {
        [self.inviteToTextView becomeFirstResponder];
        self.searchTableView.hidden = true;
        [self.filteredSearchResults removeAllObjects];
    }
    
    [self resizingTextView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = (ContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.selectedContactRows removeObject:indexPath];
    [self configureHighlightedCell:cell highlighted:false];
    User *person = self.myContacts[indexPath.row];
    if ([self.selectedContacts containsObject:person]) {
        [self.selectedContacts removeObject:person];
    }
    
    [self addContactNames:self.selectedContacts toTextView:self.inviteToTextView];
    [self resizingTextView];
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

- (void)addContactNames:(NSArray *)contacts toTextView:(UITextView *)inviteTextView {
    NSString *allNames;
    for (User *contact in contacts) {
        NSString *contactName = contact.firstName;
        if (allNames == nil) {
            //First contact added
            allNames = [NSString stringWithFormat:@"%@, ", contactName];
        } else {
            allNames = [NSString stringWithFormat:@"%@%@, ", allNames, contactName];
        }
    }
    inviteTextView.text = allNames;
    self.searchTableView.hidden = true;
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
      }
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate didDismissAddPeopleViewController];
        }
    }];
   
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Canceled the message: %d", result);
        [self didInviteUsers];
        //TODO: Nice flash message confirming things were sent
        
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
        }];
    }
}

- (IBAction)cancelButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:true];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //self.searchTableView.hidden = false;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //We can set and reload the search table view here
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        [self.selectedContacts removeAllObjects];
        [self addContactNames:self.selectedContacts toTextView:self.inviteToTextView];
    }
    
    [self resizingTextView];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.searchTableView.hidden = false;
    //TODO: Delete corner case
    NSString *searchTextViewText = self.inviteToTextView.text;
    NSString *searchTextWithPressedChar = [searchTextViewText stringByReplacingCharactersInRange:range withString:text];
    NSArray *tempArray = [searchTextWithPressedChar componentsSeparatedByString:@", "];
    NSString *searchText = [tempArray lastObject];
    if ([searchText isEqualToString:@""]) {
        //TODO: Check for no space case, when user deletes up to comma
        [self.filteredSearchResults removeAllObjects];
        self.searchTableView.hidden = true;
    } else {
        [self.filteredSearchResults removeAllObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstName contains[c] %@", searchText];
        self.filteredSearchResults = [NSMutableArray arrayWithArray:[self.myContacts filteredArrayUsingPredicate:predicate]];
        [self.searchTableView reloadData];
    }
    
    [self resizingTextView];
    return YES;
}

- (void)resizingTextView {
    [UIView animateWithDuration:1
                     animations:^{
                         CGSize sizeThatShouldFitTheContent = [self.inviteToTextView sizeThatFits:self.inviteToTextView.frame.size];
                         self.textViewHeightConstraint.constant = sizeThatShouldFitTheContent.height;
                         [self.view setNeedsLayout];
                     }];
    //[self.contactTableView reloadData];
}


//TODO: Scrolling contacts tableview should dismiss keyboard

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
