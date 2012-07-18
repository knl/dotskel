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

  $ hg collapse -a --usefirst -C -F 
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
  $ hg collapse -a --usefirst --changelog -F 
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
  
  
  $ hg collapse --repeat -a --usefirst --changelog -F 
  abort: no revision chunk found
  
  [255]


