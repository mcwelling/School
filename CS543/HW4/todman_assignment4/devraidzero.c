#include	"dat.h"
#include	"fns.h"
#include	"error.h"

enum {
	Qdir,
	Qdata,
	Qctl,
};

Dirtab raidzerotab[] =
{
	".",		{Qdir, 0, QTDIR},	0,	0555,
	"raidzerodata",	{Qdata},	0,	0666,
	"raidzeroctl",	{Qctl},	0,	0666,
};

// globals to establish channels and blocksize
Chan *r1c;
Chan *r2c;
ulong BUFFSIZE = 1024;

enum
{
	CMbind,
};

static
Cmdtab raidzerocmd[] = {
	CMbind,	"bind",	3,
};

static Chan *
raidzeroattach(char *spec)
{
	return devattach('R', spec);
}

static Walkqid *
raidzerowalk(Chan *c, Chan *nc, char **name, int nname)
{
	return devwalk(c, nc, name, nname, raidzerotab, nelem(raidzerotab), devgen);
}

static int
raidzerostat(Chan *c, uchar *db, int n)
{
	return devstat(c, db, n, raidzerotab, nelem(raidzerotab), devgen);
}

static Chan *
raidzeroopen(Chan *c, int omode)
{
	return devopen(c, omode, raidzerotab, nelem(raidzerotab), devgen);
}

static void
raidzeroclose(Chan *c)
{
	USED(c);
}

static long
raidzeroread(Chan *c, void *va, long count, vlong offset)
{
	int addr;
	int o;
	int n;
	int bnum;

	if(c->qid.type & QTDIR)
		return devdirread(c, va, count, raidzerotab, nelem(raidzerotab), devgen);
	
	switch(c->qid.path) {
	case Qdata:
		while(count > 0){
			addr = (offset / BUFFSIZE);
			bnum = addr + 1;
			o = (offset % BUFFSIZE);
			n = BUFFSIZE - o;
			if(n > count){
				n = count;
			}
			if(bnum % 2 == 0){
				devtab[r1c->type]->read(r1c, va, n, o); // even from r0
			}
			else {
				devtab[r2c->type]->read(r2c, va, n, o); // off from r1
			}
			count -= n;
			offset += n;
		}
		break;
	case Qctl:
		n = readstr(offset, va, count, "Read from control file\n");
		break;
	}
	return n;
}

static long
raidzerowrite(Chan *c, void *va, long count, vlong offset)
{
	Cmdbuf *cb;
	Cmdtab *ct;
	int addr;
	int o;
	int n;
	int bnum;

	switch(c->qid.path){
	case Qctl:
		cb = parsecmd(va, count);
		ct = lookupcmd(cb, raidzerocmd, nelem(raidzerocmd));
		switch(ct->index){
		case CMbind:
			r1c = namec(cb->f[1], Aopen, ORDWR, 0);
			r2c = namec(cb->f[2], Aopen, ORDWR, 0);
			break;
		}
		break;
	case Qdata:
		while(count > 0){
			addr = (offset / BUFFSIZE);
			bnum = addr + 1;
			o = (offset % BUFFSIZE);
			n = BUFFSIZE - o;
			if(n > count){
				n = count;
			}
			if(bnum % 2 == 0){
				devtab[r1c->type]->write(r1c, va, n, o); // even to r0
			}
			else {
				devtab[r2c->type]->write(r2c, va, n, o); // odd to r1
			}
			count -= n;
			offset += n;
		}
		break;
	}
	return count;
}

Dev raidzerodevtab = {
	'R',
	"raidzero",

	devinit,
	raidzeroattach,
	raidzerowalk,
	raidzerostat,
	raidzeroopen,
	devcreate,
	raidzeroclose,
	raidzeroread,
	devbread,
	raidzerowrite,
	devbwrite,
	devremove,
	devwstat,
};