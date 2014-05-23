## set paths
project_path = file.path(Sys.getenv('HOME'), '/R Programming/GDCD P2')
data_path = file.path(project_path, 'UCI HAR Dataset')

features_path = file.path(data_path, 'features.txt')
activities_path = file.path(data_path, 'activity_labels.txt')

train_path = file.path(data_path, 'train')
test_path = file.path(data_path, 'test')
train_signals_path = file.path(train_path, 'Inertial Signals')
test_signals_path = file.path(test_path, 'Inertial Signals')

X_train_path = file.path(train_path, 'X_train.txt')
y_train_path = file.path(train_path, 'y_train.txt')
subject_train_path = file.path(train_path, 'subject_train.txt')

X_test_path = file.path(test_path, 'X_test.txt')
y_test_path = file.path(test_path, 'y_test.txt')
subject_test_path = file.path(test_path, 'subject_test.txt')

## read in features.txt, which contains colNames for the actual data
features = read.table(features_path, header=FALSE, stringsAsFactors=FALSE)
names(features) = c('colIdx', 'colName')

## read in activity_labels.txt, which contains labels of activities
activities = read.table(activities_path, header=FALSE, stringsAsFactors=FALSE)
names(activities) = c('activityIdx', 'activity')

## read in training data files
train.X = read.table(X_train_path, header=FALSE)
train.y = read.table(y_train_path, header=FALSE)
train.subject = read.table(subject_train_path, header=FALSE)

## check dimensions
dim(features)
dim(train.X)
dim(train.y)
dim(train.subject)

## create headers for training data files
names(train.X) = features$colName
names(train.y) = 'activityIdx'
names(train.subject) = 'subjectID'

## merge train.y and activities
train.y.update = merge(train.y, activities)

## combine to create training data
dat.train = cbind(train.X, activity=train.y$activity, train.subject)
dim(dat.train)
names(dat.train)

## read in testing data files
test.X = read.table(X_test_path, header=FALSE)
test.y = read.table(y_test_path, header=FALSE)
test.subject = read.table(subject_test_path, header=FALSE)

## check dimensions
dim(features)
dim(test.X)
dim(test.y)
dim(test.subject)

## create headers for testing data files
names(test.X) = features$colName
names(test.y) = 'activityIdx'
names(test.subject) = 'subjectID'

## merge test.y and activities
test.y.update = merge(test.y, activities)

## combine to create testing data
dat.test = cbind(test.X, activity=test.y$activity, test.subject)
dim(dat.test)
names(dat.test)

## Stack the training and the test sets to create one data set
dat = rbind(dat.train, dat.test)
dim(dat)

## clean names(subdat) by substituting () with ''
names(dat) = gsub('\\(\\)$', '', names(dat))
names(dat) = gsub('\\(\\)-', '-', names(dat))
names(dat) = gsub('\\(\\)', '', names(dat))
names(dat)

## Extracts only the measurements on the mean and standard deviation
colNames = names(dat)
# get a logical vector (match or not for each element of colNames)
matched = grepl('mean|std', colNames) 
keep = colNames[matched]
length(keep)

## subset dat keeping only the matched columns
subdat = dat[, keep]
dim(subdat)
dim(dat)
names(subdat)

## write out subdat
write.table(subdat, file=file.path(project_path, 'subdat.txt'), row.names=F)

############################################################################
## Creates a second, independent tidy data set with the average of each ####
## variable for each activity and each subject                          ####
############################################################################

## initialize a data frame to collect data to be returned
dat.avgs = data.frame()

## split dat by subjectID
dat.by.subject = split(dat, dat$subjectID)

# ## only look at subject 1
# temp = dat.by.subject[[1]]
# dat.by.activity = split(temp, temp$activity)
# temp = sapply(dat.by.activity, colMeans)
# temp = t(temp) # transpose temp
# str(temp)
# temp

for (i in seq_along(dat.by.subject)){
    ## get the ith subject's data
    temp = dat.by.subject[[i]]
    ## split it by activity
    dat.by.activity = split(temp, temp$activity)
    ## get the avg of each variable for each activity and each subject
    result = sapply(dat.by.activity, colMeans)
    ## transpose the result so that each row represent a (subject, activity)
    ## and each column represent a variable
    result = t(result) 
    ## append result to dat.avgs
    dat.avgs = rbind(dat.avgs, result)
}

## extract only the names of the variables
is.varname = ! names(dat.avgs) %in% c('activity', 'subjectID')
varnames = names(dat.avgs)[is.varname]
## add 'avg.' to each variable name
varnames = paste('avg', varnames, sep='.')
## rename dat.avgs using varnames
names(dat.avgs)[is.varname] = varnames
names(dat.avgs)
## check dimension
dim(dat.avgs)

## write out dat.avgs
write.table(dat.avgs, file=file.path(project_path, 'avgs.txt'), row.names=F)
