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

  $ hg log -v
  changeset:   8:2faa932a8cd5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   7:1ef81692c336
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag tag2 for changeset a67169324f71
  
  
  changeset:   6:a67169324f71
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   5:cc6da4b2c2d6
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   4:41067822ab2a
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   3:0f0c994c7b9c
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c
  description:
  add c
  
  
  changeset:   2:a8084532793e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag tag1 for changeset 7c3bad9141dc
  
  
  changeset:   1:7c3bad9141dc
  tag:         tag1
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
  
  
  $ hg collapse -r 2:4
  adding .hgtags
  adding c
  adding d
  reverting .hgtags
  adding e
  reverting .hgtags
  adding f
  reverting .hgtags
  adding g
  collapse completed
  $ hg log -v
  changeset:   6:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   5:b021c62219bb
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   4:bb9c88befe66
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   3:79d266b9db39
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   2:9324d045e03a
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d
  description:
  add c
  ----------------
  add d
  
  
  changeset:   1:7c3bad9141dc
  tag:         tag1
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
  
  
