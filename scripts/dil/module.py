# -*- coding: utf-8 -*-
# Author: Aziz Köksal

class Module:
  def __init__(self, fqn="", tokens=[], ext="", root=None):
    self.tokens = tokens
    self.fqn = fqn
    self.ext = ext
    self.root = root
