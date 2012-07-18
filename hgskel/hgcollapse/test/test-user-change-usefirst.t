  $ base=`dirname $TESTDIR`

  $ cat >> $HGRCPATH <<EOF
  > [extensions]
  > graphlog =
  > collapse = $base/hgext/collapse.py
  > EOF

  $ mkcommit() {
  >    echo "$1" > "$1"
  >    hg add "$1"
  >    hg ci -u "$2" -m "add $1"
  > }

  $ hg init alpha
  $ cd alpha
  $ mkcommit a arthur
  $ mkcommit b arthur
  $ mkcommit c arthur
  $ mkcommit d galahad
  $ mkcommit e galahad
  $ mkcommit f robin
  $ mkcommit g robin

  $ hg log
  changeset:   6:e56ff39b02bb
  tag:         tip
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   5:81ae0b2f98ee
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   4:507ca28dd3b3
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   3:329ed92a7260
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   2:3dba5b07b5ac
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add c
  
  changeset:   1:0e9edcdd4148
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add b
  
  changeset:   0:5639cbe6bee6
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -n -a --usefirst -u -f --debug
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  find_chunk(2, set([0, 1])) children [3] parents [1]
  find_chunk(3, set([0, 1, 2])) children [4] parents [2]
  userchange parent 2 user arthur current 3 user galahad, -> stop
  Collapsing revisions set([0, 1, 2])
  get_hgtags_from_heads: rev: 2 heads: [6]
  will move revisions: [3, 4, 5, 6]
  noop: not collapsing

  $ hg collapse -a --usefirst -u -f 
  adding a
  adding b
  adding c
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   4:4a4a6fb80d71
  tag:         tip
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add g
  
  changeset:   3:0ae784701ba7
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   2:817b7273599c
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add e
  
  changeset:   1:f852c1319b23
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   0:6a6bb04d53bf
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -n --debug -a --usefirst -u -f 
  find_chunk(0, set([])) children [1] parents [-1]
  find_chunk(1, set([0])) children [2] parents [0]
  userchange parent 0 user arthur current 1 user galahad, -> stop
  find_chunk(2, set([1])) children [3] parents [1]
  find_chunk(3, set([1, 2])) children [4] parents [2]
  userchange parent 2 user galahad current 3 user robin, -> stop
  Collapsing revisions set([1, 2])
  get_hgtags_from_heads: rev: 2 heads: [4]
  will move revisions: [3, 4]
  noop: not collapsing
  $ hg collapse -a --usefirst -u -f 
  adding d
  adding e
  adding f
  adding g
  collapse completed
  $ hg collapse -a --usefirst -u -f 
  adding f
  adding g
  collapse completed
  $ hg log
  changeset:   2:285565e26e94
  tag:         tip
  user:        robin
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add f
  
  changeset:   1:e4bb575d1758
  user:        galahad
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add d
  
  changeset:   0:6a6bb04d53bf
  user:        arthur
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     add a
  
  $ hg collapse -a --usefirst -u -f 
  abort: no revision chunk found
  
  [255]
