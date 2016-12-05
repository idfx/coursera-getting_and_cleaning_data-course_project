## Getting and Cleaning Data - Course Project

The goal of this project is to prepare tidy data that can be used for later analysis. The raw data represent data collected from the accelerometers from the Samsung Galaxy S smartphone from a group of 30 volunteers within an age bracket of 19-48 years. For more information check out the README.txt file inside the zip file or refer to [codebook.md]().

### Before you start
The original dataset will be downloaded and unzipped on your current working directory. If you already have a folder named "UCI HAR Dataset", the script will attempt to read the files from that location. Please change your working directory to a different location if this is the case.

### 

#### STEP 0: Getting the data

The following script downloads and unzips the dataset to the current working directory.

```R
# Variables that contain information about the file to be downloaded
filename <- "data.zip"
path <- "UCI HAR Dataset"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "

## Download and unzip the dataset:
if (!file.exists(filename)) {
  download.file(fileURL, filename, method="curl")
}
if (!file.exists(file.path(path))) {
  unzip(filename)
}
```


#### STEP 1: Merges the training and the test sets to create one data set.

The dataset is in 8 different files. We start with the subject, activity and features data. The appropriate columns names for features data are in the "features.txt" file, so we read them and before importing the features file.

```R
# Read subject data
subject <- rbind(read.table(file.path(path, "train", "subject_train.txt"), header = FALSE, col.names = c('subject')),
                 read.table(file.path(path, "test", "subject_test.txt"), header = FALSE, col.names = c('subject')))

# Read activity data
activity<- rbind(read.table(file.path(path, "train", "y_train.txt"), header = FALSE, col.names = c('activity')),
                 read.table(file.path(path, "test", "y_test.txt"), header = FALSE, col.names = c('activity')))

# Read features column names
featuresNames <- read.table(file.path(path, "features.txt"), header = FALSE)

# Read features data
features<- rbind(read.table(file.path(path, "train", "x_train.txt"), header = FALSE, col.names = featuresNames$V2, check.names = FALSE),
                 read.table(file.path(path, "test", "x_test.txt"), header = FALSE, col.names = featuresNames$V2, check.names = FALSE))

# Merging data
mergedData <- cbind(subject, activity, features)
```


#### STEP 2: Extracts only the measurements on the mean and standard deviation for each measurement.

We select the column indexes for column names that contain "mean()" or "std()"", as well as the subject and activity columns. After this, we filter the data and assign it to a new variable.


```R
meanStdCols <- grep("subject|activity|-(mean|std)\\(\\)", names(mergedData))

meanStdData <- mergedData[,meanStdCols]
```


#### STEP 3: Uses descriptive activity names to name the activities in the data set

Since the descriptive activity names are on a different file, we read them and merge them to the dataset form the previous step, to obtain the desired data.

```R
activityNames <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names = c('activity','activityDescription'))
meanStdData_ActivityNames <- merge(activityNames, meanStdData, by='activity', all.x=TRUE)
```


### STEP 4: Appropriately labels the data set with descriptive variable names.

Since our data set has abbreviated column names, we expand them using the information found in features_info.txt as reference.

```R
names(meanStdData_ActivityNames) <- gsub("^t", "time-", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("^f", "frequency-", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("\\(\\)", "", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("(Acc)([^-])", "-Accelerometer-\\2", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("Acc-", "-Accelerometer-", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("(Gyro)([^-])", "-Gyroscope-\\2", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("Gyro-", "-Gyroscope-", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("Mag", "Magnitude", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("([^-])(Magnitude)", "\\1-Magnitude", names(meanStdData_ActivityNames))
names(meanStdData_ActivityNames) <- gsub("BodyBody", "Body", names(meanStdData_ActivityNames))
```

#### STEP 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We use the aggregate function to calculate the mean of each variable for each activity and each subject. Finally we write the result to a file.

```R
tidyData <- aggregate(. ~subject + activityDescription, meanStdData_ActivityNames, mean)
tidyData <- tidyData[order(tidyData$subject, tidyData$activity),]

write.table(tidyData, "tidyData.txt", row.name=FALSE)
```