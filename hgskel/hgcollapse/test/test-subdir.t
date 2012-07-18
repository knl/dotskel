  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > collapse = $base/hgext/collapse.py
  > EOF

  $ mkcommit() {
  >    echo "$1" > "$1"
  >    hg add "$1"
  >    hg ci -m "add $1"
  > }

  $ hg init alpha
  $ cd alpha
  $ mkcommit a
  $ mkcommit b
  $ mkcommit c
  $ mkdir sub
  $ cd sub
  $ mkcommit d
  $ mkcommit e
  $ mkcommit f
  $ mkcommit g
  $ hg log -v
  changeset:   6:7bf74dc55851
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       sub/g
  description:
  add g
  
  
  changeset:   5:76d785119df6
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       sub/f
  description:
  add f
  
  
  changeset:   4:5e6479ad3d99
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       sub/e
  description:
  add e
  
  
  changeset:   3:e92175ae4915
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       sub/d
  description:
  add d
  
  
  changeset:   2:4538525df7e2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c
  description:
  add c
  
  
  changeset:   1:7c3bad9141dc
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       b
  description:
  add b
  
  
  changeset:   0:1f0dee641bb7
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  add a
  
  
  $ pwd
  $TESTTMP/alpha/sub

  $ hg collapse -r 0:2
  adding a
  adding b
  adding c
  adding sub/d
  adding sub/e
  adding sub/f
  adding sub/g
  collapse completed
 
