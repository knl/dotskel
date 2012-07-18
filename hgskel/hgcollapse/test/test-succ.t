  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
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
  $ hg log
  changeset:   6:9f1a23278c2c
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   5:bbc3e4679176
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   4:9d206ffc875e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
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
  
  $ hg collapse -r 0:2
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   4:31e4f914c34b
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   3:84ad05ac1472
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   2:21b17d015e83
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   1:450c6b799683
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   0:09fc2cc7c4fd
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -r 1:3
  adding d
  adding e
  adding f
  adding g
  collapse completed

  $ hg log
  changeset:   2:df71a49010a1
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   1:f1934a93cfb3
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   0:09fc2cc7c4fd
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -r 0:2
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   0:58834c40a462
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
