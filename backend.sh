#!/bin/bash
log_folder="/var/log/expense"
script=$(echo $0 | cut -d "." -f1)
time=$(date +%Y-%m-%d-%H-%M-%S)
logfile="$log_folder/$script-$time.log"
mkdir -p $log_folder
r="\e[31m"
g="\e[32m"
y="\e[33m"


userid=$(id -u)
validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$r $2 not installed" | tee -a $logfile
        exit 1
    else
        echo -e "$g $2 is installed" | tee -a $logfile
    fi
}

if [ $userid -ne 0 ]
then
    echo "please run with the root privilages" | tee -a $logfile
    exit 1
fi

dnf module disable nodejs -y &>>$logfile
validate $? disabled nodejs

dnf module enable nodejs:20 -y &>>$logfile
validate $? enabled nodejs

dnf install nodejs -y &>>$logfile
validate $? installing nodejs

id expense &>>$logfile
if [ $? -ne 0 ]
then 
    useradd expense
    validate $? useradded
fi

cd /app &>>$logfile
if [ $? -ne 0 ]
then 
    mkdir /app
    validate $? directory
    curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
    cd /app
    unzip /tmp/backend.zip
fi
npm install &>>$logfile
validate $? npm

