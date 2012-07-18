  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
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
  $ mkcommit d
  $ mkcommit e
  $ mkcommit f
  $ mkcommit g
  $ hg update -r 3
  0 files updated, 0 files merged, 3 files removed, 0 files unresolved
  $ mkcommit n
  created new head
  $ mkcommit m
  $ hg update -r tip
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ mkcommit x
  $ mkcommit y
  $ mkcommit z

  $ hg log --graph
  @  changeset:   11:c1dc67a65ce6
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add z
  |
  o  changeset:   10:7b94815f7418
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add y
  |
  o  changeset:   9:094c125babce
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o  changeset:   8:38e2cd0cf7cb
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add m
  |
  o  changeset:   7:23840cbaa7b3
  |  parent:      3:47d2a3944de8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add n
  |
  | o  changeset:   6:9f1a23278c2c
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add g
  | |
  | o  changeset:   5:bbc3e4679176
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add f
  | |
  | o  changeset:   4:9d206ffc875e
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add e
  |
  o  changeset:   3:47d2a3944de8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add d
  |
  o  changeset:   2:4538525df7e2
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add c
  |
  o  changeset:   1:7c3bad9141dc
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add b
  |
  o  changeset:   0:1f0dee641bb7
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add a
  
  $ hg collapse -r 4:6
  adding e
  adding f
  adding g
  collapse completed

