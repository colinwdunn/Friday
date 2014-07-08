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
#import "PeopleViewController.h"


@interface AddPeopleViewController ()

@property (nonatomic) NSMutableArray *myContacts;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic, strong) Roll *theRoll;
- (IBAction)cancelButtonDidPress:(id)sender;
@end

@implementation AddPeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getContactsList];
    
    [self.contactTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    self.selectedContacts = [NSMutableArray array];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myContacts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.textLabel.text = [self.myContacts[indexPath.row] firstName];
    cell.detailTextLabel.text = [self.myContacts[indexPath.row] emailBaby];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *person = self.myContacts[indexPath.row];
    [self.selectedContacts addObject:person];
    NSLog(@"You selected these contacts: %@", self.selectedContacts);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove this contact from self.selectedContacts array if their email is equal to an email of someone in the array
    User *person = self.myContacts[indexPath.row];
    User *thisPerson;
    for (thisPerson in self.selectedContacts) {
        if (thisPerson.emailBaby == person.emailBaby) {
            [self.selectedContacts removeObject:thisPerson];
        }
    }
    
    NSLog(@"New selected contacts: %@", self.selectedContacts);
}

- (void)getContactsList {

    self.myContacts = [NSMutableArray array];
    
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
                for (i = 0; i<[allContacts count]; i++)
                {
                    User *person = [[User alloc] init];
                    ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                    
                    ABMultiValueRef email = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                    CFStringRef emailRef = ABMultiValueCopyValueAtIndex(email, 0);
                    NSString *emailFromMulti = (__bridge NSString *) emailRef;
                    
                    ABMultiValueRef phoneNumber = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                    CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(phoneNumber, 0);
                    NSString *phoneFromMulti = (__bridge NSString *) phoneRef;
                    
                    person.firstName = firstName;
                    person.emailBaby = emailFromMulti;
                    person.phoneNumber = phoneFromMulti;
                    
                    // Check if person has phone number, if they do add them.
                    // TODO: Fix for case when just have email
                    if (person.phoneNumber) {
                        [self.myContacts addObject:person];

                    }
                }
                NSLog(@"Contacts:%@", self.myContacts);
                [self.contactTableView reloadData];
            }
            
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted )
        {
            // Display an error.
        }
    }
    
}


- (IBAction)onAddSelectedContactsButton:(id)sender {
    
    //fetching current user's last roll
//    Roll *initializedRoll = [[Roll alloc] init];
//    [initializedRoll getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
//        NSLog(@"%@", currentRoll);
//        self.theRoll = currentRoll;
//    } andFailure:^(NSError *error) {
//        NSLog(@"OH Noes error: %@", error);
//    }];
//        
//    
//        
//        
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
    
    //
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
      if([MFMessageComposeViewController canSendText])
      {
          NSMutableArray *inviteNumbers = [NSMutableArray array];
          for (User *person in self.selectedContacts) {
              [inviteNumbers addObject:person.phoneNumber];
          }
          // Need to account for case when they don't have phone numbers
          NSLog(@"%@", inviteNumbers);
          controller.body = @"Go to your Friday app! It is Friday!";
          controller.recipients = inviteNumbers;
          controller.messageComposeDelegate = self;
          [self presentViewController:controller animated:YES completion:nil];
          
          // On send,
      }


        
        
        
    
            
        
    

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Canceled the message: %d", result);
        [self dismissViewControllerAnimated:YES completion:^{
            PeopleViewController *peopleViewController = [[PeopleViewController alloc] initWithMembersList:self.selectedContacts];
            [self presentViewController:peopleViewController animated:YES completion:NULL];
        }];
    }
    if (result == MessageComposeResultSent) {
        NSLog(@"Message was sent");
        
    }
    if (result == MessageComposeResultFailed) {
        NSLog(@"Message failed");
    }
}


- (IBAction)cancelButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
