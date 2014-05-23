GDCD-P2
=======
This will create two files.

The R code will first read in features.txt, which contains colNames for the actual data
and then it will read in activity_labels.txt, which contains labels of activities

Next it will read in training data files, create headers and merge with the activities.
Lastly it is combined to create the training data.

The same process is done for the test data and combined with the training data.

Next it will extract only the measurements on the mean and standard deviation
and output as subdat.txt

To create a second, independent tidy data set with the average of each variable 
for each activity and each subject the data frame is split by subjectID

The code will then extract only the names of the variables required for each subjectID
and after some renaming the data is saved as avgs.txt.
