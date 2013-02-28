
class Observer:
  def __init__(self):
    self.handlers = []

  def add(self, handler):
    if not (handler in self.handlers):
      self.handlers.append(handler)

  def remove(self, handler):
    if handler in self.handlers:
      self.handlers.remove(handler)

  def notify(self, event):
    for handler in self.handlers:
      handler(event)
