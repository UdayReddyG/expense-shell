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
        echo -e "$r $2 not sucessfull" | tee -a $logfile
        exit 1
    else
        echo -e "$g $2 is sucessfull" | tee -a $logfile
    fi
}

if [ $userid -ne 0 ]
then
    echo "please run with the root privilages" | tee -a $logfile
    exit 1
fi

dnf install nginx -y &>>$logfile
validate $? nginx

systemctl enable nginx
validate $? enabled
systemctl start nginx
validate $? starting

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? removal

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? content

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$logfile
validate $? unzip

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx