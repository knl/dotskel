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

  $ hg log -v
  changeset:   9:6f44456eadca
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   8:a64a9f61adf5
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   7:4bed095917ba
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  change d
  
  
  changeset:   6:6f890aafa926
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   5:00b9f31adff9
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       b
  description:
  change b
  
  
  changeset:   4:d8d5f7ec46e8
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   3:47d2a3944de8
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
  
  
  $ hg collapse -a --changelog -F 
  reverting a
  reverting b
  reverting d
  adding e
  reverting a
  reverting a
  collapse completed
  $ hg log -v
  changeset:   6:4118b7593b99
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   5:df1954d2ad04
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   4:265b2a1f9312
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b d e
  description:
  * a:
  change a
  
  * b:
  change b
  
  * e:
  add e
  
  * d:
  change d
  
  
  changeset:   3:47d2a3944de8
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
  
  
  $ hg collapse -a --changelog -F 
  adding a
  adding b
  adding c
  adding d
  reverting a
  reverting b
  reverting d
  adding e
  reverting a
  reverting a
  collapse completed
  $ hg log -v
  changeset:   3:b720f41e21d4
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   2:5cb35218f5f1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a
  description:
  change a
  
  
  changeset:   1:4a11f90699ce
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b d e
  description:
  * a:
  change a
  
  * b:
  change b
  
  * e:
  add e
  
  * d:
  change d
  
  
  changeset:   0:8a1c2c24503e
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b c d
  description:
  * a:
  add a
  
  * b:
  add b
  
  * c:
  add c
  
  * d:
  add d
  
  
  $ hg collapse -a --changelog -F 
  abort: no revision chunk found
  
  [255]

