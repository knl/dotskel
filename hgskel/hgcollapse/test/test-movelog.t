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
  
  $ hg collapse -L ../move.log -r0:2
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
  
  $ cat ../move.log
  coll 1f0dee641bb7258c56bd60e93edfa2405381c41e -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 7c3bad9141dcb46ff89abf5f61856facd56e476c -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 4538525df7e2b9f09423636c61ef63a4cb872a2d -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  move 47d2a3944de8b013de3be9578e8e344ea2e6c097 -> 450c6b7996838f5041269864664689d04be137eb
  move 9d206ffc875e1bc304590549be293be36821e66c -> 21b17d015e83a0c8f8259a6107d23f807505b916
  move bbc3e467917630e7d77cd77298e1027030972893 -> 84ad05ac1472fd4c039b9917f20b63bd3cdcaabf
  move 9f1a23278c2c9e0932c2989b39fae1b8cc81adb0 -> 31e4f914c34bebbf41d18d6e2ded1d4581003fcc

  $ hg collapse -L ../move.log -r0:2
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   2:30b49bc8539a
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   1:232bd782efa4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   0:199fee38029f
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ cat ../move.log
  coll 1f0dee641bb7258c56bd60e93edfa2405381c41e -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 7c3bad9141dcb46ff89abf5f61856facd56e476c -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 4538525df7e2b9f09423636c61ef63a4cb872a2d -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  move 47d2a3944de8b013de3be9578e8e344ea2e6c097 -> 450c6b7996838f5041269864664689d04be137eb
  move 9d206ffc875e1bc304590549be293be36821e66c -> 21b17d015e83a0c8f8259a6107d23f807505b916
  move bbc3e467917630e7d77cd77298e1027030972893 -> 84ad05ac1472fd4c039b9917f20b63bd3cdcaabf
  move 9f1a23278c2c9e0932c2989b39fae1b8cc81adb0 -> 31e4f914c34bebbf41d18d6e2ded1d4581003fcc
  coll 09fc2cc7c4fda512bcd03cceea623e5f1e56014e -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  coll 450c6b7996838f5041269864664689d04be137eb -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  coll 21b17d015e83a0c8f8259a6107d23f807505b916 -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  move 84ad05ac1472fd4c039b9917f20b63bd3cdcaabf -> 232bd782efa4c12ab2d92ceeedca8c2a97f2c1f6
  move 31e4f914c34bebbf41d18d6e2ded1d4581003fcc -> 30b49bc8539af1d94272e8f298e90b48db06f9cb

  $ hg collapse -L ../move.log -r0:2
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
  
  $ cat ../move.log
  coll 1f0dee641bb7258c56bd60e93edfa2405381c41e -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 7c3bad9141dcb46ff89abf5f61856facd56e476c -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  coll 4538525df7e2b9f09423636c61ef63a4cb872a2d -> 09fc2cc7c4fda512bcd03cceea623e5f1e56014e
  move 47d2a3944de8b013de3be9578e8e344ea2e6c097 -> 450c6b7996838f5041269864664689d04be137eb
  move 9d206ffc875e1bc304590549be293be36821e66c -> 21b17d015e83a0c8f8259a6107d23f807505b916
  move bbc3e467917630e7d77cd77298e1027030972893 -> 84ad05ac1472fd4c039b9917f20b63bd3cdcaabf
  move 9f1a23278c2c9e0932c2989b39fae1b8cc81adb0 -> 31e4f914c34bebbf41d18d6e2ded1d4581003fcc
  coll 09fc2cc7c4fda512bcd03cceea623e5f1e56014e -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  coll 450c6b7996838f5041269864664689d04be137eb -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  coll 21b17d015e83a0c8f8259a6107d23f807505b916 -> 199fee38029fce24fefc2fa9b124a8b1ab9a00d3
  move 84ad05ac1472fd4c039b9917f20b63bd3cdcaabf -> 232bd782efa4c12ab2d92ceeedca8c2a97f2c1f6
  move 31e4f914c34bebbf41d18d6e2ded1d4581003fcc -> 30b49bc8539af1d94272e8f298e90b48db06f9cb
  coll 199fee38029fce24fefc2fa9b124a8b1ab9a00d3 -> 58834c40a462497611ea7fb99d093192874d0c98
  coll 232bd782efa4c12ab2d92ceeedca8c2a97f2c1f6 -> 58834c40a462497611ea7fb99d093192874d0c98
  coll 30b49bc8539af1d94272e8f298e90b48db06f9cb -> 58834c40a462497611ea7fb99d093192874d0c98
