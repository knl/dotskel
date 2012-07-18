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
  $ hg branch branchname
  marked working directory as branch branchname
  $ hg ci -m "only branch"
  $ mkcommit d
  $ mkcommit e
  $ mkcommit f
  $ mkcommit g
  $ cd ..
  $ hg clone alpha beta
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone alpha gamma
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd alpha
  $ hg log -v  
  changeset:   7:b1f58df41a4e
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   6:ad15c7e2a7b8
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   5:c05bc9e22eb0
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   4:37687bae9cfe
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   3:08ebc638fac2
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  only branch
  
  
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
  
  
  $ hg collapse -r 5:7
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v  
  changeset:   5:ec284105363f
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e f g
  description:
  add e
  ----------------
  add f
  ----------------
  add g
  
  
  changeset:   4:37687bae9cfe
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   3:08ebc638fac2
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  only branch
  
  
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
  
  

  $ cd ../beta
  $ hg log -v  
  changeset:   7:b1f58df41a4e
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   6:ad15c7e2a7b8
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   5:c05bc9e22eb0
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   4:37687bae9cfe
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   3:08ebc638fac2
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  only branch
  
  
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
  
  
  $ hg collapse -r 0:1
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v
  changeset:   6:97f50210ab7a
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   5:1a7d6b112c85
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   4:bae836cd0666
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   3:955eb46581b4
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   2:307e515d99e5
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  only branch
  
  
  changeset:   1:38e114dd4cc8
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c
  description:
  add c
  
  
  changeset:   0:baa8680ec83d
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       a b
  description:
  add a
  ----------------
  add b
  
  $ cd ../gamma
  $ hg log -v  
  changeset:   7:b1f58df41a4e
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   6:ad15c7e2a7b8
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   5:c05bc9e22eb0
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   4:37687bae9cfe
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       d
  description:
  add d
  
  
  changeset:   3:08ebc638fac2
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  description:
  only branch
  
  
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
  
  
  $ hg collapse -r 2:4  
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log -v  
  changeset:   5:05ffc03cb9df
  branch:      branchname
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       g
  description:
  add g
  
  
  changeset:   4:a161cbaff3c1
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       f
  description:
  add f
  
  
  changeset:   3:a2c5e5ffa59e
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       e
  description:
  add e
  
  
  changeset:   2:97ea1683b5a8
  branch:      branchname
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       c d
  description:
  add c
  ----------------
  only branch
  ----------------
  add d
  
  
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
  
  

