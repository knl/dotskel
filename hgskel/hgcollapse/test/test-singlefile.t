  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
  > collapse = $base/hgext/collapse.py
  > EOF

  $ add() {
  >    echo "$1" > "$1"
  >    hg add "$1"
  >    hg ci -m "add $1"
  > }

  $ chg() {
  >    echo "$2" > "$1"
  >    hg ci -m "change $1"
  > }

  $ hg init alpha
  $ cd alpha
  $ add a
  $ add b
  $ add c
  $ add d
  $ chg a x
  $ chg b x
  $ add e
  $ chg d x
  $ chg a y
  $ chg a z

  $ hg log
  changeset:   9:6f44456eadca
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     change a
  
  changeset:   8:a64a9f61adf5
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     change a
  
  changeset:   7:4bed095917ba
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     change d
  
  changeset:   6:6f890aafa926
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   5:00b9f31adff9
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     change b
  
  changeset:   4:d8d5f7ec46e8
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     change a
  
  changeset:   3:47d2a3944de8
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   2:4538525df7e2
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add c
  
  changeset:   1:7c3bad9141dc
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add b
  
  changeset:   0:1f0dee641bb7
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -n --usefirst -a -F --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4] parents [2]
  find_chunk(4, set([0, 1, 2, 3])) children [5] parents [3]
  singlefile current 4 fs set(['a', 'c', 'b', 'd']) cs set(['a']) -> stop
  Collapsing revisions set([0, 1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [9]
  will move revisions: [4, 5, 6, 7, 8, 9]
  noop: not collapsing

  $ hg collapse -a --usefirst -F 
  adding a
  adding b
  adding c
  adding d
  reverting a
  reverting b
  adding e
  reverting d
  reverting a
  reverting a
  collapse completed
  $ hg log -v
  changeset:   6:9b2a16836033
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   5:b870da015f96
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   4:441d5f833aa0
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  change d
  
  
  changeset:   3:30f82a9d6f33
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   2:adbabea82c30
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       b
  description:
  change b
  
  
  changeset:   1:8b359d1da0c1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   0:ff6fe4183e85
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b c d
  description:
  add a
  ----------------
  add b
  ----------------
  add c
  ----------------
  add d
  
  
  $ hg collapse -a --usefirst -F 
  reverting a
  reverting b
  reverting d
  adding e
  reverting a
  reverting a
  collapse completed
  $ hg log -v
  changeset:   3:19ac3ad376ce
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   2:9a27c7373280
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   1:33efc3d4f485
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b d e
  description:
  change a
  ----------------
  change b
  ----------------
  add e
  ----------------
  change d
  
  
  changeset:   0:ff6fe4183e85
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b c d
  description:
  add a
  ----------------
  add b
  ----------------
  add c
  ----------------
  add d
  
  

  $ hg collapse -a --usefirst -F 
  abort: no revision chunk found
  
  [255]

