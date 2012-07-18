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
  $ hg tag tag2
  $ mkcommit e
  $ hg tag tag3
  $ mkcommit f
  $ mkcommit g
  $ hg tag tag4
  $ hg clone . ../beta
  updating to branch default
  8 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone . ../gamma
  updating to branch default
  8 files updated, 0 files merged, 0 files removed, 0 files unresolved

  $ hg log -v
  changeset:   10:6329d8158cf8
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag tag4 for changeset 8e0de046fc99
  
  
  changeset:   9:8e0de046fc99
  tag:         tag4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   8:e29d3f9eb2b6
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   7:887dd03b6c90
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag tag3 for changeset 939bc8715def
  
  
  changeset:   6:939bc8715def
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   5:ec6df80af7db
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag tag2 for changeset 41067822ab2a
  
  
  changeset:   4:41067822ab2a
  tag:         tag2
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
  
  
  $ hg collapse -r0:1
  adding a
  adding b
  adding .hgtags
  adding c
  reverting .hgtags
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
  
  
  changeset:   5:e6ad8fb7fc20
  tag:         tag4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   4:c38fbfb0379f
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   3:a4c3db04ba4f
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   2:e61e73fea077
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   1:38e114dd4cc8
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c
  description:
  add c
  
  
  changeset:   0:baa8680ec83d
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  
  $ hg collapse -r1:4
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   3:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   2:497010a64601
  tag:         tag4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   1:c0b8b2ea663a
  tag:         tag2
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d e f
  description:
  add c
  ----------------
  add d
  ----------------
  add e
  ----------------
  add f
  
  
  changeset:   0:baa8680ec83d
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  
  $ hg collapse -r2:3
  adding .hgtags
  adding g
  collapse completed
  $ hg log -v
  changeset:   3:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   2:* (glob)
  tag:         tag4
  user:        test
  date:        * (glob)
  files:       g
  description:
  add g
  
  
  changeset:   1:c0b8b2ea663a
  tag:         tag2
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d e f
  description:
  add c
  ----------------
  add d
  ----------------
  add e
  ----------------
  add f
  
  
  changeset:   0:baa8680ec83d
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  
  $ cd ../beta  
  $ hg collapse -a --repeat
  reverting .hgtags
  adding f
  adding g
  collapse completed
  reverting .hgtags
  adding e
  reverting .hgtags
  adding f
  adding g
  collapse completed
  adding .hgtags
  adding c
  adding d
  reverting .hgtags
  adding e
  reverting .hgtags
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
  changeset:   4:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   3:46ebcfceadf5
  tag:         tag4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f g
  description:
  add f
  ----------------
  add g
  
  
  changeset:   2:ede8ac6fb74a
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   1:f55edd33a2dd
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d
  description:
  add c
  ----------------
  add d
  
  
  changeset:   0:baa8680ec83d
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  


  $ cd ../gamma
  $ hg collapse --usefirst -a --repeat
  adding a
  adding b
  adding .hgtags
  adding c
  reverting .hgtags
  adding d
  reverting .hgtags
  adding e
  reverting .hgtags
  adding f
  reverting .hgtags
  adding g
  collapse completed
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   4:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   3:46ebcfceadf5
  tag:         tag4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f g
  description:
  add f
  ----------------
  add g
  
  
  changeset:   2:ede8ac6fb74a
  tag:         tag3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   1:f55edd33a2dd
  tag:         tag2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d
  description:
  add c
  ----------------
  add d
  
  
  changeset:   0:baa8680ec83d
  tag:         tag1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  
