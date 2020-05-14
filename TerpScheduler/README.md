#  TerpSchedulerIOS Documentation

## Model Overview
* CustomUserDefaults -- handles updating and synchronizing with the settings app.
* DataTransferManager -- God class. Handles orchestration of data flow between controllers and repositories. Also contains protocols it uses in a vain attempt to segregate interfaces.
* UserColors -- defines color themes in a centralized fashion.
* NetworkScheduleUpdater -- handles the communication with an external API to download a JSON containing the schedule for the year. A default schedule is baked in on each release, but that's quickly updated. This class hits an API that looks like GET: /api/schedule/year?update=last-update, where year is the current school year (2019 for the 2019-2020 school year) and last-update is a timestamp in seconds since the epoch. The JSON response has the following format:

{ "ISO week number": [[List of letter codes for that week], "DD/MM/YYYY for monday"], ..., "Last Updated": "DD/MM/YYYY"}

* ScheduleTypeData -- handles converting letter days into missing classes, etc. with a few special cases.
* NotificationManager -- handles interfacing with the iOS notification system to pop up reminders.
### Entities & Repositories
* Repository -- generic repository to handle CoreData queries, plus some helper classes.
* TaskRepository (inherits from Repository) -- this is the main one that handles queries about individual user-entered tasks.
* DateRepository (inherits from Repository) -- handles schedules and day-letters.
* SchoolClassesRepository (inherits from Repository) -- handles user-entered data about their classes (for the left-hand bar on the main screen)
* All the *Entity classes are individual CoreData entities, along with their fully-hydrated model objects where relevant.




