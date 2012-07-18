  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
  > collapse = $base/hgext/collapse.py
  > [merge-tools]
  > mergetags.premerge = False
  > mergetags.executable = cat
  > mergetags.args = \$local \$other  | sort -u >> \$output
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
  $ hg tag tag1
  $ mkcommit g
  $ hg update -r 3
  0 files updated, 0 files merged, 4 files removed, 0 files unresolved
  $ mkcommit n
  created new head
  $ mkcommit m
  $ hg tag tag2
  $ hg clone . ../beta
  updating to branch default
  7 files updated, 0 files merged, 0 files removed, 0 files unresolved
XXX: have to set --tool because HGMERGE is set by run-tests.py persistently  
  $ hg merge --tool=mergetags
  merging .hgtags
  3 files updated, 1 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)

  $ hg commit -m 'merge'
  $ mkcommit x
  $ mkcommit y
  $ mkcommit z
  $ hg clone . ../gamma
  updating to branch default
  13 files updated, 0 files merged, 0 files removed, 0 files unresolved

  $ hg log -v --graph
  @  changeset:   14:0dffbb0c84cc
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       z
  |  description:
  |  add z
  |
  |
  o  changeset:   13:1c1b49d83c1f
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       y
  |  description:
  |  add y
  |
  |
  o  changeset:   12:8d4a23778eda
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       x
  |  description:
  |  add x
  |
  |
  o    changeset:   11:d0aaebeba932
  |\   parent:      10:bb59bbea0c62
  | |  parent:      7:d375e7452b25
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  merge
  | |
  | |
  | o  changeset:   10:bb59bbea0c62
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  Added tag tag2 for changeset 38e2cd0cf7cb
  | |
  | |
  | o  changeset:   9:38e2cd0cf7cb
  | |  tag:         tag2
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       m
  | |  description:
  | |  add m
  | |
  | |
  | o  changeset:   8:23840cbaa7b3
  | |  parent:      3:47d2a3944de8
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       n
  | |  description:
  | |  add n
  | |
  | |
  o |  changeset:   7:d375e7452b25
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       g
  | |  description:
  | |  add g
  | |
  | |
  o |  changeset:   6:b8b14504a017
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  Added tag tag1 for changeset bbc3e4679176
  | |
  | |
  o |  changeset:   5:bbc3e4679176
  | |  tag:         tag1
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       f
  | |  description:
  | |  add f
  | |
  | |
  o |  changeset:   4:9d206ffc875e
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    files:       e
  |    description:
  |    add e
  |
  |
  o  changeset:   3:47d2a3944de8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       d
  |  description:
  |  add d
  |
  |
  o  changeset:   2:4538525df7e2
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       c
  |  description:
  |  add c
  |
  |
  o  changeset:   1:7c3bad9141dc
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       b
  |  description:
  |  add b
  |
  |
  o  changeset:   0:1f0dee641bb7
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     files:       a
     description:
     add a
  
  

  $ hg collapse -r 12:14
  adding x
  adding y
  adding z
  collapse completed

  $ hg log -v --graph
  @  changeset:   12:722abc0fc120
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       x y z
  |  description:
  |  add x
  |  ----------------
  |  add y
  |  ----------------
  |  add z
  |
  |
  o    changeset:   11:d0aaebeba932
  |\   parent:      10:bb59bbea0c62
  | |  parent:      7:d375e7452b25
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  merge
  | |
  | |
  | o  changeset:   10:bb59bbea0c62
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  Added tag tag2 for changeset 38e2cd0cf7cb
  | |
  | |
  | o  changeset:   9:38e2cd0cf7cb
  | |  tag:         tag2
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       m
  | |  description:
  | |  add m
  | |
  | |
  | o  changeset:   8:23840cbaa7b3
  | |  parent:      3:47d2a3944de8
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       n
  | |  description:
  | |  add n
  | |
  | |
  o |  changeset:   7:d375e7452b25
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       g
  | |  description:
  | |  add g
  | |
  | |
  o |  changeset:   6:b8b14504a017
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       .hgtags
  | |  description:
  | |  Added tag tag1 for changeset bbc3e4679176
  | |
  | |
  o |  changeset:   5:bbc3e4679176
  | |  tag:         tag1
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       f
  | |  description:
  | |  add f
  | |
  | |
  o |  changeset:   4:9d206ffc875e
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    files:       e
  |    description:
  |    add e
  |
  |
  o  changeset:   3:47d2a3944de8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       d
  |  description:
  |  add d
  |
  |
  o  changeset:   2:4538525df7e2
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       c
  |  description:
  |  add c
  |
  |
  o  changeset:   1:7c3bad9141dc
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       b
  |  description:
  |  add b
  |
  |
  o  changeset:   0:1f0dee641bb7
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
  adding .hgtags
  adding g
  forgetting .hgtags
  removing e
  removing f
  removing g
  adding n
  adding m
  adding .hgtags
  adding e
  adding f
  adding g
  reverting .hgtags
  adding x
  adding y
  adding z
  collapse completed
  $ hg log -v --graph
  @  changeset:   10:* (glob)
  |  tag:         tip
  |  user:        test
  |  date:        * (glob)
  |  files:       .hgtags
  |  description:
  |  collapse tag fix
  |
  |
  o  changeset:   9:38bf9ad51d4b
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       x y z
  |  description:
  |  add x
  |  ----------------
  |  add y
  |  ----------------
  |  add z
  |
  |
  o    changeset:   8:2ff052a0abeb
  |\   parent:      7:efbbca0bce13
  | |  parent:      5:e6ad8fb7fc20
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  description:
  | |  merge
  | |
  | |
  | o  changeset:   7:efbbca0bce13
  | |  tag:         tag2
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       m
  | |  description:
  | |  add m
  | |
  | |
  | o  changeset:   6:ebd4831f69f0
  | |  parent:      2:e61e73fea077
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       n
  | |  description:
  | |  add n
  | |
  | |
  o |  changeset:   5:e6ad8fb7fc20
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       g
  | |  description:
  | |  add g
  | |
  | |
  o |  changeset:   4:c38fbfb0379f
  | |  tag:         tag1
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       f
  | |  description:
  | |  add f
  | |
  | |
  o |  changeset:   3:a4c3db04ba4f
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    files:       e
  |    description:
  |    add e
  |
  |
  o  changeset:   2:e61e73fea077
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       d
  |  description:
  |  add d
  |
  |
  o  changeset:   1:38e114dd4cc8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       c
  |  description:
  |  add c
  |
  |
  o  changeset:   0:baa8680ec83d
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     files:       a b
     description:
     add a
     ----------------
     add b
  
  

  $ hg collapse -r 6:7
  adding m
  adding n
  adding e
  adding f
  adding g
  adding x
  adding y
  adding z
  collapse completed
  $ hg log -v --graph
  @  changeset:   9:* (glob)
  |  tag:         tip
  |  user:        test
  |  date:        * (glob)
  |  files:       .hgtags
  |  description:
  |  collapse tag fix
  |
  |
  o  changeset:   8:0abcb8d2b34c
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       x y z
  |  description:
  |  add x
  |  ----------------
  |  add y
  |  ----------------
  |  add z
  |
  |
  o    changeset:   7:ab5c03457c2c
  |\   parent:      6:4204d0be6108
  | |  parent:      5:e6ad8fb7fc20
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  description:
  | |  merge
  | |
  | |
  | o  changeset:   6:4204d0be6108
  | |  tag:         tag2
  | |  parent:      2:e61e73fea077
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       m n
  | |  description:
  | |  add n
  | |  ----------------
  | |  add m
  | |
  | |
  o |  changeset:   5:e6ad8fb7fc20
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       g
  | |  description:
  | |  add g
  | |
  | |
  o |  changeset:   4:c38fbfb0379f
  | |  tag:         tag1
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       f
  | |  description:
  | |  add f
  | |
  | |
  o |  changeset:   3:a4c3db04ba4f
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    files:       e
  |    description:
  |    add e
  |
  |
  o  changeset:   2:e61e73fea077
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       d
  |  description:
  |  add d
  |
  |
  o  changeset:   1:38e114dd4cc8
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  files:       c
  |  description:
  |  add c
  |
  |
  o  changeset:   0:baa8680ec83d
     user:        test
     date:        Thu Jan 01 00:00:00 1970 +0000
     files:       a b
     description:
     add a
     ----------------
     add b
  
  
  $ cd ../beta
  $ hg collapse -r 0:3
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding .hgtags
  adding g
  forgetting .hgtags
  removing e
  removing f
  removing g
  adding n
  adding m
  collapse completed
  $ hg log -v --graph -v
  @  changeset:   7:* (glob)
  |  tag:         tip
  |  parent:      3:eabc86a84f9d
  |  user:        test
  |  date:        * (glob)
  |  files:       .hgtags
  |  description:
  |  collapse tag fix
  |
  |
  | o  changeset:   6:* (glob)
  | |  user:        test
  | |  date:        * (glob)
  | |  files:       .hgtags
  | |  description:
  | |  collapse tag fix
  | |
  | |
  | o  changeset:   5:19da2917114f
  | |  tag:         tag2
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       m
  | |  description:
  | |  add m
  | |
  | |
  | o  changeset:   4:f0500128d072
  | |  parent:      0:ff6fe4183e85
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       n
  | |  description:
  | |  add n
  | |
  | |
  o |  changeset:   3:eabc86a84f9d
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       g
  | |  description:
  | |  add g
  | |
  | |
  o |  changeset:   2:4b8f9de26843
  | |  tag:         tag1
  | |  user:        test
  | |  date:        Thu Jan 01 00:00:00 1970 +0000
  | |  files:       f
  | |  description:
  | |  add f
  | |
  | |
  o |  changeset:   1:04e9e84ae13f
  |/   user:        test
  |    date:        Thu Jan 01 00:00:00 1970 +0000
  |    files:       e
  |    description:
  |    add e
  |
  |
  o  changeset:   0:ff6fe4183e85
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
  
  
  $ hg cat -r 6 .hgtags
  19da2917114f5b9089c1a3d600e74d7654b17e5e tag2
  $ hg cat -r 7 .hgtags
  4b8f9de2684322e10ef0e261fc6d747134ce4460 tag1

