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

  $ hg collapse -n -a --usefirst
  noop: not collapsing
  $ hg collapse -n --auto --usefirst
  noop: not collapsing

  $ hg collapse -n --auto --usefirst --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4, 7] parents [2]
  Collapsing revisions set([0, 1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [12]
  will move revisions: [4, 5, 6, 7, 8, 9, 10, 11, 12]
  noop: not collapsing

  $ hg collapse -n --auto --usefirst --debug -r 1
  find_chunk(1, set([])) children [2] parents [0]
  find_chunk(2, set([1])) children [3] parents [1]
  find_chunk(3, set([1, 2])) children [4, 7] parents [2]
  Collapsing revisions set([1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [12]
  will move revisions: [4, 5, 6, 7, 8, 9, 10, 11, 12]
  noop: not collapsing

  $ hg collapse -n --auto --usefirst --debug -r 3
  find_chunk(3, set([])) children [4, 7] parents [2]
  find_chunk(4, set([])) children [5] parents [3]
  find_chunk(5, set([4])) children [6] parents [4]
  find_chunk(6, set([4, 5])) children [9] parents [5]
  find_chunk(9, set([4, 5, 6])) children [10] parents [8, 6]
  Collapsing revisions set([4, 5, 6])
  get_hgtags_from_heads: rev: 6 heads: [12]
  will move revisions: [9, 10, 11, 12]
  noop: not collapsing

  $ hg collapse -n --auto --usefirst --debug -r 6
  find_chunk(6, set([])) children [9] parents [5]
  find_chunk(9, set([6])) children [10] parents [8, 6]
  find_chunk(10, set([])) children [11] parents [9]
  find_chunk(11, set([10])) children [12] parents [10]
  find_chunk(12, set([10, 11])) children [] parents [11]
  Collapsing revisions set([10, 11, 12])
  get_hgtags_from_heads: rev: 12 heads: [12]
  will move revisions: []
  noop: not collapsing

  $ hg collapse -a --usefirst
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
  adding n
  adding m
  adding e
  adding f
  adding g
  adding x
  adding y
  adding z
  collapse completed

  $ hg log --graph
  @  changeset:   9:7df01aea5723
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add z
  |
  o  changeset:   8:3bded8e79801
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add y
  |
  o  changeset:   7:fc8629a03d73
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   6:0bd87ea899fa
  |\   parent:      5:19da2917114f
  | |  parent:      3:eabc86a84f9d
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   5:19da2917114f
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add m
  | |
  | o  changeset:   4:f0500128d072
  | |  parent:      0:ff6fe4183e85
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add n
  | |
  o |  changeset:   3:eabc86a84f9d
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add g
  | |
  o |  changeset:   2:4b8f9de26843
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add f
  | |
  o |  changeset:   1:04e9e84ae13f
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add e
  |
  o  changeset:   0:ff6fe4183e85
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add a
  
  $ hg collapse -n --debug -a --usefirst
  find_chunk(0, set([])) children [1, 4] parents [-1]
  find_chunk(1, set([])) children [2] parents [0]
  find_chunk(2, set([1])) children [3] parents [1]
  find_chunk(3, set([1, 2])) children [6] parents [2]
  find_chunk(6, set([1, 2, 3])) children [7] parents [5, 3]
  Collapsing revisions set([1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [9]
  will move revisions: [6, 7, 8, 9]
  noop: not collapsing
  $ hg collapse -a --usefirst
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
  @  changeset:   7:062e99202e9d
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add z
  |
  o  changeset:   6:9d6f509cb0b2
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add y
  |
  o  changeset:   5:462f17e507ea
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add x
  |
  o    changeset:   4:bcc0da53327e
  |\   parent:      2:19da2917114f
  | |  parent:      3:145b37fcb973
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     merge
  | |
  | o  changeset:   3:145b37fcb973
  | |  parent:      0:ff6fe4183e85
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add e
  | |
  o |  changeset:   2:19da2917114f
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  summary:     add m
  | |
  o |  changeset:   1:f0500128d072
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    summary:     add n
  |
  o  changeset:   0:ff6fe4183e85
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     summary:     add a
  
  $ hg collapse -n --debug -a --usefirst
  find_chunk(0, set([])) children [1, 3] parents [-1]
  find_chunk(1, set([])) children [2] parents [0]
  find_chunk(2, set([1])) children [4] parents [1]
  find_chunk(4, set([1, 2])) children [5] parents [2, 3]
  Collapsing revisions set([1, 2])
  get_hgtags_from_heads: rev: 2 heads: [7]
  will move revisions: [4, 5, 6, 7]
  noop: not collapsing

  $ hg collapse -a --usefirst
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
  @  changeset:   6:e5624853e3db
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add z
  |
  o  changeset:   5:58f5744585df
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add y
  |
  o  changeset:   4:9b4566d9af10
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
  
  $ hg collapse -n --debug -a --usefirst
  find_chunk(0, set([])) children [1, 2] parents [-1]
  find_chunk(1, set([])) children [3] parents [0]
  find_chunk(3, set([1])) children [4] parents [2, 1]
  find_chunk(4, set([])) children [5] parents [3]
  find_chunk(5, set([4])) children [6] parents [4]
  find_chunk(6, set([4, 5])) children [] parents [5]
  Collapsing revisions set([4, 5, 6])
  get_hgtags_from_heads: rev: 6 heads: [6]
  will move revisions: []
  noop: not collapsing
  $ hg collapse -a --usefirst
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
  
  $ hg collapse -n --debug -a --usefirst
  find_chunk(0, set([])) children [1, 2] parents [-1]
  find_chunk(1, set([])) children [3] parents [0]
  find_chunk(3, set([1])) children [4] parents [2, 1]
  find_chunk(4, set([])) children [] parents [3]
  find_chunk(2, set([])) children [3] parents [0]
  find_chunk(3, set([2])) children [4] parents [2, 1]
  find_chunk(4, set([])) children [] parents [3]
  abort: no revision chunk found
  
  [255]
  $ hg collapse -a --usefirst
  abort: no revision chunk found
  
  [255]
