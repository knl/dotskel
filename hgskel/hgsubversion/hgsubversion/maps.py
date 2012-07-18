''' Module for self-contained maps. '''

import os
from mercurial import util as hgutil
from mercurial import node

import svncommands
import util

class AuthorMap(dict):
    '''A mapping from Subversion-style authors to Mercurial-style
    authors, and back. The data is stored persistently on disk.

    If the 'hgsubversion.defaultauthors' configuration option is set to false,
    attempting to obtain an unknown author will fail with an Abort.
    '''

    def __init__(self, ui, path, defaulthost=None):
        '''Initialise a new AuthorMap.

        The ui argument is used to print diagnostic messages.

        The path argument is the location of the backing store,
        typically .hg/authormap.
        '''
        self.ui = ui
        self.path = path
        if defaulthost:
            self.defaulthost = '@%s' % defaulthost.lstrip('@')
        else:
            self.defaulthost = ''
        self.super = super(AuthorMap, self)
        self.super.__init__()
        self.load(path)

    def load(self, path):
        ''' Load mappings from a file at the specified path. '''

        path = os.path.expandvars(path)
        if not os.path.exists(path):
            return

        writing = False
        if path != self.path:
            writing = open(self.path, 'a')

        self.ui.note('reading authormap from %s\n' % path)
        f = open(path, 'r')
        for number, line_org in enumerate(f):

            line = line_org.split('#')[0]
            if not line.strip():
                continue

            try:
                src, dst = line.split('=', 1)
            except (IndexError, ValueError):
                msg = 'ignoring line %i in author map %s: %s\n'
                self.ui.status(msg % (number, path, line.rstrip()))
                continue

            src = src.strip()
            dst = dst.strip()

            if writing:
                if not src in self:
                    self.ui.debug('adding author %s to author map\n' % src)
                elif dst != self[src]:
                    msg = 'overriding author: "%s" to "%s" (%s)\n'
                    self.ui.status(msg % (self[src], dst, src))
                writing.write(line_org)

            self[src] = dst

        f.close()
        if writing:
            writing.close()

    def __getitem__(self, author):
        ''' Similar to dict.__getitem__, except in case of an unknown author.
        In such cases, a new value is generated and added to the dictionary
        as well as the backing store. '''
        if author is None:
            author = '(no author)'
        if author in self:
            result = self.super.__getitem__(author)
        elif self.ui.configbool('hgsubversion', 'defaultauthors', True):
            self[author] = result = '%s%s' % (author, self.defaulthost)
            msg = 'substituting author "%s" for default "%s"\n'
            self.ui.note(msg % (author, result))
        else:
            msg = 'author %s has no entry in the author map!'
            raise hgutil.Abort(msg % author)
        self.ui.debug('mapping author "%s" to "%s"\n' % (author, result))
        return result

    def reverselookup(self, author):
        for svnauthor, hgauthor in self.iteritems():
            if author == hgauthor:
                return svnauthor
        else:
            # Mercurial incorrectly splits at e.g. '.', so we roll our own.
            return author.rsplit('@', 1)[0]


class Tags(dict):
    """Map tags to converted node identifier.

    tag names are non-empty strings. Tags are saved in a file
    called tagmap, for backwards compatibility reasons.
    """
    VERSION = 2

    @classmethod
    def filepath(cls, repo):
        return os.path.join(repo.path, 'svn', 'tagmap')

    def __init__(self, repo, endrev=None):
        dict.__init__(self)
        self.path = self.filepath(repo)
        self.endrev = endrev
        if os.path.isfile(self.path):
            self._load(repo)
        else:
            self._write()

    def _load(self, repo):
        f = open(self.path)
        ver = int(f.readline())
        if ver < self.VERSION:
            repo.ui.status('tag map outdated, running rebuildmeta...\n')
            f.close()
            os.unlink(self.path)
            svncommands.rebuildmeta(repo.ui, repo, ())
            return
        elif ver != self.VERSION:
            print 'tagmap too new -- please upgrade'
            raise NotImplementedError
        for l in f:
            ha, revision, tag = l.split(' ', 2)
            revision = int(revision)
            tag = tag[:-1]
            if self.endrev is not None and revision > self.endrev:
                break
            if not tag:
                continue
            dict.__setitem__(self, tag, node.bin(ha))
        f.close()

    def _write(self):
        assert self.endrev is None
        f = open(self.path, 'w')
        f.write('%s\n' % self.VERSION)
        f.close()

    def update(self, other):
        for k, v in other.iteritems():
            self[k] = v

    def __contains__(self, tag):
        return (tag and dict.__contains__(self, tag)
                and dict.__getitem__(self, tag) != node.nullid)

    def __getitem__(self, tag):
        if tag and tag in self:
            return dict.__getitem__(self, tag)
        raise KeyError()

    def __setitem__(self, tag, info):
        if not tag:
            raise hgutil.Abort('tag cannot be empty')
        ha, revision = info
        f = open(self.path, 'a')
        f.write('%s %s %s\n' % (node.hex(ha), revision, tag))
        f.close()
        dict.__setitem__(self, tag, ha)


class RevMap(dict):

    VERSION = 1

    def __init__(self, repo):
        dict.__init__(self)
        self.path = os.path.join(repo.path, 'svn', 'rev_map')
        self.ypath = os.path.join(repo.path, 'svn', 'lastpulled')
        # TODO(durin42): Consider moving management of the youngest
        # file to svnmeta itself rather than leaving it here.
        # must load youngest file first, or else self._load() can
        # clobber the info
        _yonngest_str = util.load_string(self.ypath, '0')
        self._youngest = int(_yonngest_str.strip())
        self.oldest = 0
        if os.path.isfile(self.path):
            self._load()
        else:
            self._write()

    def _set_youngest(self, rev):
        self._youngest = max(self._youngest, rev)
        util.save_string(self.ypath, str(self._youngest) + '\n')

    def _get_youngest(self):
        return self._youngest

    youngest = property(_get_youngest, _set_youngest)

    def hashes(self):
        return dict((v, k) for (k, v) in self.iteritems())

    def branchedits(self, branch, rev):
        check = lambda x: x[0][1] == branch and x[0][0] < rev.revnum
        return sorted(filter(check, self.iteritems()), reverse=True)

    def _load(self):
        f = open(self.path)
        ver = int(f.readline())
        if ver != self.VERSION:
            print 'revmap too new -- please upgrade'
            raise NotImplementedError
        for l in f:
            revnum, ha, branch = l.split(' ', 2)
            if branch == '\n':
                branch = None
            else:
                branch = branch[:-1]
            revnum = int(revnum)
            if revnum > self.youngest or not self.youngest:
                self.youngest = revnum
            if revnum < self.oldest or not self.oldest:
                self.oldest = revnum
            dict.__setitem__(self, (revnum, branch), node.bin(ha))
        f.close()

    def _write(self):
        f = open(self.path, 'w')
        f.write('%s\n' % self.VERSION)
        f.close()

    def __setitem__(self, key, ha):
        revnum, branch = key
        f = open(self.path, 'a')
        b = branch or ''
        f.write(str(revnum) + ' ' + node.hex(ha) + ' ' + b + '\n')
        f.close()
        if revnum > self.youngest or not self.youngest:
            self.youngest = revnum
        if revnum < self.oldest or not self.oldest:
            self.oldest = revnum
        dict.__setitem__(self, (revnum, branch), ha)


class FileMap(object):

    def __init__(self, repo):
        self.ui = repo.ui
        self.include = {}
        self.exclude = {}
        filemap = repo.ui.config('hgsubversion', 'filemap')
        if filemap and os.path.exists(filemap):
            self.load(filemap)

    def _rpairs(self, name):
        yield '.', name
        e = len(name)
        while e != -1:
            yield name[:e], name[e+1:]
            e = name.rfind('/', 0, e)

    def check(self, m, path):
        m = getattr(self, m)
        for pre, _suf in self._rpairs(path):
            if pre not in m:
                continue
            return m[pre]
        return None

    def __contains__(self, path):
        if len(self.include) and len(path):
            inc = self.check('include', path)
        else:
            inc = path
        if len(self.exclude) and len(path):
            exc = self.check('exclude', path)
        else:
            exc = None
        if inc is None or exc is not None:
            return False
        return True

    # Needed so empty filemaps are false
    def __len__(self):
        return len(self.include) + len(self.exclude)

    def add(self, fn, m, path):
        mapping = getattr(self, m)
        if path in mapping:
            msg = 'duplicate %s entry in %s: "%s"\n'
            self.ui.status(msg % (m, fn, path))
            return
        bits = m.strip('e'), path
        self.ui.debug('%sing %s\n' % bits)
        mapping[path] = path

    def load(self, fn):
        self.ui.note('reading file map from %s\n' % fn)
        f = open(fn, 'r')
        for line in f:
            if line.strip() == '' or line.strip()[0] == '#':
                continue
            try:
                cmd, path = line.split(' ', 1)
                cmd = cmd.strip()
                path = path.strip()
                if cmd in ('include', 'exclude'):
                    self.add(fn, cmd, path)
                    continue
                self.ui.warn('unknown filemap command %s\n' % cmd)
            except IndexError:
                msg = 'ignoring bad line in filemap %s: %s\n'
                self.ui.warn(msg % (fn, line.rstrip()))
        f.close()

class BranchMap(dict):
    '''Facility for controlled renaming of branch names. Example:

    oldname = newname
    other = default

    All changes on the oldname branch will now be on the newname branch; all
    changes on other will now be on default (have no branch name set).
    '''

    def __init__(self, ui, path):
        self.ui = ui
        self.path = path
        self.super = super(BranchMap, self)
        self.super.__init__()
        self.load(path)

    def load(self, path):
        '''Load mappings from a file at the specified path.'''
        if not os.path.exists(path):
            return

        writing = False
        if path != self.path:
            writing = open(self.path, 'a')

        self.ui.note('reading branchmap from %s\n' % path)
        f = open(path, 'r')
        for number, line in enumerate(f):

            if writing:
                writing.write(line)

            line = line.split('#')[0]
            if not line.strip():
                continue

            try:
                src, dst = line.split('=', 1)
            except (IndexError, ValueError):
                msg = 'ignoring line %i in branch map %s: %s\n'
                self.ui.status(msg % (number, path, line.rstrip()))
                continue

            src = src.strip()
            dst = dst.strip()
            self.ui.debug('adding branch %s to branch map\n' % src)

            if not dst:
                # prevent people from assuming such lines are valid
                raise hgutil.Abort('removing branches is not supported, yet\n'
                                   '(line %i in branch map %s)'
                                   % (number, path))
            elif src in self and dst != self[src]:
                msg = 'overriding branch: "%s" to "%s" (%s)\n'
                self.ui.status(msg % (self[src], dst, src))
            self[src] = dst

        f.close()
        if writing:
            writing.close()

class TagMap(dict):
    '''Facility for controlled renaming of tags. Example:

    oldname = newname
    other =

        The oldname tag from SVN will be represented as newname in the hg tags;
        the other tag will not be reflected in the hg repository.
    '''

    def __init__(self, ui, path):
        self.ui = ui
        self.path = path
        self.super = super(TagMap, self)
        self.super.__init__()
        self.load(path)

    def load(self, path):
        '''Load mappings from a file at the specified path.'''
        if not os.path.exists(path):
            return

        writing = False
        if path != self.path:
            writing = open(self.path, 'a')

        self.ui.note('reading tag renames from %s\n' % path)
        f = open(path, 'r')
        for number, line in enumerate(f):

            if writing:
                writing.write(line)

            line = line.split('#')[0]
            if not line.strip():
                continue

            try:
                src, dst = line.split('=', 1)
            except (IndexError, ValueError):
                msg = 'ignoring line %i in tag renames %s: %s\n'
                self.ui.status(msg % (number, path, line.rstrip()))
                continue

            src = src.strip()
            dst = dst.strip()
            self.ui.debug('adding tag %s to tag renames\n' % src)

            if src in self and dst != self[src]:
                msg = 'overriding tag rename: "%s" to "%s" (%s)\n'
                self.ui.status(msg % (self[src], dst, src))
            self[src] = dst

        f.close()
        if writing:
            writing.close()
