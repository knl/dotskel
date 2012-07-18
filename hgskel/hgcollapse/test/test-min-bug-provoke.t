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
  $ mkcommit d
  $ mkcommit e
  $ mkcommit f
  $ hg update -r 0
  0 files updated, 0 files merged, 2 files removed, 0 files unresolved
  $ mkcommit n
  created new head
  $ hg merge
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m 'merge'

  $ hg log --graph
  @    changeset:   4:2a02a686e185
  |\   tag:         tip
  | |  parent:      3:75c497f37dd9
  | |  parent:      2:84be2a59bc6c
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   3:75c497f37dd9
  | |  parent:      0:88872feea69b
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add n
  | |
  o |  changeset:   2:84be2a59bc6c
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add f
  | |
  o |  changeset:   1:1955b2633bee
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add e
  |
  o  changeset:   0:88872feea69b
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add d
  
  $ hg collapse -r 1:2
  adding e
  adding f
  reverting e
  reverting f
  adding n
  collapse completed

  $ hg log --graph
  @    changeset:   3:bfd47c4f2897
  |\   tag:         tip
  | |  parent:      1:75c497f37dd9
  | |  parent:      2:a4af24141ea5
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   2:a4af24141ea5
  | |  parent:      0:88872feea69b
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add e
  | |
  o |  changeset:   1:75c497f37dd9
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add n
  |
  o  changeset:   0:88872feea69b
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add d
  
