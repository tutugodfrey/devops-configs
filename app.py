from rediscluster import StrictRedisCluster
import time
from flask import Flask


app = Flask(__name__)
startup_nodes = [{"host": "redis-cluster", "port": "6379"}]
cache = StrictRedisCluster(startup_nodes=startup_nodes, decode_responses=True)


def get_hit_count():
    return cache.incr('hits')


@app.route('/')
def hit():
    count = get_hit_count()
    return 'I have been hit %i times since deployment.\n' % int(count)


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)


