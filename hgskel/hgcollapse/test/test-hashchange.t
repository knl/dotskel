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

  $ hg log --graph
  @  changeset:   12:68b2e29a0930
  |  tag:         tip
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add z
  |
  o  changeset:   11:f912b9969b5c
  |  user:        test
  |  date:        Thu Jan 01 00:00:00 1970 +0000
  |  summary:     add y
  |
  o  changeset:   10:d01f31debc24
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
  
  $ hg collapse --debugdelay 2.5 --debug -r 0:3
  Collapsing revisions set([0, 1, 2, 3])
  get_hgtags_from_heads: rev: 3 heads: [12]
  will move revisions: [4, 5, 6, 7, 8, 9, 10, 11, 12]
  updating to revision -1
  resolving manifests
   overwrite False partial False
   ancestor 68b2e29a0930 local 68b2e29a0930+ remote 000000000000
   a: other deleted -> r
   c: other deleted -> r
   b: other deleted -> r
   e: other deleted -> r
   d: other deleted -> r
   g: other deleted -> r
   f: other deleted -> r
   m: other deleted -> r
   n: other deleted -> r
   y: other deleted -> r
   x: other deleted -> r
   z: other deleted -> r
  updating: a 1/12 files (8.33%)
  removing a
  updating: b 2/12 files (16.67%)
  removing b
  updating: c 3/12 files (25.00%)
  removing c
  updating: d 4/12 files (33.33%)
  removing d
  updating: e 5/12 files (41.67%)
  removing e
  updating: f 6/12 files (50.00%)
  removing f
  updating: g 7/12 files (58.33%)
  removing g
  updating: m 8/12 files (66.67%)
  removing m
  updating: n 9/12 files (75.00%)
  removing n
  updating: x 10/12 files (83.33%)
  removing x
  updating: y 11/12 files (91.67%)
  removing y
  updating: z 12/12 files (100.00%)
  removing z
  reverting to revision 3
  reverting to revision 3
  adding a
  adding b
  adding c
  adding d
  a
  b
  c
  d
  makecollapsed 1f0dee641bb7258c56bd60e93edfa2405381c41e -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  makecollapsed 7c3bad9141dcb46ff89abf5f61856facd56e476c -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  makecollapsed 4538525df7e2b9f09423636c61ef63a4cb872a2d -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  makecollapsed 47d2a3944de8b013de3be9578e8e344ea2e6c097 -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  moving revision 4
  sleep debug_delay: 2.5
  setting parent to 13
  reverting to revision 4
  reverting to revision 4
  adding e
  a
  b
  c
  d
  e
  movedescendants 9d206ffc875e1bc304590549be293be36821e66c -> 04e9e84ae13f5fd4ccae69367bfaa16f9872204f
  moving revision 5
  sleep debug_delay: 2.5
  setting parent to 14
  reverting to revision 5
  reverting to revision 5
  adding f
  a
  b
  c
  d
  e
  f
  movedescendants bbc3e467917630e7d77cd77298e1027030972893 -> 4b8f9de2684322e10ef0e261fc6d747134ce4460
  moving revision 6
  sleep debug_delay: 2.5
  setting parent to 15
  reverting to revision 6
  reverting to revision 6
  adding g
  a
  b
  c
  d
  e
  f
  g
  movedescendants 9f1a23278c2c9e0932c2989b39fae1b8cc81adb0 -> eabc86a84f9d6db3986187a14fc7f69b0e635371
  moving revision 7
  sleep debug_delay: 2.5
  setting parent to 13
  reverting to revision 7
  reverting to revision 7
  removing e
  removing f
  saving current version of g as g.orig
  removing g
  adding n
  a
  b
  c
  d
  n
  movedescendants 23840cbaa7b3227b407d0ba79d359bca4ecab988 -> f0500128d072341c61ed28b3e2146596093c2fc7
  moving revision 8
  sleep debug_delay: 2.5
  setting parent to 17
  reverting to revision 8
  reverting to revision 8
  adding m
  a
  b
  c
  d
  m
  n
  movedescendants 38e2cd0cf7cbd5ae5f00b31a27d3d6648b38173b -> 19da2917114f5b9089c1a3d600e74d7654b17e5e
  moving revision 9
  sleep debug_delay: 2.5
  setting parents to 18 and 16
  reverting to revision 9
  reverting to revision 9
  adding e
  adding f
  adding g
  a
  b
  c
  d
  e
  f
  g
  m
  n
  movedescendants b17788d8ea7fe484608ffebfa9b5416994acc00d -> 0bd87ea899fac192233f9acc82f409c96ea0fe41
  moving revision 10
  sleep debug_delay: 2.5
  setting parent to 19
  reverting to revision 10
  reverting to revision 10
  adding x
  a
  b
  c
  d
  e
  f
  g
  m
  n
  x
  movedescendants d01f31debc242572a0fbd29a81f3005e1d52be88 -> fc8629a03d73cd6689df2879ecf4c4febc451c21
  moving revision 11
  sleep debug_delay: 2.5
  setting parent to 20
  reverting to revision 11
  reverting to revision 11
  adding y
  a
  b
  c
  d
  e
  f
  g
  m
  n
  x
  y
  movedescendants f912b9969b5cf0608873e45c44a4f2604eeaec41 -> 3bded8e79801b17ca2fe61f52c9a2a80530377cc
  moving revision 12
  sleep debug_delay: 2.5
  setting parent to 21
  reverting to revision 12
  reverting to revision 12
  adding z
  a
  b
  c
  d
  e
  f
  g
  m
  n
  x
  y
  z
  movedescendants 68b2e29a0930ba0798307d26e4a02894793df291 -> 7df01aea57237f50bff5e24051ad025599d3c565
  fix_hgtags: tagsmap bbc3e467917630e7d77cd77298e1027030972893 -> 4b8f9de2684322e10ef0e261fc6d747134ce4460
  fix_hgtags: tagsmap b17788d8ea7fe484608ffebfa9b5416994acc00d -> 0bd87ea899fac192233f9acc82f409c96ea0fe41
  fix_hgtags: tagsmap f912b9969b5cf0608873e45c44a4f2604eeaec41 -> 3bded8e79801b17ca2fe61f52c9a2a80530377cc
  fix_hgtags: tagsmap 38e2cd0cf7cbd5ae5f00b31a27d3d6648b38173b -> 19da2917114f5b9089c1a3d600e74d7654b17e5e
  fix_hgtags: tagsmap 68b2e29a0930ba0798307d26e4a02894793df291 -> 7df01aea57237f50bff5e24051ad025599d3c565
  fix_hgtags: tagsmap 7c3bad9141dcb46ff89abf5f61856facd56e476c -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  fix_hgtags: tagsmap 4538525df7e2b9f09423636c61ef63a4cb872a2d -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  fix_hgtags: tagsmap 9f1a23278c2c9e0932c2989b39fae1b8cc81adb0 -> eabc86a84f9d6db3986187a14fc7f69b0e635371
  fix_hgtags: tagsmap d01f31debc242572a0fbd29a81f3005e1d52be88 -> fc8629a03d73cd6689df2879ecf4c4febc451c21
  fix_hgtags: tagsmap 47d2a3944de8b013de3be9578e8e344ea2e6c097 -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  fix_hgtags: tagsmap 1f0dee641bb7258c56bd60e93edfa2405381c41e -> ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  fix_hgtags: tagsmap 23840cbaa7b3227b407d0ba79d359bca4ecab988 -> f0500128d072341c61ed28b3e2146596093c2fc7
  fix_hgtags: tagsmap 9d206ffc875e1bc304590549be293be36821e66c -> 04e9e84ae13f5fd4ccae69367bfaa16f9872204f
  stripping revision 0
  10 changesets found
  list of changesets:
  ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  04e9e84ae13f5fd4ccae69367bfaa16f9872204f
  4b8f9de2684322e10ef0e261fc6d747134ce4460
  eabc86a84f9d6db3986187a14fc7f69b0e635371
  f0500128d072341c61ed28b3e2146596093c2fc7
  19da2917114f5b9089c1a3d600e74d7654b17e5e
  0bd87ea899fac192233f9acc82f409c96ea0fe41
  fc8629a03d73cd6689df2879ecf4c4febc451c21
  3bded8e79801b17ca2fe61f52c9a2a80530377cc
  7df01aea57237f50bff5e24051ad025599d3c565
  bundling: 1/10 changesets (10.00%)
  bundling: 2/10 changesets (20.00%)
  bundling: 3/10 changesets (30.00%)
  bundling: 4/10 changesets (40.00%)
  bundling: 5/10 changesets (50.00%)
  bundling: 6/10 changesets (60.00%)
  bundling: 7/10 changesets (70.00%)
  bundling: 8/10 changesets (80.00%)
  bundling: 9/10 changesets (90.00%)
  bundling: 10/10 changesets (100.00%)
  bundling: 1/10 manifests (10.00%)
  bundling: 2/10 manifests (20.00%)
  bundling: 3/10 manifests (30.00%)
  bundling: 4/10 manifests (40.00%)
  bundling: 5/10 manifests (50.00%)
  bundling: 6/10 manifests (60.00%)
  bundling: 7/10 manifests (70.00%)
  bundling: 8/10 manifests (80.00%)
  bundling: 9/10 manifests (90.00%)
  bundling: 10/10 manifests (100.00%)
  bundling: a 1/12 files (8.33%)
  bundling: b 2/12 files (16.67%)
  bundling: c 3/12 files (25.00%)
  bundling: d 4/12 files (33.33%)
  bundling: e 5/12 files (41.67%)
  bundling: f 6/12 files (50.00%)
  bundling: g 7/12 files (58.33%)
  bundling: m 8/12 files (66.67%)
  bundling: n 9/12 files (75.00%)
  bundling: x 10/12 files (83.33%)
  bundling: y 11/12 files (91.67%)
  bundling: z 12/12 files (100.00%)
  adding branch
  adding changesets
  changesets: 1 chunks
  add changeset ff6fe4183e85
  changesets: 2 chunks
  add changeset 04e9e84ae13f
  changesets: 3 chunks
  add changeset 4b8f9de26843
  changesets: 4 chunks
  add changeset eabc86a84f9d
  changesets: 5 chunks
  add changeset f0500128d072
  changesets: 6 chunks
  add changeset 19da2917114f
  changesets: 7 chunks
  add changeset 0bd87ea899fa
  changesets: 8 chunks
  add changeset fc8629a03d73
  changesets: 9 chunks
  add changeset 3bded8e79801
  changesets: 10 chunks
  add changeset 7df01aea5723
  adding manifests
  manifests: 1/10 chunks (10.00%)
  manifests: 2/10 chunks (20.00%)
  manifests: 3/10 chunks (30.00%)
  manifests: 4/10 chunks (40.00%)
  manifests: 5/10 chunks (50.00%)
  manifests: 6/10 chunks (60.00%)
  manifests: 7/10 chunks (70.00%)
  manifests: 8/10 chunks (80.00%)
  manifests: 9/10 chunks (90.00%)
  manifests: 10/10 chunks (100.00%)
  adding file changes
  adding a revisions
  files: 1/12 chunks (8.33%)
  adding b revisions
  files: 2/12 chunks (16.67%)
  adding c revisions
  files: 3/12 chunks (25.00%)
  adding d revisions
  files: 4/12 chunks (33.33%)
  adding e revisions
  files: 5/12 chunks (41.67%)
  adding f revisions
  files: 6/12 chunks (50.00%)
  adding g revisions
  files: 7/12 chunks (58.33%)
  adding m revisions
  files: 8/12 chunks (66.67%)
  adding n revisions
  files: 9/12 chunks (75.00%)
  adding x revisions
  files: 10/12 chunks (83.33%)
  adding y revisions
  files: 11/12 chunks (91.67%)
  adding z revisions
  files: 12/12 chunks (100.00%)
  added 10 changesets with 12 changes to 12 files
  updating the branch cache
  invalidating branch cache (tip differs)
  collapse completed
  $ hg log --debug
  changeset:   9:7df01aea57237f50bff5e24051ad025599d3c565
  tag:         tip
  parent:      8:3bded8e79801b17ca2fe61f52c9a2a80530377cc
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    9:3d09f79365b09c88680f66bc1040782e3a2f72b4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      z
  extra:       branch=default
  description:
  add z
  
  
  changeset:   8:3bded8e79801b17ca2fe61f52c9a2a80530377cc
  parent:      7:fc8629a03d73cd6689df2879ecf4c4febc451c21
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    8:3779946e495c9602aa7415d7cbbfd9b83d2cea69
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      y
  extra:       branch=default
  description:
  add y
  
  
  changeset:   7:fc8629a03d73cd6689df2879ecf4c4febc451c21
  parent:      6:0bd87ea899fac192233f9acc82f409c96ea0fe41
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    7:d6a8a49d0c6fb5c296869b9c6ea5abafa42a3e15
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      x
  extra:       branch=default
  description:
  add x
  
  
  changeset:   6:0bd87ea899fac192233f9acc82f409c96ea0fe41
  parent:      5:19da2917114f5b9089c1a3d600e74d7654b17e5e
  parent:      3:eabc86a84f9d6db3986187a14fc7f69b0e635371
  manifest:    6:94fbbcd85b88c6e3934e2593b201a72556f08a1f
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      e f g
  extra:       branch=default
  description:
  merge
  
  
  changeset:   5:19da2917114f5b9089c1a3d600e74d7654b17e5e
  parent:      4:f0500128d072341c61ed28b3e2146596093c2fc7
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    5:0e8202d6b3f9844b894cfd2c557901fb359fe671
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      m
  extra:       branch=default
  description:
  add m
  
  
  changeset:   4:f0500128d072341c61ed28b3e2146596093c2fc7
  parent:      0:ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    4:1fa5b2b42672f01656e9dd7573526d3b4c11ced1
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      n
  extra:       branch=default
  description:
  add n
  
  
  changeset:   3:eabc86a84f9d6db3986187a14fc7f69b0e635371
  parent:      2:4b8f9de2684322e10ef0e261fc6d747134ce4460
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    3:ed5c4f83e1974286b70b89ba9d8c65e4eac7fb41
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      g
  extra:       branch=default
  description:
  add g
  
  
  changeset:   2:4b8f9de2684322e10ef0e261fc6d747134ce4460
  parent:      1:04e9e84ae13f5fd4ccae69367bfaa16f9872204f
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    2:488092b4bec54565c630cdf953d5945e1a4993a0
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      f
  extra:       branch=default
  description:
  add f
  
  
  changeset:   1:04e9e84ae13f5fd4ccae69367bfaa16f9872204f
  parent:      0:ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    1:251ee6379d69fc281a21ff9890c4d4cb46c30336
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      e
  extra:       branch=default
  description:
  add e
  
  
  changeset:   0:ff6fe4183e85f99f599ee7502f5cbf60bd4d254f
  parent:      -1:0000000000000000000000000000000000000000
  parent:      -1:0000000000000000000000000000000000000000
  manifest:    0:9c601042bb6720fc7b4364539cae4716791e5fda
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files+:      a b c d
  extra:       branch=default
  description:
  add a
  ----------------
  add b
  ----------------
  add c
  ----------------
  add d
  
  
