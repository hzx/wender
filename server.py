import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import os.path

# IMPORT HERE HANDLERS
from ruspod.handlers import handlers as ruspodHandlers
from ruspodan.handlers import handlers as ruspodanHandlers

from tornado.options import define, options
define('port', default=8000, help="web port", type=int)
# COMPOSE DB CONNECTION
define('mongodb', default='mongodb://user:password@localhost:27017/rubear')

# COMPOSE HANDLERS HERE
handlers = ruspodHandlers + ruspodanHandlers

# COMPOSE SETTINGS
settings= {
    'debug': True,
    'autoescape': None,
    'template_path': os.path.normpath(os.path.join(os.path.dirname(__file__), './templates')),
    'static_path': os.path.normpath(os.path.join(os.path.dirname(__file__), './static')),
    'xsrf_cookies': True,
    'cookie_secret': 'rsyM3CJnRES831OMeu5OunHm2c1cUk3UvmySrdhJ+sY=',
    'login_url': '/login',
    }

class Application(tornado.web.Application):
  def __init__(self):
    tornado.web.Application.__init__(self, handlers, **settings)

if __name__ == "__main__":
  tornado.options.parse_command_line()
  server = tornado.httpserver.HTTPServer(Application())
  server.listen(options.port)
  tornado.ioloop.IOLoop.instance().start()
