import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import os.path
from wender.handlers import handlers as wenderHandlers

CURRENT_DIR = os.path.abspath(os.path.dirname(__file__))

# IMPORT HERE HANDLERS
{% for handler in handlers %}
from {{ handler['module'] }} import urls as {{ handler['alias'] }}
{% end %}

# from ruspod.handlers import handlers as ruspodHandlers
# from ruspodan.handlers import handlers as ruspodanHandlers

from tornado.options import define, options
define('port', default=8000, help='web port', type=int)
# COMPOSE DB CONNECTION
define('mongodb', default='{{ mongodb }}')

# COMPOSE HANDLERS HERE
handlers = wenderHandlers {% for handler in handlers %} + {{ handler['alias'] }}{% end %}

# COMPOSE SETTINGS
settings = {
    'debug': {{ debug }},
    'autoescape': None,
    'template_path': os.path.abspath(os.path.normpath(CURRENT_DIR + '/../templates')),
    'static_path': os.path.abspath(os.path.normpath(CURRENT_DIR + '/../static')),
    'xsrf_cookies': True,
    'cookie_secret': '{{ cookie_secret }}',
    'login_url': '/login',
    }

class Application(tornado.web.Application):
  def __init__(self):
    tornado.web.Application.__init__(self, handlers, **settings)

if __name__ == "__main__":
  tornado.options.parse_command_line()
  server = tornado.httpserver.HTTPServer(Application(), xheaders=True)
  server.listen(options.port)
  tornado.ioloop.IOLoop.instance().start()
