# Bash Script for SFTP Deployments

Believe it or not, there are still projects where the only way to make a deployment is using FTP/SFTP, so those nice SSH commands/scripts to have an automated deployment and CI/CD practices won't work. Furthermore, to drag & drop using tools such as Filezilla can be tedious when there are all kind of files in different directories. That's why I wrote this bash script to have a semi-automated deployment process.

```Bash
Usage:
  ./deploy.sh [-s (test|development|production)] [-d number]

      -s:         the server where new changes will be deployed (default: development)
      -d:         how old (in days) are the modified files to be deployed? (default: 1)

Execution example:
  ./deploy.sh -s test -d 3
```

## Contributing
Pull requests, bug reports, enhancements and feature requests are welcome.
