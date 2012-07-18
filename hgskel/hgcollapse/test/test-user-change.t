  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
  > collapse = $base/hgext/collapse.py
  > EOF

  $ mkcommit() {
  >    echo "$1" > "$1"
  >    hg add "$1"
  >    hg ci -u "$2" -m "add $1"
  > }

  $ hg init alpha
  $ cd alpha
  $ mkcommit a arthur
  $ mkcommit b arthur
  $ mkcommit c arthur
  $ mkcommit d galahad
  $ mkcommit e galahad
  $ mkcommit f robin
  $ mkcommit g robin

  $ hg log -v
  changeset:   6:e56ff39b02bb
  tag:         tip
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   5:81ae0b2f98ee
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   4:507ca28dd3b3
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   3:329ed92a7260
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   2:3dba5b07b5ac
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c
  description:
  add c
  
  
  changeset:   1:0e9edcdd4148
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       b
  description:
  add b
  
  
  changeset:   0:5639cbe6bee6
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  add a
  
  
  $ hg collapse -a --repeat -u -f 
  adding f
  adding g
  collapse completed
  adding d
  adding e
  adding f
  adding g
  collapse completed
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   2:285565e26e94
  tag:         tip
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f g
  description:
  add f
  ----------------
  add g
  
  
  changeset:   1:e4bb575d1758
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d e
  description:
  add d
  ----------------
  add e
  
  
  changeset:   0:6a6bb04d53bf
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b c
  description:
  add a
  ----------------
  add b
  ----------------
  add c
  
  
  $ hg collapse -a -u -f 
  abort: no revision chunk found
  
  [255]
