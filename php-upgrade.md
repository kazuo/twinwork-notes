# PHP upgrade

You can simply change which PHP version `pkg` should point to and force the upgrade

Here's an example of upgrading PHP 8.2 to PHP 8.3

```
sh
for i in $(pkg query -g %n 'php82-*'); do pkg set -yn ${i}:php83-${i#php82-}; done
pkg upgrade -f
```