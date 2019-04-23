# Wordpress behind HAProxy with SSL termination

Setting this up is really fucking problematic *(yes i'm writing this after frustrating debugging and reading lots of documentation)* so in order to make my life (and hopefully yours) easier i'm documenting this.

## HAProxy

I'll asume that you already know how to setup HAProxy backends with SSL and just focus on the tricky part. Turns out that you have to make HAProxy send the `X-Forwarded-Proto` header to make Wordpress know that she's behind a SSL terminating proxy.

```
frontend web-https
    http-request set-header X-Forwarded-Proto https if { ssl_fc }
```


## Wordpress

I'll also assume here that you know how to setup wordpress:

You have to add some code to `wp-config.php` to check the `X-Forwarded-Proto` that HAProxy sets up.

```
define('FORCE_SSL_ADMIN', true);


if($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'){
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}
```

That's it!
Be happy :D

# References
* https://www.oxcrag.net/2017/04/30/wordpress-behind-haproxy-with-tls-termination/
* https://www.feliciano.tech/blog/running-wordpress-behind-an-sslhttps-terminating-proxy/
