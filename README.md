LDS Helper
=========

LDS Helper is an App that helps LDS members with some of the most common tasks as a leader in the church, especially with *Home Teaching* and *Visiting Teaching*.

Background
----
Every member in the LDS Church is responsible for watching over other members. To help them with this, there are two programs in the church: [*Home Teaching*](http://www.lds.org/topics/home-teaching) for the men and [*Visiting Teaching*](http://www.lds.org/topics/visiting-teaching) for the women.  As a Home Teacher, a member is assigned a companion with whom he visits other members at least once every month.  They both, as a companionship, report any issues or help needed to the Elder's Quorum President (or Relief Society President in the case of the women). 

The current features on the App are targeted towards the Elder's Quorum president and the Relief Society president, although other organizations could be enabled. As mentioned in the todo section, other people could take advantage of the App if it is integrated with a backend service.

Features
----
 - You can add members by entering their information manually or by importing it from your contacts.
 - You can assign a default organization and even choose if duplicates should be skipped when importing.
 - You can take *assistance* to keep a record of who goes to church and/or to any other activities.
 - You can create companionships
    - When setting up companionships, only members without a companion are shown.
    - When assigning who they'll visit, only members not being visited are shown.
 - You can fill out Home/Visiting Teaching Reports
    - These reports are filled out monthly.
    - You can see at first glance the companionship, how many people they visit and how many people they visited that specific month.
    - You can add comments with concerns or help needed for members visited by a companionship.
    - If you prefer, you can see a list of all the members and quickly see who hasn't been visited.
 - You can create reports in PDF format for Members, monthly assistance, companionships and monthly home teaching reports.
   - You can print these reports from your device or share them via email. 

Todo
----
 - Turn iCloud on, or even better, write a backend service so members can report through the app.
 - Create PDF reports using data from Core Data (the basic methods are there, the App currently creates dummy PDF files)
 - Add other features that might be useful to other organizations(?)
 - Polish UI
 - Add Launch Image and full set of icons
 - Other smaller todos can be found in the code.

Dependencies
----
 - iOS 7
 - External libraries used in this project:
    - [MagicalRecord](https://github.com/magicalpanda/MagicalRecord)
    - [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack/)
    - [MZDayPicker](https://github.com/m1entus/MZDayPicker)
    - [SWRevealViewController](https://github.com/John-Lluch/SWRevealViewController)
    - [TSMessages](https://github.com/toursprung/TSMessages)
    
Notes
----
Open the **.xcworkspace** file and not the **xcodeproj** file
If linker errors are found, easiest fix is to re-install external libraries using [CocoaPods](http://cocoapods.org/):

```sh
pod install
```
