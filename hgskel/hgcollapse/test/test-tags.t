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
  $ hg tag tag1
  $ mkcommit c
  $ mkcommit d
  $ mkcommit e
  $ mkcommit f
  $ hg tag tag2
  $ mkcommit g

  $ hg log
  changeset:   8:2faa932a8cd5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   7:1ef81692c336
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag tag2 for changeset a67169324f71
  
  changeset:   6:a67169324f71
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   5:cc6da4b2c2d6
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   4:41067822ab2a
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   3:0f0c994c7b9c
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add c
  
  changeset:   2:a8084532793e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag tag1 for changeset 7c3bad9141dc
  
  changeset:   1:7c3bad9141dc
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add b
  
  changeset:   0:1f0dee641bb7
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ cat .hgtags
  7c3bad9141dcb46ff89abf5f61856facd56e476c tag1
  a67169324f7182208a585f345d7b02b8b878dd16 tag2

  $ hg collapse -r 3:4
  adding c
  adding d
  adding e
  adding f
  reverting .hgtags
  adding g
  collapse completed
  $ hg log
  changeset:   7:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  summary:     collapse tag fix
  
  changeset:   6:c0931faf4ea1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   5:3cfc751d17cd
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   4:6195a1f18847
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   3:531c2ef25d0e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add c
  
  changeset:   2:a8084532793e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag tag1 for changeset 7c3bad9141dc
  
  changeset:   1:7c3bad9141dc
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add b
  
  changeset:   0:1f0dee641bb7
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg update tip
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cat .hgtags
  7c3bad9141dcb46ff89abf5f61856facd56e476c tag1
  3cfc751d17cdfdbf3853134e17e3bee9803e66d7 tag2
