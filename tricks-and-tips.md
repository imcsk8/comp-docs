# Linux Tricks and Tips

## Shell

* **Remove string with newline using sed**
```
 sed -i -e ':a' -e 'N' -e '$!ba' -e  's/string to remove\n//g' file
```

* **Check SMTPS connection**
```
# openssl s_client -connect imap.gmail.com:993 
```
