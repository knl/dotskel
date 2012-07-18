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
  $ hg merge
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m 'merge'
  $ mkcommit x
  $ mkcommit y
  $ mkcommit z

  $ hg collapse -n
  abort: no revisions specified
  [255]

  $ hg collapse -n -a
  noop: not collapsing
  $ hg collapse -n --auto
  noop: not collapsing

  $ hg collapse -n --auto --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4, 7] parents [2]
  find_chunk(4, set([])) children [5] parents [3]
  find_chunk(5, set([4])) children [6] parents [4]
  find_chunk(6, set([4, 5])) children [9] parents [5]
  find_chunk(9, set([4, 5, 6])) children [10] parents [8, 6]
  find_chunk(9, set([])) children [10] parents [8, 6]
  find_chunk(10, set([])) children [11] parents [9]
  find_chunk(11, set([10])) children [12] parents [10]
  find_chunk(12, set([10, 11])) children [] parents [11]
  Collapsing revisions set([10, 11, 12])
  get_hgtags_from_heads: rev: 12 heads: [12]
  will move revisions: []
  noop: not collapsing

  $ hg collapse -a
  adding x
  adding y
  adding z
  collapse completed

  $ hg log --graph
  @  changeset:   10:f89cbde54929
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   9:b17788d8ea7f
  |\   parent:      8:38e2cd0cf7cb
  | |  parent:      6:9f1a23278c2c
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   8:38e2cd0cf7cb
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add m
  | |
  | o  changeset:   7:23840cbaa7b3
  | |  parent:      3:47d2a3944de8
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add n
  | |
  o |  changeset:   6:9f1a23278c2c
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add g
  | |
  o |  changeset:   5:bbc3e4679176
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add f
  | |
  o |  changeset:   4:9d206ffc875e
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
  
  $ hg collapse -n --debug -a
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4, 7] parents [2]
  find_chunk(4, set([])) children [5] parents [3]
  find_chunk(5, set([4])) children [6] parents [4]
  find_chunk(6, set([4, 5])) children [9] parents [5]
  find_chunk(9, set([4, 5, 6])) children [10] parents [8, 6]
  find_chunk(9, set([])) children [10] parents [8, 6]
  find_chunk(10, set([])) children [] parents [9]
  Collapsing revisions set([4, 5, 6])
  get_hgtags_from_heads: rev: 6 heads: [10]
  will move revisions: [9, 10]
  noop: not collapsing
  $ hg collapse -a
  adding e
  adding f
  adding g
  reverting e
  reverting f
  reverting g
  adding m
  adding n
  adding x
  adding y
  adding z
  collapse completed
  $ hg log --graph
  @  changeset:   8:ff0fa8cff528
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   7:9e0e0679b6f6
  |\   parent:      5:38e2cd0cf7cb
  | |  parent:      6:ec6ba9434785
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   6:ec6ba9434785
  | |  parent:      3:47d2a3944de8
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add e
  | |
  o |  changeset:   5:38e2cd0cf7cb
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add m
  | |
  o |  changeset:   4:23840cbaa7b3
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add n
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
  
  $ hg collapse -n --debug -a
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4, 6] parents [2]
  find_chunk(4, set([])) children [5] parents [3]
  find_chunk(5, set([4])) children [7] parents [4]
  find_chunk(7, set([4, 5])) children [8] parents [5, 6]
  find_chunk(7, set([])) children [8] parents [5, 6]
  find_chunk(8, set([])) children [] parents [7]
  Collapsing revisions set([4, 5])
  get_hgtags_from_heads: rev: 5 heads: [8]
  will move revisions: [7, 8]
  noop: not collapsing

  $ hg collapse -a
  adding m
  adding n
  adding e
  adding f
  adding g
  adding x
  adding y
  adding z
  collapse completed
  $ hg log --graph
  @  changeset:   7:9c2fac9f71a4
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   6:4610642609b4
  |\   parent:      5:5f39d293fadc
  | |  parent:      4:ec6ba9434785
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   5:5f39d293fadc
  | |  parent:      3:47d2a3944de8
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add n
  | |
  o |  changeset:   4:ec6ba9434785
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
  
  $ hg collapse -n --debug -a
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4, 5] parents [2]
  find_chunk(4, set([])) children [6] parents [3]
  find_chunk(6, set([4])) children [7] parents [5, 4]
  find_chunk(7, set([])) children [] parents [6]
  find_chunk(5, set([])) children [6] parents [3]
  find_chunk(6, set([5])) children [7] parents [5, 4]
  find_chunk(7, set([])) children [] parents [6]
  Collapsing revisions set([0, 1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [7]
  will move revisions: [4, 5, 6, 7]
  noop: not collapsing
  $ hg collapse -a
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  removing e
  removing f
  removing g
  adding m
  adding n
  adding e
  adding f
  adding g
  adding x
  adding y
  adding z
  collapse completed
  $ hg log --graph
  @  changeset:   4:5fe5b9172a19
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   3:60db41dbc1aa
  |\   parent:      2:1c2f5804e1e7
  | |  parent:      1:145b37fcb973
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   2:1c2f5804e1e7
  | |  parent:      0:ff6fe4183e85
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add n
  | |
  o |  changeset:   1:145b37fcb973
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add e
  |
  o  changeset:   0:ff6fe4183e85
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add a
  
  $ hg collapse -n --debug -a
  find_chunk(0, set([])) children [1, 2] parents [-1]
  find_chunk(1, set([])) children [3] parents [0]
  find_chunk(3, set([1])) children [4] parents [2, 1]
  find_chunk(4, set([])) children [] parents [3]
  find_chunk(2, set([])) children [3] parents [0]
  find_chunk(3, set([2])) children [4] parents [2, 1]
  find_chunk(4, set([])) children [] parents [3]
  abort: no revision chunk found
  
  [255]
  $ hg collapse -a
  abort: no revision chunk found
  
  [255]
