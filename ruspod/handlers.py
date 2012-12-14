from wender.handlers import BaseHandler


class MainHandler(BaseHandler):

  def get(self):
    self.render('main.html')


class MenuHandler(BaseHandler):

  def get(self):
    self.render('menu.html')


class OrderHandler(BaseHandler):

  def get(self):
    self.render('order.html')


class AboutHandler(BaseHandler):

  def get(self):
    self.render('about.html')


class ContactHandler(BaseHandler):

  def get(self):
    self.render('contact.html')


handlers = [
    ('/', MainHandler),
    ('/menu', MenuHandler),
    ('/order', OrderHandler),
    ('/about', AboutHandler),
    ('/contact', ContactHandler),
    ]
