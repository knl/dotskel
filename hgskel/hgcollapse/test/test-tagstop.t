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
  $ mkcommit a
  $ mkcommit b
  $ mkcommit c
  $ mkcommit d
  $ hg tag footag
  $ mkcommit e
  $ mkcommit f
  $ mkcommit g

  $ hg log -v
  changeset:   7:cc42c5850121
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   6:26f591e362e9
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   5:31e8e57fa7b4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   4:b5f6bbec946a
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       .hgtags
  description:
  Added tag footag for changeset 47d2a3944de8
  
  
  changeset:   3:47d2a3944de8
  tag:         footag
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
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
  
  
  $ hg collapse -n -a --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4] parents [2]
  find_chunk(4, set([0, 1, 2, 3])) children [5] parents [3]
  parent 3 has tags ['footag'] -> stop
  find_chunk(4, set([])) children [5] parents [3]
  parent 3 has tags ['footag'] -> stop
  find_chunk(5, set([4])) children [6] parents [4]
  find_chunk(6, set([4, 5])) children [7] parents [5]
  find_chunk(7, set([4, 5, 6])) children [] parents [6]
  Collapsing revisions set([4, 5, 6, 7])
  get_hgtags_from_heads: rev: 7 heads: [7]
  get_hgtags_from_heads: head_hgtags[cc42c58501215260ae571291586f8b656836eef2]:
  47d2a3944de8b013de3be9578e8e344ea2e6c097 footag
  
  will move revisions: []
  noop: not collapsing

  $ hg collapse -a
  adding .hgtags
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   5:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   4:ec6ba9434785
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e f g
  description:
  add e
  ----------------
  add f
  ----------------
  add g
  
  
  changeset:   3:47d2a3944de8
  tag:         footag
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
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
  
  
  $ hg collapse -n -a --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4] parents [2]
  find_chunk(4, set([0, 1, 2, 3])) children [5] parents [3]
  parent 3 has tags ['footag'] -> stop
  find_chunk(4, set([])) children [5] parents [3]
  parent 3 has tags ['footag'] -> stop
  find_chunk(5, set([4])) children [] parents [4]
  .hgtags in head 5 -> exclude
  Collapsing revisions set([0, 1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [5]
  get_hgtags_from_heads: head_hgtags[*]: (glob)
  47d2a3944de8b013de3be9578e8e344ea2e6c097 footag
  
  will move revisions: [4, 5]
  noop: not collapsing
  $ hg collapse -a
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   2:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   1:* (glob)
  user:        test
  date:        * (glob)
  files:       e f g
  description:
  add e
  ----------------
  add f
  ----------------
  add g
  
  
  changeset:   0:ff6fe4183e85
  tag:         footag
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
  
  
  $ hg collapse -a
  abort: no revision chunk found
  
  [255]

  $ hg collapse -a -T
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   1:* (glob)
  tag:         tip
  user:        test
  date:        * (glob)
  files:       .hgtags
  description:
  collapse tag fix
  
  
  changeset:   0:58834c40a462
  tag:         footag
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b c d e f g
  description:
  add a
  ----------------
  add b
  ----------------
  add c
  ----------------
  add d
  ----------------
  add e
  ----------------
  add f
  ----------------
  add g
  
  
