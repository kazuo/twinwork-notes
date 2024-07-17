# Troubleshooting

## SABnzbd won't start

Everyone once in awhile... and unsure how after upgrading packages, some times `sabnzbd` wont' start with very little error logging information other than something that has to do with SSL/TLS.

I tried rolling back the package and even switch the package repo to FreeBSD quarterly release, but still have the same SSL/TLS handshake error. I even created a seperate jail with an older repo and it still won't start!

After trying multiple changes across 3 days, I ended up restarting my server and whatever the issue was no longer exists. So when in doubt, just restart...

(This might be easier if SABnzbd was in a jail instead on the host)