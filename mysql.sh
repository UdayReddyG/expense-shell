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

dnf install mysql-server -y
validate $? mysql

systemctl enable mysqld
validate $? mysql

systemctl start mysqld
validate $? mysql

mysql -h database.the4teen.info -u root -pExpenseApp@1 -e 'show databases;' &>>$logfile
if [ $? -ne 0 ]
then
    echo "mysql is not setup.... setting up now"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? mysql
else
    echo "mysql already installed"
fi


