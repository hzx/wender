# -*- coding: utf-8 -*-
import re

tagReSrc = u'[a-z0-9а-я]+'

pretextsRaw = ['в', 'без', 'до', 'из', 'к', 'на', 'по', 'о', 'от', 'перед', 'при', 'через', 'с', 'у', 'за', 'над', 'об', 'под', 'про', 'для']
pretexts = {}
for it in pretextsRaw:
  pretexts[it] = None

def getTags(text):
  text = text.lower()
  tagRe = re.compile(tagReSrc, re.UNICODE)
  tags = tagRe.findall(text)
  filtered = {}
  for tag in tags:
    if (len(tag) <= 1) or (tag in pretexts):
      continue
    filtered[tag] = None
  return filtered.keys()


def getPartialTags(text):
  tags = getTags(text)
  if len(tags) == 0:
    return []
  vocabulary = {}
  for tag in tags:
    length = len(tag)
    if length < 2:
      continue
    vocabulary[tag] = None
    for last in range(2, length):
      vocabulary[tag[0:last]] = None
  return vocabulary.keys()
