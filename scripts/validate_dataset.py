#!/usr/bin/env python3
from pathlib import Path
import csv, sys
from collections import defaultdict, deque

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    with open(ROOT/rel, encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))

domains = read('data/source/domains.csv')
interfaces = read('data/source/interfaces.csv')
official = read('data/source/interface_relations_official.csv')
semantic = read('data/source/interface_relations_semantic.csv')
objects = read('data/demo/objects.csv')
props = read('data/demo/object_properties.csv')
objrels = read('data/demo/object_relations.csv')
scenarios = read('data/demo/scenarios.csv')

errors=[]

def index_unique(rows, key, label):
    out={}
    for r in rows:
        v=r[key]
        if v in out:
            errors.append(f"duplicate {label}: {v}")
        out[v]=r
    return out

doms=index_unique(domains,'domain_id','domain_id')
ints=index_unique(interfaces,'interface_id','interface_id')
objs=index_unique(objects,'object_id','object_id')
scs=index_unique(scenarios,'scenario_id','scenario_id')
index_unique(official,'relation_id','official relation_id')
index_unique(semantic,'relation_id','semantic relation_id')
index_unique(objrels,'relationship_id','object relationship_id')

# 1. Every Interface belongs to exactly one known Domain.
for i in interfaces:
    if i['domain_id'] not in doms:
        errors.append(f"interface domain missing: {i['interface_id']} -> {i['domain_id']}")

# 2. Official relationship endpoints.
for r in official:
    if r['source_interface_id'] not in ints or r['target_interface_id'] not in ints:
        errors.append(f"official endpoint missing: {r['relation_id']}")
    if r['relation_type']=='LINK' and r['directionality']!='conceptually_undirected':
        errors.append(f"LINK directionality must be conceptually_undirected: {r['relation_id']}")
    if r['relation_type']=='EXTENDS_TO' and r['directionality']!='directed_child_to_parent':
        errors.append(f"EXTENDS_TO directionality mismatch: {r['relation_id']}")

# 3. Semantic relation must derive from an official LINK.
orig={r['relation_id']:r for r in official}
for r in semantic:
    base=orig.get(r['derived_from_relation_id'])
    if not base:
        errors.append(f"semantic base missing: {r['relation_id']}")
    elif base['relation_type'] != 'LINK':
        errors.append(f"semantic base is not LINK: {r['relation_id']} -> {base['relation_type']}")

# 4. Object -> Interface and scenario membership.
for o in objects:
    if o['primary_interface_id'] not in ints:
        errors.append(f"object interface missing: {o['object_id']} -> {o['primary_interface_id']}")
    for sid in filter(None,o['scenario_ids'].split('|')):
        if sid not in scs:
            errors.append(f"object scenario missing: {o['object_id']} -> {sid}")

# 5. Property object references.
for p in props:
    if p['object_id'] not in objs:
        errors.append(f"property object missing: {p['object_id']}")

# EXTENDS_TO closure child -> ancestors including self.
parent=defaultdict(list)
for r in official:
    if r['relation_type']=='EXTENDS_TO':
        parent[r['source_interface_id']].append(r['target_interface_id'])

def ancestors(i):
    seen={i}; q=deque([i])
    while q:
        x=q.popleft()
        for y in parent[x]:
            if y not in seen:
                seen.add(y); q.append(y)
    return seen
anc={i:ancestors(i) for i in ints}

# Semantic rule index.
rules=defaultdict(list)
for r in semantic:
    rules[r['relation_type']].append((r['source_interface_id'],r['target_interface_id'],r['relation_id']))

# 6. Object relationship validation.
for r in objrels:
    s=objs.get(r['source_object_id']); t=objs.get(r['target_object_id'])
    if not s or not t:
        errors.append(f"object relation endpoint missing: {r['relationship_id']}")
        continue
    sid=r['scenario_id']
    if sid not in scs:
        errors.append(f"relation scenario missing: {r['relationship_id']} -> {sid}")
    if sid not in s['scenario_ids'].split('|') or sid not in t['scenario_ids'].split('|'):
        errors.append(f"scenario membership mismatch: {r['relationship_id']} {sid} {s['object_id']}->{t['object_id']}")
    si=s['primary_interface_id']; ti=t['primary_interface_id']; typ=r['relation_type']
    supported=[]
    for rs,rt,rid in rules.get(typ,[]):
        if rs in anc[si] and rt in anc[ti]:
            supported.append(rid)
    if not supported:
        errors.append(f"no semantic rule supports {r['relationship_id']}: {si}-[{typ}]->{ti}")
    declared='SR-'+r['basis_interface_relation_id'].split('-')[-1]
    if supported and declared not in supported:
        errors.append(f"basis mismatch {r['relationship_id']}: declared {declared}, supported {supported}")

print('Defense OSDK Neo4j dataset validation — revised explicit hierarchy')
print(f"domain/group nodes: {len(domains)} (official OSDK: {sum(r['official'].lower()=='true' for r in domains)}, platform base reference groups: {sum(r['domain_kind']=='platform_base_group' for r in domains)})")
print(f"interfaces: {len(interfaces)}")
print(f"official interface relations: {len(official)}")
print(f"  - LINK (conceptually undirected): {sum(r['relation_type']=='LINK' for r in official)}")
print(f"  - EXTENDS_TO (directed): {sum(r['relation_type']=='EXTENDS_TO' for r in official)}")
print(f"semantic interface relations: {len(semantic)}")
print(f"objects: {len(objects)}")
print(f"object properties: {len(props)}")
print(f"curated object relations: {len(objrels)}")
print(f"scenarios: {len(scenarios)}")

if errors:
    print(f"FAIL: {len(errors)} error(s)")
    for e in errors:
        print(' -',e)
    sys.exit(1)
print('PASS: domain/interface hierarchy, inheritance, scenarios, and semantic-rule checks passed.')
