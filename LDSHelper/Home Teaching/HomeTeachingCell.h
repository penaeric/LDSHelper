//
//  HomeTeachingCell.h
//  LDSHelper
//
//  Created by Eric Pena on 9/23/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface HomeTeachingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageLeft;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageRight;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabelLeft;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabelRight;

@end
