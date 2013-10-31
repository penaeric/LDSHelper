//
//  MemberCell.h
//  LDSHelper
//
//  Created by Eric Pena on 6/20/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface MemberCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *initialsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@end
