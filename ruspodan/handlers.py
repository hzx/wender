from wender.handlers import BaseHandler


class DefaultHandler(BaseHandler):

  def get(self):
    self.render('admin/default.html')


class MainHandler(BaseHandler):

  def get(self):
    self.render('admin/main.html')


class MenuHandler(BaseHandler):

  def get(self):
    self.render('admin/menu.html')


class OrderHandler(BaseHandler):

  def get(self):
    self.render('admin/order.html')


class AboutHandler(BaseHandler):

  def get(self):
    self.render('admin/about.html')


class ContactHandler(BaseHandler):

  def get(self):
    self.render('admin/contact.html')


handlers = [
    ('/admin', DefaultHandler),
    ('/admin/main', MainHandler),
    ('/admin/menu', MenuHandler),
    ('/admin/order', OrderHandler),
    ('/admin/about', AboutHandler),
    ('/admin/contact', ContactHandler),
    ]
