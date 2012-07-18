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
  $ echo a1 > a
  $ hg ci -m "change a to a1" 
  $ echo a2 > a
  $ hg ci -m "change a to a2" 
  $ echo a1 > a
  $ hg ci -m "change a to a1" 

  $ hg log -v
  changeset:   5:937054ce2155
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a to a1
  
  
  changeset:   4:e4e2aba1f2da
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a to a2
  
  
  changeset:   3:f02114de4df2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a to a1
  
  
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
  
  
  $ hg collapse -r 4:5
  reverting a
  collapse completed

  $ hg log -v
  changeset:   4:be438300013d
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  change a to a2
  ----------------
  change a to a1
  
  
  changeset:   3:f02114de4df2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a to a1
  
  
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
  
  
