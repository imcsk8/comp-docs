# Create CentOS Custo Image

I wrote a shell script to create custom images but it was a hassle because I had to modify the script almos each time I created an image. 
That's why I switched to osbuild.

## Install OSBuild

```bash
# dnf install -y lorax lorax-composer lorax-templates-generic \
  composer-cli osbuild cockpit-composer weldr-client
```

