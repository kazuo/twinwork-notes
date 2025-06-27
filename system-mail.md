# System Mail

I previously used `mail/ssmtp` instead of `sendmail` to get whatever system emails needed to go out. However, `mail/ssmtp` doesn't look like there's a current maintainer for the FreeBSD port and maybe it's time to explore other ways. This is probably overkill (yes, it is), but wanted to see what if I were to host a mail server at home. What can go wrong? (Lots of things, bounces... undelivered mail for one...)

Let's see if we can do this on a jail and we'll need to figiure out how to get the actual system to use it for outgoing mail. 