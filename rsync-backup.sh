#!/bin/bash
 
# expects that password-less SSH key based authentication has already
# been configured on the client and server sides of the operation
# otherwise expect to enter user's SSH password/passphrase several times
# for commands passed to the server
# Date examples imply that "today's" backup is being done 2011-10-29
# This script uses rsync's ability to perform incremental backups via hard links,
# so it is not reliant on snapshot abilities of the filesystem on which the 
# backups are being stored.  For backups that will be stored to a target that 
# can handle its own storage and manipulation of snapshots, this method may be
# unnecessary and could be done more cleanly other ways.
 
# config
## host name or IP of ssh/rsync server
SYNCSERVER=torrents

## what to sync
SYNCWHAT=/home/`whoami`  #'my' home directory

## where to sync it, as the server filestructure would recognize it
BASEDIR=/mnt/torrent-pool/home-backups/`whoami`@`hostname`

## can be changed to taste if backups need to happen more often than daily, or whatever
NOW=`date +%F`
# end of config
 
WORKDIR=$BASEDIR/$NOW
NOWDIR=$BASEDIR/now
YESTERDIR=$BASEDIR/last
# assumes that /backup-path/last was left pointing to /backup-path/2011-10-28
 
#setup
ssh $SYNCSERVER mkdir -p $WORKDIR
# ex. /backup-path/2011-10-29
# may work without pre-creation, but why tempt fate?
ssh $SYNCSERVER rm -fv $NOWDIR
# ex. /backup-path/now
ssh $SYNCSERVER ln -s $WORKDIR $NOWDIR
# ex. /backup-path/2011-10-29 -> /backup-path/now
 
# act
rsync -aHP $SYNCWHAT/ $SYNCSERVER:$NOWDIR/ --link-dest=$YESTERDIR/
 
# cleanup
ssh $SYNCSERVER rm -fv $YESTERDIR
# ex. /backup-path/last
ssh $SYNCSERVER ln -s $WORKDIR $YESTERDIR
# ex. /backup-path/2011-10-29 -> /backup-path/last

