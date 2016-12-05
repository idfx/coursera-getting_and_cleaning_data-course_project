## Coursera - Johns Hopkins Data Science Specialization
## Getting and Cleaning Data
## Week 4 - Course Project
## Juan Lara
## December 4, 2016

################# STEP 0 ######################
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

################# STEP 1 ######################
# Merges the training and the test sets to create one data set.

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

################# STEP 2 ######################
# Extracts only the measurements on the mean and standard deviation for each measurement.
meanStdCols <- grep("subject|activity|-(mean|std)\\(\\)", names(mergedData))

meanStdData <- mergedData[,meanStdCols]

################# STEP 3 ######################
# Uses descriptive activity names to name the activities in the data set
activityNames <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names = c('activity','activityDescription'))
meanStdData_ActivityNames <- merge(activityNames, meanStdData, by='activity', all.x=TRUE)

################# STEP 4 ######################
# Appropriately labels the data set with descriptive variable names.
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

################# STEP 5 ######################
# From the data set in step 4, creates a second, independent tidy data set with the 
# average of each variable for each activity and each subject.

tidyData <- aggregate(. ~subject + activityDescription, meanStdData_ActivityNames, mean)
tidyData <- tidyData[order(tidyData$subject, tidyData$activity),]

write.table(tidyData, "tidyData.txt", row.name=FALSE)
