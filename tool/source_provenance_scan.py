#!/usr/bin/env python3
"""Compare immutable local source snapshots, without executing upstream code.

Skips comments, checks literal 20/40-token and identifier/literal-normalized
100-token runs, and SHA-256 equality for nonempty files. This is a lexical
heuristic, not an AST translation detector or a legal provenance decision.
Snapshots must contain only the intended source files (exclude caches/builds).
"""
from pathlib import Path
import re,json,hashlib,collections,time
import argparse
parser=argparse.ArgumentParser(description='Lexical source similarity scan; matches are review leads, not proof of copying or legal clearance.')
parser.add_argument('--manifest', type=Path, required=True, help='Local snapshot.json with snapshotRoot and references')
parser.add_argument('--output', type=Path, required=True)
args=parser.parse_args()
manifest=json.loads(args.manifest.read_text())
base=Path(manifest['snapshotRoot'])
exts={'.dart','.kt','.java','.swift','.m','.mm','.h','.hpp','.cc','.cpp','.c','.rs','.qml','.py','.sh','.cmake'}
lex=re.compile(r'(?P<comment>//[^\n]*|/\*[\s\S]*?\*/)|(?P<string>"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|(?P<id>[A-Za-z_$][A-Za-z0-9_$]*)|(?P<num>\d+(?:\.\d+)?)|(?P<op>[^\s])')
keywords=set('if else for while do switch case default break continue return class struct enum interface extends implements import package using namespace public private protected static final const var let mut val new this self super async await try catch finally throw throws true false null nil void bool int double float String string fun fn def function override abstract sealed get set in is as when with required late factory typedef operator'.split())
def sources(root):
 out={}
 for p in root.rglob('*'):
  if p.is_file() and (p.suffix in exts or p.name=='CMakeLists.txt'):
   text=p.read_text(errors='replace');tokens=[];lines=[];struct=[]
   offsets=[0]
   for m in re.finditer('\n',text):offsets.append(m.end())
   import bisect
   for m in lex.finditer(text):
    if m.lastgroup=='comment':continue
    v=m.group();tokens.append(v);lines.append(bisect.bisect_right(offsets,m.start()));struct.append('LIT' if m.lastgroup in {'string','num'} else 'ID' if m.lastgroup=='id' and v not in keywords else v)
   if tokens:out[str(p.relative_to(root))]=(tokens,struct,lines)
 return out
own=sources(base/'dukto2')
def digest(tokens):return hashlib.blake2b('\x1f'.join(tokens).encode(),digest_size=12).digest()
results={'sourceFileCounts':{'dukto2':len(own)},'exactFiles':{},'tokenMatches':{}}
for ref in manifest['references']:
 upstream=sources(base/ref);results['sourceFileCounts'][ref]=len(upstream)
 hashes=collections.defaultdict(list)
 for p in (base/ref).rglob('*'):
  if p.is_file() and p.stat().st_size:hashes[hashlib.sha256(p.read_bytes()).hexdigest()].append(str(p.relative_to(base/ref)))
 identical=[]
 for p in (base/'dukto2').rglob('*'):
  if p.is_file() and p.stat().st_size:
   h=hashlib.sha256(p.read_bytes()).hexdigest()
   if h in hashes:identical.append({'own':str(p.relative_to(base/'dukto2')),'upstream':hashes[h]})
 results['exactFiles'][ref]=identical
 results['tokenMatches'][ref]={}
 for mode,k,index in [('literal20',20,0),('literal40',40,0),('structural100',100,1)]:
  lookup=collections.defaultdict(list)
  for f,data in own.items():
   tok=data[index]
   for i in range(len(tok)-k+1):lookup[digest(tok[i:i+k])].append((f,i))
  pairs=collections.defaultdict(list)
  for f,data in upstream.items():
   tok=data[index]
   for j in range(len(tok)-k+1):
    for of,i in lookup.get(digest(tok[j:j+k]),[]):
     if own[of][index][i:i+k]==tok[j:j+k]:pairs[(of,f)].append((i,j))
  rows=[]
  for (of,f),anchors in pairs.items():
   aset=set(anchors);best=None;bestn=0
   for i,j in aset:
    if (i-1,j-1) in aset:continue
    n=1
    while (i+n,j+n) in aset:n+=1
    if n>bestn:bestn=n;best=(i,j)
   i,j=best;span=bestn+k-1
   rows.append({'own':of,'upstream':f,'matchingWindows':len(anchors),'longestTokens':span,'ownLines':[own[of][2][i],own[of][2][i+span-1]],'upstreamLines':[upstream[f][2][j],upstream[f][2][j+span-1]]})
  results['tokenMatches'][ref][mode]=sorted(rows,key=lambda x:x['longestTokens'],reverse=True)
  print(ref,mode,'pairs',len(rows),'largest',results['tokenMatches'][ref][mode][:3],flush=True)
args.output.write_text(json.dumps(results,indent=2)+'\n')
print('Exact nonempty file counts:', {k:len(v) for k,v in results['exactFiles'].items()}, flush=True)
