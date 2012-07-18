  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
  > collapse = $base/hgext/collapse.py
  > EOF

  $ mkcommit() {
  >    echo "$1" > "$1"
  >    hg add "$1"
  >    hg ci -d "$2" -m "add $1"
  > }

  $ hg init alpha
  $ cd alpha
  $ mkcommit a "2000-01-01 12:00"
  $ mkcommit b "2000-01-01 12:15"
  $ mkcommit c "2000-01-01 12:20"
  $ mkcommit d "2000-01-02 12:00"
  $ mkcommit e "2000-01-02 13:00"
  $ mkcommit f "2000-01-02 14:00"
  $ mkcommit g "2000-01-03 12:00"

  $ hg log
  changeset:   6:700a6185fa2f
  tag:         tip
  user:        test
  date:        Mon Jan 03 12:00:00 2000 +0000
  summary:     add g
  
  changeset:   5:85507e35b331
  user:        test
  date:        Sun Jan 02 14:00:00 2000 +0000
  summary:     add f
  
  changeset:   4:a594dbd65406
  user:        test
  date:        Sun Jan 02 13:00:00 2000 +0000
  summary:     add e
  
  changeset:   3:1918872f9f11
  user:        test
  date:        Sun Jan 02 12:00:00 2000 +0000
  summary:     add d
  
  changeset:   2:5b55beac0b59
  user:        test
  date:        Sat Jan 01 12:20:00 2000 +0000
  summary:     add c
  
  changeset:   1:54615d5be4be
  user:        test
  date:        Sat Jan 01 12:15:00 2000 +0000
  summary:     add b
  
  changeset:   0:4e81d08a3677
  user:        test
  date:        Sat Jan 01 12:00:00 2000 +0000
  summary:     add a
  
  $ hg collapse -n -t 0 -r 1
  abort: -t or --timedelta only valid with --auto
  [255]
  $ hg collapse -n --timedelta=0 -r 1
  abort: -t or --timedelta only valid with --auto
  [255]

  $ hg collapse -n --debug -a --usefirst --timedelta=100.0
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  timedelta parent 0 current 1 is 900.0 (max 100.0) -> stop
  find_chunk(2, set([1])) children [3] parents [1]
  timedelta parent 1 current 2 is 300.0 (max 100.0) -> stop
  find_chunk(3, set([2])) children [4] parents [2]
  timedelta parent 2 current 3 is 85200.0 (max 100.0) -> stop
  find_chunk(4, set([3])) children [5] parents [3]
  timedelta parent 3 current 4 is 3600.0 (max 100.0) -> stop
  find_chunk(5, set([4])) children [6] parents [4]
  timedelta parent 4 current 5 is 3600.0 (max 100.0) -> stop
  find_chunk(6, set([5])) children [] parents [5]
  timedelta parent 5 current 6 is 79200.0 (max 100.0) -> stop
  abort: no revision chunk found
  
  [255]
  $ hg collapse -n --debug -a --usefirst --timedelta=900
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4] parents [2]
  timedelta parent 2 current 3 is 85200.0 (max 900.0) -> stop
  Collapsing revisions set([0, 1, 2])
  get_hgtags_from_heads: rev: 2 heads: [6]
  will move revisions: [3, 4, 5, 6]
  noop: not collapsing
  $ hg collapse -n --debug -a --usefirst --timedelta=899
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  timedelta parent 0 current 1 is 900.0 (max 899.0) -> stop
  find_chunk(2, set([1])) children [3] parents [1]
  find_chunk(3, set([1, 2])) children [4] parents [2]
  timedelta parent 2 current 3 is 85200.0 (max 899.0) -> stop
  Collapsing revisions set([1, 2])
  get_hgtags_from_heads: rev: 2 heads: [6]
  will move revisions: [3, 4, 5, 6]
  noop: not collapsing
  $ hg collapse --auto --usefirst --timedelta=900
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   4:7276beb2c066
  tag:         tip
  user:        test
  date:        Mon Jan 03 12:00:00 2000 +0000
  summary:     add g
  
  changeset:   3:15dea3ef0bc1
  user:        test
  date:        Sun Jan 02 14:00:00 2000 +0000
  summary:     add f
  
  changeset:   2:f5963c9a1077
  user:        test
  date:        Sun Jan 02 13:00:00 2000 +0000
  summary:     add e
  
  changeset:   1:42cfb446918d
  user:        test
  date:        Sun Jan 02 12:00:00 2000 +0000
  summary:     add d
  
  changeset:   0:512d475cd6d2
  user:        test
  date:        Sat Jan 01 12:20:00 2000 +0000
  summary:     add a
  
  $ hg collapse --auto --usefirst --timedelta=900
  abort: no revision chunk found
  
  [255]
